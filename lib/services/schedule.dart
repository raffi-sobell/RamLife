import "package:flutter/foundation.dart";
import "dart:async" show Timer;

import "package:ramaz/services/reader.dart";

import "package:ramaz/data/student.dart";
import "package:ramaz/data/schedule.dart";

typedef NoteSetter = void Function({
	@required String subject, 
	@required String period, 
	@required Letters letter
});

class ScheduleTracker with ChangeNotifier {
	static DateTime now = DateTime.now();

	final Student student;
	final Map<String, Subject> subjects;
	final Map<DateTime, Day> calendar;
	final NoteSetter setNotes;

	Timer timer;
	Day today, currentDay;
	Period period, nextPeriod;
	List<Period> periods;

	int periodIndex;

	ScheduleTracker(
		Reader reader,
		{@required this.setNotes}
	) : 
		subjects = Subject.getSubjects(reader.subjectData),
		student = Student.fromJson(reader.studentData),
		calendar = Day.getCalendar(reader.calendarData) 
	{
		setToday();
	}

	@override 
	void dispose() {
		timer.cancel();
		super.dispose();
	}

	Subject get subject => subjects [period?.id];

	void setToday() {
		// Get rid of the time
		final DateTime currentDate = DateTime.utc(
			now.year, 
			now.month,
			now.day
		); 
		
		today = currentDay = calendar [currentDate];
		if (today.school) {
			periods = student.getPeriods(today);
			onNewPeriod();
			timer?.cancel();
			timer = Timer.periodic(
				const Duration (minutes: 1),
				(Timer timer) => onNewPeriod()
			);
		}
	}

	void onNewPeriod() {
		final DateTime newDate = DateTime.now();
		if (newDate.day != now.day) {
			// Day changed. Probably midnight
			now = newDate;
			return setToday();
		} else if (!today.school) {
			period = nextPeriod = periods = null;
			notifyListeners();
			return;
		}

		// So we have school today...
		periodIndex = today.period;
		if (periodIndex == null) { // School ended
			period = nextPeriod = null;
			notifyListeners();
			return;
		}

		// Only here if there is school right now
		period = periods [periodIndex];
		if (periodIndex < periods.length - 1) 
			nextPeriod = periods [periodIndex + 1];

		setNotes(
			period: period?.period,
			subject: subjects [period?.id]?.name,
			letter: today.letter,
		);
		
		notifyListeners();
	}
}