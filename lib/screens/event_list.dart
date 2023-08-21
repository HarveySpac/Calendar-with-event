import 'package:device_calendar_example/bloc/event_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:device_calendar/device_calendar.dart' as cal;

class EventList extends StatelessWidget {
  EventList({required this.calendarId});
  final String calendarId;
  final List<cal.Event> eventList = [];
  final CalendarBloc bloc = CalendarBloc();

  @override
  Widget build(BuildContext context) {
    bloc.add(FetchEventList(calendarId: calendarId));
    return BlocConsumer<CalendarBloc, CalendarState>(
      listener: (context, state) {},
      buildWhen: (previous, current) {
        if (current is CalendarLoaded) {
          if (current.eventList != null) {
            eventList.clear();
            eventList.addAll(current.eventList!);
            return true;
          }
          if (current.eventDeleted) {
            bloc.add(FetchEventList(calendarId: calendarId));

            return true;
          }
        }
        return false;
      },
      bloc: bloc,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Event List'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: eventList.length,
              itemBuilder: (context, index) {
                return EventTile(
                  event: eventList[index],
                  onDelete: () =>
                      bloc.add(DeleteEvent(event: eventList[index])),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class EventTile extends StatelessWidget {
  final cal.Event event;
  final void Function() onDelete;
  EventTile({required this.event, Key? key, required this.onDelete})
      : super(key: key);

  final orangeColor = const Color(0xffFF8527);
  @override
  Widget build(BuildContext context) {
    final String startDate = DateFormat('MMM d, yyyy')
        .format(DateTime.tryParse(event.start.toString()) ?? DateTime.now());
    final String endDate = DateFormat('MMM d, yyyy')
        .format(DateTime.tryParse(event.end.toString()) ?? DateTime.now());

    return ListTile(
      isThreeLine: true,
      leading: Icon(Icons.event),
      title: Text(event.title ?? 'Event Title'),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.description ?? 'Event Description'),
                Text('Start Date: ${startDate}'),
                Text('Start Date: ${endDate}'),
              ],
            ),
          ),
        ],
      ),
      trailing: Column(
        children: [IconButton(onPressed: onDelete, icon: Icon(Icons.delete))],
      ),
    );
  }
}
