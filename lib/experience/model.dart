import '../companies/model.dart';
import '../skills/model.dart';

class Experience {
  Experience();

  Experience.fromMap(Map<String, dynamic> data) {
    company = Company.fromMap(data['company']);
    roles ??= [];
    for (var role in data['roles'] ?? []) {
      roles!.add(Role.fromMap(role));
    }
  }

  Company? company;
  List<Role>? roles;

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> roleData = [];
    for (Role role in roles ?? []) {
      roleData.add(role.toMap());
    }
    return {'company': company?.toMap(), 'roles': roleData};
  }
}

class Role {
  Role();

  Role.fromMap(Map<String, dynamic> data) {
    title = data['title'] ?? '';
    summary = data['summary'] ?? '';
    started = data['started'] != null ? DateTime.parse(data['started']) : null;
    ended = data['ended'] != null ? DateTime.parse(data['ended']) : null;
    skills ??= [];
    for (var skill in data['skills'] ?? []) {
      skills!.add(Skill.fromMap(skill));
    }
  }

  String? title;
  String? summary;
  DateTime? started;
  DateTime? ended;
  List<Skill>? skills;

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> skillData = [];
    var sortedSkills = skills
      ?..sort((a, b) => a.started!.compareTo(b.started!));
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
