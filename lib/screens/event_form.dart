import 'package:device_calendar_example/bloc/event_bloc.dart';
import 'package:device_calendar_example/controller/helper_functions.dart';
import 'package:device_calendar_example/model/event.dart';
import 'package:device_calendar_example/screens/custom_text_Field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class EventForm extends StatelessWidget {
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController eventTitle = TextEditingController();
  final TextEditingController eventDescription = TextEditingController();
  final CalendarBloc bloc = CalendarBloc();
  DateTime? _startDate;
  DateTime? _endDate;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CalendarBloc, CalendarState>(
      listener: (context, state) {
        if (state is CalendarLoaded) {
          if (state.eventSaved) {
            HelperFunctions.showMessage(context,
                message: 'Event Saved Successully');
            Navigator.pop(context);
          }
        } else if (state is EventDetailsError) {
          HelperFunctions.showMessage(context, message: state.message);
        }
      },
      bloc: bloc,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Event Form'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  CustomTextField(
                    inputController: eventTitle,
                    hintText: 'Event Title',
                  ),
                  CustomTextField(
                    inputController: eventDescription,
                    hintText: 'Event Description',
                  ),
                  CustomDateField(
                    inputController: startDateController,
                    onTap: () async {
                      DateTime? _date = await _showDatePicker(context);
                      if (_date != null) {
                        _startDate = _date;
                        startDateController.text =
                            DateFormat('MMM d, yyyy').format(_date);
                      }
                    },
                    hintText: 'Event Start Date',
                  ),
                  CustomDateField(
                    inputController: endDateController,
                    onTap: () async {
                      DateTime? _date = await _showDatePicker(context);
                      if (_date != null) {
                        _endDate = _date;
                        endDateController.text =
                            DateFormat('MMM d, yyyy').format(_date);
                      }
                    },
                    hintText: 'Event End Date',
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (eventTitle.text.isEmpty) {
                        HelperFunctions.showMessage(context,
                            message: 'Event Title is Required');
                      } else if (eventDescription.text.isEmpty) {
                        HelperFunctions.showMessage(context,
                            message: 'Event Description is Required');
                      } else if (_startDate == null) {
                        HelperFunctions.showMessage(context,
                            message: 'Start Date is Required');
                      } else if (_endDate == null) {
                        HelperFunctions.showMessage(context,
                            message: 'End Date is Required');
                      } else {
                        bloc.add(CreateCalendarEvent(
                            event: Event.creatEvent(
                              name: eventTitle.text,
                              startDate: _startDate.toString(),
                              endDate: _endDate.toString(),
                              detail: eventDescription.text,
                            ),
                            context: context));
                      }
                    },
                    child: Text('Add Event'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<DateTime?> _showDatePicker(BuildContext context) async {
    return showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2024));
  }
}
