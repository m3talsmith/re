import '../companies/model.dart';
import '../skills/model.dart';

class Experience {
  Experience();

  Experience.fromMap(Map<String, dynamic> data) {
    company = Company.fromMap(data['company']);
    roles = (data['roles'] as List<Map<String, dynamic>>).map((e) => Role.fromMap(e)).toList();
  }

  Company? company;
  List<Role>? roles;

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> roleData = [];
    for (Role role in roles ?? []) {
      roleData.add(role.toMap());
    }
    return {
      'company': company?.toMap(),
      'roles': roleData
    };
  }
}

class Role {
  Role();

  Role.fromMap(Map<String, dynamic> data) {
    title = data['title'];
    summary = data['summary'];
    started = DateTime.parse(data['started']);
    ended = DateTime.parse(data['ended']);
    skills = (data['skills'] as List<Map<String, dynamic>>).map((e) => Skill.fromMap(e)).toList();
  }

  String? title;
  String? summary;
  DateTime? started;
  DateTime? ended;
  List<Skill>? skills;

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> skillData = [];
    var sortedSkills = skills?..sort((a, b) => a.started!.compareTo(b.started!));
    for (Skill skill in sortedSkills ?? []) {
      skillData.add(skill.toMap());
    }
    return {
      'title': title,
      'summary': summary,
      'started': started?.toIso8601String(),
      'ended': ended?.toIso8601String(),
      'skills': skillData
    };
  }
}