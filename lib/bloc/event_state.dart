part of 'event_bloc.dart';

abstract class CalendarState {
  const CalendarState();
}

class EventDetailsInitial extends CalendarState {}

class EventDetailsLoading extends CalendarState {}

class CalendarLoaded extends CalendarState {
  final bool eventSaved;
  final bool eventDeleted;
  final List<cal.Event>? eventList;
  CalendarLoaded(
      {this.eventSaved = false, this.eventList, this.eventDeleted = false});
}

class EventDetailsError extends CalendarState {
  final String message;
  final bool isError;

  EventDetailsError({
    required this.message,
    this.isError = false,
  });
}
