import "package:flutter/foundation.dart";
import "schedule.dart";
import "times.dart";

class Student {
	final int id;
	final Map <Letters, Schedule> schedule;
	final Letters homeroomDay;
	final String homeroomMeeting;
	final Map <Letters, String> minchaRooms;

	const Student ({
		@required this.id,
		@required this.schedule,
		@required this.homeroomDay,
		@required this.homeroomMeeting,
		@required this.minchaRooms
	});

	List <Period> getPeriods (Day day) {
		final List <Period> result = [];
		final List <PeriodData> periods = schedule [day.letter].periods;
		final Special special = day.special;
		int periodIndex = 0;
		print (periods);

		for (int index = 0; index < special.periods.length; index++) {
			final Range range = special.periods [index];
			print (periodIndex);
			while ((special?.skip ?? const []).contains(periodIndex + 1)) {
				print ("Skipping $periodIndex");
				periodIndex++;
				break;
			}
			if (special.homeroom == index) {
				result.add (
					Schedule.homeroom (
						range,
						room: getHomeroomMeeting(day)
					)
				); 
			} else if (special.mincha == index) {
				result.add (
					Schedule.mincha (range, minchaRooms [day.letter])
				); 
				print ("Added mincha: $periodIndex");
			} 
			else {
				final PeriodData period = periods [periodIndex];
				if (period == null) print ("AAAAAAA");
				print (period);
				if (period == null) {  // free period
					result.add (
						Period (
							PeriodData (
								room: null,
								id: -1
							),
							period: (periodIndex + 1).toString(),
							time: range,
						)
					);
					print ("Added a free period: $periodIndex");
				} else {
					result.add (
						Period (
							period,
							time: range,
							period: (periodIndex + 1).toString()
						)
					);
				}
				periodIndex++;
			}
		}
		return result;
	}

	String getHomeroomMeeting(Day day) => day.letter == homeroomDay 
		? homeroomMeeting : null;
}