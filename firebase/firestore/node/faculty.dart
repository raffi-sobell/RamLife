import "package:firestore/data.dart";
import "package:firestore/helpers.dart";
import "package:firestore/faculty.dart";
import "package:firestore/sections.dart";
import "package:firestore/services.dart";
import "package:firestore/students.dart";

Future<void> main() async {
	Args.initLogger("Indexing data...");

	final Map<String, Student> faculty = await Logger.logValue(
		"faculty objects", FacultyReader.getFaculty,
	);

	final Map<String, String> sectionTeachers = await Logger.logValue(
		"section teachers", () => SectionReader.getSectionTeachers(id: true)
	);

	final Map<Student, Set<String>> facultySections = await Logger.logValue(
		"faculty sections", () => FacultyLogic.getFacultySections(
			teachers: faculty,
			sectionTeachers: sectionTeachers,
		)
	);

	final Map<String, List<Period>> periods = await Logger.logValue(
		"periods", StudentReader.getPeriods,
	);

	final List<Student> facultyWithSchedule = await Logger.logValue(
		"faculty with schedule", () => FacultyLogic.getFacultyWithSchedule(
			teacherSections: facultySections,
			sectionPeriods: periods,
		)
	);

	Logger.info("Finished data indexing.");

	if (Args.upload) {
		await Logger.logProgress(
			"data upload", () => Firestore.upoadStudents(facultyWithSchedule)
		);
	}
	await app.delete();
	Logger.info("Processed ${facultyWithSchedule.length} faculty");
}
