part of 'event_bloc.dart';

abstract class CalendarEvent {
  const CalendarEvent();
}

class CreateCalendarEvent extends CalendarEvent {
  final Event event;
  final BuildContext context;
  CreateCalendarEvent({required this.event, required this.context});
}

class CheckEventExists extends CalendarEvent {
  final Event event;
  CheckEventExists({required this.event});
}

class FetchEventList extends CalendarEvent {
  final String calendarId;
  FetchEventList({required this.calendarId});
}

class DeleteEvent extends CalendarEvent {
  final cal.Event event;
  DeleteEvent({required this.event});
}
