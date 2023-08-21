import 'package:device_calendar_example/bloc/event_bloc.dart';
import 'package:device_calendar_example/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black54),
        useMaterial3: true,
      ),
      home: BlocProvider<CalendarBloc>(
        create: (_) => CalendarBloc.bloc,
        child: BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, state) {
            return HomeScreen();
          },
        ),
      ),
    );
  }
}
