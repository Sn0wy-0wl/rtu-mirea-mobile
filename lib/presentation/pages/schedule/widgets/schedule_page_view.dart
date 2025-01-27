import 'package:flutter/material.dart';
import 'package:rtu_mirea_app/common/calendar.dart';
import 'package:rtu_mirea_app/domain/entities/lesson.dart';
import 'package:rtu_mirea_app/domain/entities/schedule.dart';
import 'package:rtu_mirea_app/presentation/colors.dart';
import 'package:rtu_mirea_app/presentation/theme.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'lesson_card.dart';

class SchedulePageView extends StatefulWidget {
  final Schedule schedule;

  const SchedulePageView({Key? key, required this.schedule}) : super(key: key);

  @override
  _SchedulePageViewState createState() => _SchedulePageViewState();
}

class _SchedulePageViewState extends State<SchedulePageView> {
  late int _selectedWeek;
  late int _selectedPage;
  late DateTime _selectedDay;
  late final PageController _controller;

  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();

  final DateTime _firstCalendarDay = Calendar.getSemesterStart();
  final DateTime _lastCalendarDay =
      DateTime.utc(2021, 12, 19); // TODO: create method for it

  late List<List<Lesson>> _allLessonsInWeek;

  @override
  void initState() {
    super.initState();

    // initialize data
    _selectedPage = DateTime.now().difference(_firstCalendarDay).inDays;
    _controller = PageController(initialPage: _selectedPage);
    _selectedDay = DateTime.now();
    _selectedWeek = Calendar.getCurrentWeek();
    _allLessonsInWeek = _getLessonsByWeek(_selectedWeek, widget.schedule);
  }

  List<List<Lesson>> _getLessonsByWeek(int week, Schedule schedule) {
    List<List<Lesson>> lessonsInWeek = [];
    for (int i = 1; i <= 6; i++) {
      lessonsInWeek.add([]);
      schedule.schedule[i.toString()]!.lessons.forEach((elements) {
        elements.forEach((lesson) {
          if (lesson.weeks.contains(week)) lessonsInWeek[i - 1].add(lesson);
        });
      });
    }

    return lessonsInWeek;
  }

