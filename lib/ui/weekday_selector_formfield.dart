import 'package:chores_app/database/entity/DbMember.dart';
import 'package:chores_app/models/Task.dart';
import 'package:chores_app/ui/weekday_selector.dart';
import 'package:flutter/material.dart';

class WeekDaySelectScreen extends StatelessWidget {
  final Task mTask;

  WeekDaySelectScreen({Key key, this.mTask}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final examples = <Widget>[
      DisabledExample(mTask: mTask,),
      // TODO: use with setstate
    ];
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.all(12),
          separatorBuilder: (_, __) => Divider(height: 24),
          itemBuilder: (_, index) => examples[index],
          itemCount: examples.length,
        ),
      ]);
  }
}
class DisabledExample extends StatefulWidget {
  final Task mTask;

  const DisabledExample({Key key, this.mTask}) : super(key: key);
  @override
  _DisabledExampleState createState() => _DisabledExampleState();
}

class _DisabledExampleState extends State<DisabledExample> {
  //final values = <bool>[false, false, false, false, false, false, false];
  final values = List.filled(7, true);
  List<String> weekList = List<String>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ExampleTitle('Select Week Day'),
        SizedBox(height: 5.0,),
        WeekdaySelector(
          selectedFillColor: Colors.amber[800],
          onChanged: (v) {
            var week = intDayToEnglish(v);
            print("Week  selected ${week}");
            setState(() {
              values[v % 7] = !values[v % 7];
              if(weekList.contains(week))
                {
                  weekList.remove(week.toString());
                }
              else{
                weekList.add(week.toString());
               // widget.mTask.custom = week.toString();
              }
            });
          },
          values: values,
        ),
      ],
    );
  }
}

class ExampleTitle extends StatelessWidget {
  final String title;

  const ExampleTitle(this.title, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(title, style: Theme.of(context).textTheme.title,),
    );
  }
}

/// Print the integer value of the day and the day that it corresponds to in English.
///
/// It's added to the example so that you can always see and verify that the
/// code is correct.
printIntAsDay(int day) {
  print('Received integer: $day. Corresponds to day: ${intDayToEnglish(day)}');
  var week = intDayToEnglish(day);
}

String intDayToEnglish(int day) {
  if (day % 7 == DateTime.monday % 7) return 'Monday';
  if (day % 7 == DateTime.tuesday % 7) return 'Tueday';
  if (day % 7 == DateTime.wednesday % 7) return 'Wednesday';
  if (day % 7 == DateTime.thursday % 7) return 'Thursday';
  if (day % 7 == DateTime.friday % 7) return 'Friday';
  if (day % 7 == DateTime.saturday % 7) return 'Saturday';
  if (day % 7 == DateTime.sunday % 7) return 'Sunday';
  throw '🐞 This should never have happened: $day';
}
