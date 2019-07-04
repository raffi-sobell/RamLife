import "../utils.dart";

import "dart:convert" show JsonUnsupportedObjectError;

import "package:ramaz/data/student.dart";
import "package:ramaz/data/schedule.dart";

const Map<String, dynamic> invalidJson = {
	"this": "is",
	"totally": false
};

void main() => test_suite (
	const {
		"Student": {
			"Equality Test": StudentTester.equalityTest,
			"Factory Test": StudentTester.factoryTest,
			"Periods Test": StudentTester.periodsTest,
			"Homeroom Test": StudentTester.homeroomTest,
		}
	}
);

class StudentTester {
	static const Map<String, dynamic> periodJson = {
		"room": "U501",
		"id": "12345"
	};
	static final List periodListJson = List.filled (11, periodJson);
	static final PeriodData period = PeriodData.fromJson (periodJson);
	static final List<PeriodData> periods = List.filled (11, period);

	static final Map<Letters, Schedule> schedule = {
		Letters.A: Schedule (periods),
		Letters.B: Schedule (periods),
		Letters.C: Schedule (periods),
		Letters.M: Schedule (periods),
		Letters.R: Schedule (periods),
		Letters.E: Schedule (periods),
		Letters.F: Schedule (periods),
	};

	static const String homeroomLocation = "U507";
	static const String homeroom = "UADV-5";

	static final Student student = Student (
		homeroomLocation: homeroomLocation,
		homeroom: homeroom,
		schedule: schedule
	);

	static final Map<String, dynamic> json = {
		"homeroom meeting room": homeroomLocation,
		"homeroom": homeroom,
		"A": periodListJson,
		"B": periodListJson,
		"C": periodListJson,
		"E": periodListJson,
		"F": periodListJson,
		"M": periodListJson,
		"R": periodListJson,
	};

	static final Day day = Day (letter: Letters.B);
	static final Day noSchool = Day (letter: null);

	static Map<Letters, List<PeriodData>>convert(Student student)=> 
		Map.fromEntries(
			student.schedule.entries.map<MapEntry<Letters, List<PeriodData>>>(
				(MapEntry<Letters, Schedule> entry) => MapEntry (
					entry.key,
					entry.value.periods
				)
			)
		);

	static void equalityTest() {
		compare<Student> (
			Student (
				homeroomLocation: homeroomLocation, 
				schedule: schedule, 
				homeroom: homeroom
			),
			student, 
		);
	}

	static void factoryTest() {
		compareDeepMaps<Letters, PeriodData> (
			convert (Student.fromJson (json)), 
			convert (student)
		);
		willThrow<JsonUnsupportedObjectError>(
			() => Student.fromJson (invalidJson)
		);
		willThrow<ArgumentError> (
			() => Student.fromJson (
				const <String, dynamic> {
					"homeroom meeting room": homeroomLocation, 
					"homeroom": "UADV-5",
					"A": null, 
				}
			)
		);
	}

	static void periodsTest() {
		final List<Period> periods = student.getPeriods(day);
		compare<int> (periods.length, 13);
		for (final Period period in periods) {
			if (int.tryParse (period.period) == null) continue;
			compare<String> (period.id, StudentTester.period.id);
		}
		compare<List<Period>> (
			student.getPeriods(noSchool),
			null
		);
	}

	static void homeroomTest() {
		compare<PeriodData> (
			student.getHomeroom(day), 
			PeriodData (
				room: homeroomLocation,
				id: homeroom
			),
		);
		compare<PeriodData> (
			student.getHomeroom(noSchool),
			null
		);
	}
}