

import 'package:device_calendar_example/controller/local_storage.dart';

class Event {
  double get id => map['id'] as double? ?? 0.0;
  String get name => map['name'] as String? ?? '';
  String get startDate => map['start_date'] as String? ?? '';
  String get endDate => map['end_date'] as String? ?? '';
  String get _details => (map['detail'] as String? ?? '').trim();
  String get details => _details.isEmpty ? 'No Description Available' : _details;
  String get timezone => map['timezone'] as String? ?? '';
  final Map<String, dynamic> map;

  const Event({this.map = const <String, dynamic>{}});

  static Event creatEvent({
    required String name,
    required String startDate,
    required String endDate,
    String timezone = 'utc',
    required String detail,
  }) {
    return Event(map: {
      'id': DateTime.now().millisecondsSinceEpoch / 8640000000000000,
      'name': name,
      'start_date': startDate,
      'end_date': endDate,
      'detail': detail,
      'timezone': timezone
    });
  }
}

class AllEvents extends Manageable<List<dynamic>> {
  @override
  Future<void> init() async {
    data = AllEvents(list: await readFromFile());
  }

  @override
  Future<void> clear() async {
    await clearLocal();
    data = AllEvents();
  }

  const AllEvents({List<dynamic> list = const <dynamic>[]}) : super(fileName: 'all_events', value: list);
  List<Event> get allEventList => value.map((dynamic e) => Event(map: e as Map<String, dynamic>)).toList();

  static AllEvents data = AllEvents();
}
