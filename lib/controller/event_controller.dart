import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_calendar/device_calendar.dart' as cal;
import 'package:device_calendar_example/controller/helper_functions.dart';
import 'package:intl/intl.dart';
import '../model/event.dart';

class CalendarEventsRepository {
  static final CalendarEventsRepository repo =
      CalendarEventsRepository._internal();
  late cal.DeviceCalendarPlugin _deviceCalendarPlugin;
  CalendarEventsRepository._internal() {
    _deviceCalendarPlugin = cal.DeviceCalendarPlugin();
  }

  Future<cal.Calendar?> _getCalendar() async {
    try {
      List<cal.Calendar> calendar = <cal.Calendar>[];
      final cal.Result<UnmodifiableListView<cal.Calendar>> calendarResult =
          await _deviceCalendarPlugin.retrieveCalendars();
      if (calendarResult.data != null) {
        if (Platform.isIOS) {
          return calendarResult.data!.firstWhere(
            (cal.Calendar element) => element.name!.toUpperCase() == 'CALENDAR',
          );
        } else if (Platform.isAndroid) {
          calendar = calendarResult.data as List<cal.Calendar>;
          return calendar.first;
        }
      }
    } catch (error, stackTrace) {
      log(error.toString());
      return null;
    }
    return null;
  }

  Future<bool> eventExists(Event event) async {
    final _CalendarEvent cEvent = _CalendarEvent.fromEvent(event: event);
    await cEvent.loadEvent();
    return cEvent.uid.isNotEmpty;
  }

  Future<bool> saveEvent(Event event) async {
    final _CalendarEvent cEvent = _CalendarEvent.fromEvent(event: event);
    final cal.Calendar? calendar = await _getCalendar();
    if (calendar != null) {
      final cal.Result<String>? status =
          await _deviceCalendarPlugin.createOrUpdateEvent(
        cEvent.toCalEvent(calendar.id ?? ''),
      );
      if (status != null && status.isSuccess) {
        await _CalendarEvent.fromEvent(uid: status.data ?? '', event: event)
            .save();
        return true;
      }
    }
    return false;
  }

  Future<List<cal.Event>> fetchEventList(String calendarId) async {
    final startDate = DateTime.now().add(const Duration(days: -30));
    final endDate = DateTime.now().add(const Duration(days: 30));
    var calendarEventsResult = await _deviceCalendarPlugin.retrieveEvents(
        calendarId,
        cal.RetrieveEventsParams(startDate: startDate, endDate: endDate));
    return calendarEventsResult.data as List<cal.Event>;
  }

  Future<bool> deleteLocalEvent(Event event) async {
    final _CalendarEvent cEvent = _CalendarEvent.fromEvent(event: event);
    await cEvent.loadEvent();
    final cal.Calendar? calendar = await _getCalendar();
    if (calendar != null) {
      await _deviceCalendarPlugin.deleteEvent(calendar.id, cEvent.uid);
      await cEvent.delete();
      return true;
    }
    return false;
  }

  Future<bool> deleteEvent(cal.Event event) async {
    final cal.Calendar? calendar = await _getCalendar();
    if (calendar != null) {
      await _deviceCalendarPlugin.deleteEvent(event.calendarId, event.eventId);
      return true;
    }
    return false;
  }

  Future<bool> saveOrDeleteEvent(Event event) async {
    final cal.Calendar? calendar = await _getCalendar();
    if (calendar != null) {
      final _CalendarEvent cEvent = _CalendarEvent.fromEvent(event: event);
      await cEvent.loadEvent();
      if (cEvent.uid.isNotEmpty) {
        return deleteLocalEvent(event);
      } else {
        return saveEvent(event);
      }
    }
    return false;
  }
}

class _CalendarEvent extends Event {
  static const String _fileName = 'calendar_events_uid';
  String get uid => _uid;
  String _uid = '';
  _CalendarEvent() : super(map: <String, dynamic>{});

  _CalendarEvent.fromEvent({
    required Event event,
    String uid = '',
  })  : _uid = uid,
        super(
          map: <String, dynamic>{
            'detail': event.details,
            'end_date': event.endDate,
            'id': event.id,
            'name': event.name,
            'start_date': event.startDate,
            'timezone': event.timezone,
            'uid': uid,
            'event_id': event.id,
          },
        );

  cal.Event toCalEvent(String calendarId) {
    final DateTime startDate =
        DateTime.tryParse(super.startDate) ?? DateTime.now();
    final DateTime endDate = DateTime.tryParse(super.endDate) ?? DateTime.now();
    return cal.Event(
      calendarId,
      eventId: uid.isEmpty ? null : uid,
      title: super.name,
      description: super.details,
      start: cal.TZDateTime.local(
        startDate.year,
        startDate.month,
        startDate.day,
        startDate.hour,
        startDate.minute,
        startDate.second,
      ),
      end: cal.TZDateTime.local(
        endDate.year,
        endDate.month,
        endDate.day,
        endDate.hour,
        endDate.minute,
        endDate.second,
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _read() async {
    String? content = await HelperFunctions.storage.read(key: _fileName);
    content ??= jsonEncode(<Map<String, dynamic>>[
      <String, dynamic>{
        'uid': '',
        'event_id': '',
      },
    ]);
    final List<dynamic> out = jsonDecode(content) as List<dynamic>;
    return out.map((dynamic e) => e as Map<String, dynamic>).toList();
  }

  Future<void> _write(List<Map<String, dynamic>> list) async {
    await HelperFunctions.storage
        .write(key: _fileName, value: jsonEncode(list));
  }

  Future<void> save() async {
    final List<Map<String, dynamic>> decoded = await _read();
    if (!decoded.any((Map<String, dynamic> e) => e['event_id'] == super.id)) {
      decoded.add(map);
    }
    await _write(decoded);
  }

  Future<void> loadEvent() async {
    final List<Map<String, dynamic>> decoded = await _read();
    _uid = decoded
        .firstWhere(
          (Map<String, dynamic> e) => e['event_id'] == super.id,
          orElse: () => <String, dynamic>{'uid': ''},
        )['uid']
        .toString();
  }

  Future<void> update(String newUid) async {
    final List<Map<String, dynamic>> list = await _read();
    for (int i = 0; i < list.length; i++) {
      if (list[i]['event_id'] == id) list[i]['uid'] = newUid;
    }
    await _write(list);
  }

  Future<void> delete() async {
    final List<Map<String, dynamic>> list = await _read();
    for (int i = 0; i < list.length; i++) {
      if (list[i]['event_id'] == id) list.removeAt(i);
    }
    await _write(list);
  }
}