  Widget _buildEmptyLessons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image(
          image: AssetImage('assets/images/Saly-18.png'),
          height: 225.0,
        ),
        Text('Пар нет!', style: DarkTextTheme.title),
      ],
    );
  }

  Widget _buildPageViewContent(BuildContext context, int index) {
    if (index == 6) {
      return _buildEmptyLessons();
    } else {
      final lessons = _allLessonsInWeek[index];
      if (lessons.length == 0) return _buildEmptyLessons();
      return Container(
        child: ListView.separated(
          itemCount: lessons.length,
          itemBuilder: (context, i) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: LessonCard(
                name: lessons[i].name,
                timeStart: lessons[i].timeStart,
                timeEnd: lessons[i].timeEnd,
                room: '${lessons[i].rooms.join(', ')}',
                type: lessons[i].types,
                teacher: '${lessons[i].teachers.join(', ')}',
              ),
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(height: 8);
          },
        ),
      );
    }
  }

  void _setLessonsByWeek(int week) {
    if (week != _selectedWeek) {
      _selectedWeek = week;
      _allLessonsInWeek = _getLessonsByWeek(week, widget.schedule);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          // pageJumpingEnabled: true,
          weekendDays: const [DateTime.sunday],
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  events.length,
                  (index) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 0.3),
                    decoration: new BoxDecoration(
                      color: LessonCard.getColorByType(
                          (events[index] as Lesson).types),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          calendarFormat: _calendarFormat,
          firstDay: _firstCalendarDay,
          lastDay: _lastCalendarDay,
          sixWeekMonthsEnforced: true,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: HeaderStyle(
            formatButtonShowsNext: false,
            titleTextStyle: DarkTextTheme.captionL,
            formatButtonTextStyle: DarkTextTheme.buttonS,
            titleTextFormatter: (DateTime date, dynamic locale) {
              String dateStr = DateFormat.yMMMM(locale).format(date);
              String weekStr = _selectedWeek.toString();
              return '$dateStr\nвыбрана $weekStr неделя';
            },
            formatButtonDecoration: const BoxDecoration(
                border: const Border.fromBorderSide(
                    BorderSide(color: DarkThemeColors.deactive)),
                borderRadius: const BorderRadius.all(Radius.circular(12.0))),
          ),
          calendarStyle: CalendarStyle(
            rangeHighlightColor: DarkThemeColors.secondary,
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle:
                DarkTextTheme.body.copyWith(color: DarkThemeColors.deactive),
            weekendStyle: DarkTextTheme.body
                .copyWith(color: DarkThemeColors.deactiveDarker),
          ),
          focusedDay: _focusedDay,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Месяц',
            CalendarFormat.twoWeeks: '2 недели',
            CalendarFormat.week: 'Неделя'
          },
          eventLoader: (day) {
            final int week = Calendar.getCurrentWeek(mCurrentDate: day);
            final int weekday = day.weekday - 1;

            var lessons = _getLessonsByWeek(week, widget.schedule);
            if (weekday == 6)
              return [];
            else
              return lessons[weekday];
          },
          locale: 'ru_RU',
          selectedDayPredicate: (day) {
            // Use `selectedDayPredicate` to determine which day is currently selected.
            // If this returns true, then `day` will be marked as selected.

            // Using `isSameDay` is recommended to disregard
            // the time-part of compared DateTime objects.
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              final int currentNewWeek =
                  Calendar.getCurrentWeek(mCurrentDate: selectedDay);
              // Call `setState()` when updating the selected day
              setState(() {
                _setLessonsByWeek(currentNewWeek);
                _selectedPage =
                    selectedDay.difference(_firstCalendarDay).inDays;
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedWeek = currentNewWeek;
                _controller.jumpToPage(_selectedPage);
              });
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              // Call `setState()` when updating calendar format
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            // No need to call `setState()` here
            _focusedDay = focusedDay;
          },
          onHeaderTapped: (date) {
            final currentDate = DateTime.now();
            setState(() {
              _focusedDay = currentDate;
              _selectedDay = currentDate;
              _selectedPage = _selectedDay.difference(_firstCalendarDay).inDays;
              _controller.jumpToPage(_selectedPage);
            });
          },
          onHeaderLongPressed: (date) {
            // set up the AlertDialog
            AlertDialog alert = AlertDialog(
                contentPadding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 8.0),
                backgroundColor: DarkThemeColors.background02,
                title: Text("Выберите неделю"),
                content: Wrap(
                  spacing: 4.0,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment: WrapAlignment.center,
                  children: [
                    for (int i = 1; i <= Calendar.kMaxWeekInSemester; i++)
                      ElevatedButton(
                        child: Text(i.toString()),
                        style: ElevatedButton.styleFrom(
                          primary: DarkThemeColors.primary,
                          onPrimary: Colors.white,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedWeek = i;
                            _selectedDay =
                                Calendar.getDaysInWeek(_selectedWeek)[0];
                            _focusedDay = _selectedDay;
                            _selectedPage = _selectedDay
                                .difference(_firstCalendarDay)
                                .inDays;
                            _allLessonsInWeek = _getLessonsByWeek(
                                _selectedWeek, widget.schedule);
                            _controller.jumpToPage(_selectedPage);
                          });
                        },
                      ),
                  ],
                ));

            // show the dialog
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                });
          },
        ),
        SizedBox(height: 25),
        Expanded(
          child: PageView.builder(
              controller: _controller,
              physics: ClampingScrollPhysics(),
              onPageChanged: (value) {
                setState(() {
                  if (value > _selectedPage)
                    _selectedDay = _selectedDay.add(Duration(days: 1));
                  else if (value < _selectedPage)
                    _selectedDay = _selectedDay.subtract(Duration(days: 1));
                  final int currentNewWeek =
                      Calendar.getCurrentWeek(mCurrentDate: _selectedDay);
                  _focusedDay = _selectedDay;
                  _setLessonsByWeek(currentNewWeek);
                  _selectedPage = value;
                });
              },
              itemCount: _lastCalendarDay.difference(_firstCalendarDay).inDays,
              itemBuilder: (context, index) {
                final DateTime lessonDay =
                    _firstCalendarDay.add(Duration(days: index));
                final int week =
                    Calendar.getCurrentWeek(mCurrentDate: lessonDay);
                final int lessonIndex =
                    week >= 1 && week <= Calendar.kMaxWeekInSemester
                        ? lessonDay.weekday - 1
                        : 6;
                return _buildPageViewContent(context, lessonIndex);
              }),
        )
      ],
    );
  }
}
