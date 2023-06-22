import 'package:filcnaplo/api/providers/user_provider.dart';
import 'package:filcnaplo_kreta_api/models/absence.dart';
import 'package:filcnaplo_kreta_api/models/grade.dart';
import 'package:filcnaplo_kreta_api/models/subject.dart';
import 'package:filcnaplo_kreta_api/providers/absence_provider.dart';
import 'package:filcnaplo_kreta_api/providers/grade_provider.dart';
import 'package:filcnaplo_kreta_api/providers/homework_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllSumBody extends StatefulWidget {
  const AllSumBody({Key? key}) : super(key: key);

  @override
  _AllSumBodyState createState() => _AllSumBodyState();
}

class _AllSumBodyState extends State<AllSumBody> {
  late UserProvider user;
  late GradeProvider gradeProvider;
  late HomeworkProvider homeworkProvider;
  late AbsenceProvider absenceProvider;
  //late TimetableProvider timetableProvider;
  late Map<String, Map<String, dynamic>> things = {};
  late List<Widget> firstSixTiles = [];
  late List<Widget> lastSixTiles = [];

  int avgDropValue = 0;

  List<Grade> getSubjectGrades(Subject subject, {int days = 0}) => gradeProvider
      .grades
      .where((e) =>
          e.subject == subject &&
          e.type == GradeType.midYear &&
          (days == 0 ||
              e.date.isBefore(DateTime.now().subtract(Duration(days: days)))))
      .toList();

  @override
  void initState() {
    super.initState();

    gradeProvider = Provider.of<GradeProvider>(context, listen: false);
    homeworkProvider = Provider.of<HomeworkProvider>(context, listen: false);
    absenceProvider = Provider.of<AbsenceProvider>(context, listen: false);
    //timetableProvider = Provider.of<TimetableProvider>(context, listen: false);
  }

  void getGrades() {
    var allGrades = gradeProvider.grades;
    var testsGrades = gradeProvider.grades.where((a) => a.value.weight == 100);
    var closingTestsGrades =
        gradeProvider.grades.where((a) => a.value.weight >= 200);

    things.addAll({
      'tests': {'name': 'dolgozat', 'value': testsGrades.length},
      'closingTests': {'name': 'témazáró', 'value': closingTestsGrades.length},
      'grades': {'name': 'jegy', 'value': allGrades.length}
    });
  }

  void getHomework() {
    var allHomework = homeworkProvider.homework;

    things.addAll({
      'homework': {'name': 'házi', 'value': allHomework.length}
    });
  }

  void getSubjects() {
    var allSubjects = gradeProvider.grades
        .map((e) => e.subject)
        .toSet()
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    //var totalLessons;
    var totalLessons = 0;

    things.addAll({
      'subjects': {'name': 'tantárgy', 'value': allSubjects.length},
      'lessons': {'name': 'óra', 'value': totalLessons}
    });
  }

  void getAbsences() {
    var allAbsences = absenceProvider.absences.where((a) => a.delay == 0);
    var excusedAbsences = absenceProvider.absences
        .where((a) => a.state == Justification.excused && a.delay == 0);
    var unexcusedAbsences = absenceProvider.absences.where((a) =>
        (a.state == Justification.unexcused ||
            a.state == Justification.pending) &&
        a.delay == 0);

    things.addAll({
      'absences': {'name': 'hiányzás', 'value': allAbsences.length},
      'excusedAbsences': {'name': 'igazolt', 'value': excusedAbsences.length},
      'unexcusedAbsences': {
        'name': 'igazolatlan',
        'value': unexcusedAbsences.length
      }
    });
  }

  void getDelays() {
    var allDelays = absenceProvider.absences.where((a) => a.delay > 0);
    var totalDelayTime = (allDelays.map((a) {
      return a.delay;
    }).toList())
        .reduce((a, b) => a + b);
    var unexcusedDelays = absenceProvider.absences
        .where((a) => a.state == Justification.unexcused && a.delay > 0);

    things.addAll({
      'delays': {'name': 'késés', 'value': allDelays.length},
      'totalDelay': {'name': 'perc', 'value': totalDelayTime},
      'unexcusedDelays': {
        'name': 'igazolatlan',
        'value': unexcusedDelays.length
      }
    });
  }

  void getEverything() {
    getGrades();
    getHomework();
    getSubjects();
    getAbsences();
    getDelays();
  }

  void generateTiles() {
    for (var i in things.values) {
      Widget w = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            i.values.toList()[1].toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 36.0,
              color: Colors.white,
            ),
          ),
          Text(
            i.values.toList()[0],
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.white,
            ),
          ),
        ],
      );

      // TODO: az orakat es a hazikat szarul keri le, de majd meg lesz csinalva
      if (firstSixTiles.length < 6) {
        firstSixTiles.add(w);
      } else if (lastSixTiles.length < 6) {
        lastSixTiles.add(w);
      } else {
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    getEverything();
    generateTiles();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 45,
        ),
        SizedBox(
          height: 250,
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 0,
            crossAxisSpacing: 5,
            children: firstSixTiles,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        SizedBox(
          height: 250,
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 0,
            crossAxisSpacing: 5,
            children: lastSixTiles,
          ),
        ),
      ],
    );
  }
}