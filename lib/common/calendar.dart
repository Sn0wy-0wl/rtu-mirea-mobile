import 'package:clock/clock.dart';

class Calendar {
  /// Maximum number of academic weeks per semester
  static const int kMaxWeekInSemester = 16;

  /// Returns the current day of the week, where 1 is Mon, 7 is Sun
  static int getCurrentDayOfWeek({final Clock clock = const Clock()}) {
    return clock.now().weekday;
  }

  /// Returns the number of the current week using the current date
  static int getCurrentWeek(
      {DateTime? mCurrentDate, final Clock clock = const Clock()}) {
    DateTime currentDate = mCurrentDate ?? clock.now();
    int currentYear = currentDate.year;

    DateTime startDate;

    if (currentDate.month >= DateTime.september) {
      startDate = DateTime.utc(currentYear, 9, 1);
    } else {
      startDate = DateTime.utc(currentYear, 2, 8);
    }

    int week = 1;
    int prevWeekday = startDate.weekday;

    while (currentDate.difference(startDate).inDays != 0) {
      if (startDate.weekday == 7 && startDate.weekday != prevWeekday) {
        week += 1;
      }
      prevWeekday = startDate.weekday;
      startDate = startDate.add(const Duration(days: 1));
    }

    // int week = ((milliseconds / (24 * 60 * 60 * 1000) / 7) + 1).round();

    return week;
  }

  /// Returns the list of dates by [week] number
  static List<DateTime> getDaysInWeek(int week, [DateTime? mCurrentDate]) {
    List<DateTime> daysInWeek = [];

    DateTime semStart = getSemesterStart(mCurrentDate: mCurrentDate);

    // Понедельник недели начала семестра
    var firstDayOfWeek =
        semStart.subtract(Duration(days: semStart.weekday - 1));

    // Прибавляем сколько дней прошло с начала семестра
    var firstDayOfChosenWeek =
        firstDayOfWeek.add(Duration(days: (week - 1) * 7));

    // Добавляем дни в массив, увеличивая счётчик на 1 день
    for (int i = 0; i < 7; ++i) {
      daysInWeek.add(firstDayOfChosenWeek);
      firstDayOfChosenWeek = firstDayOfChosenWeek.add(Duration(days: 1));
    }
    return daysInWeek;
  }

  /// Get the start date of the semester
  ///
  /// [mCurrentDate] is the date for which
  /// the beginning of the semester will be calculated.
  static DateTime getSemesterStart(
      {DateTime? mCurrentDate, final Clock clock = const Clock()}) {
    return _CurrentSemesterStart.getCurrentSemesterStart(
        mCurrentDate: mCurrentDate, clock: clock);
  }

  /// Get the last date of the semester
  static DateTime getSemesterLastDay(
      {DateTime? mCurrentDate, final Clock clock = const Clock()}) {
    return getDaysInWeek(
            kMaxWeekInSemester,
            _CurrentSemesterStart.getCurrentSemesterStart(
                mCurrentDate: mCurrentDate, clock: clock))
        .last;
  }
}

/// Get the date when the semester begins
class _CurrentSemesterStart {
  /// Get the first Monday of the month from which the current semester begins
  static DateTime _getFirstMondayOfMonth(int year, int month) {
    var firstOfMonth = DateTime(year, month, 1);
    var firstMonday = firstOfMonth.add(
        Duration(days: (7 - (firstOfMonth.weekday - DateTime.monday)) % 7));
    return firstMonday;
  }

  /// Adjust the start date of the semester
  /// If the selected day is a day off, take the first Monday of the month,
  /// Otherwise the selected day is chosen correctly already
  static DateTime _getCorrectedDate(DateTime date) {
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return _getFirstMondayOfMonth(date.year, date.month);
    } else {
      return date;
    }
  }

  /// Get the expected start date of the semester.
  /// For the first semester it is September 1
  /// For the second semester it is February 8th
  static DateTime _getExpectedSemesterStart(DateTime currentDate) {
    if (currentDate.month >= DateTime.september) {
      return DateTime(currentDate.year, DateTime.september, 1);
    } else {
      return DateTime(currentDate.year, DateTime.february, 8);
    }
  }

  /// Get the start date of the current semester
  static DateTime getCurrentSemesterStart(
      {DateTime? mCurrentDate, final Clock clock = const Clock()}) {
    DateTime currentDate = mCurrentDate ?? clock.now();
    // Expected start date of the semester
    DateTime expectedStart = _getExpectedSemesterStart(currentDate);
    // Adjust in case it falls on a day off
    return _getCorrectedDate(expectedStart);
  }
}
