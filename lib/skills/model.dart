class Skill {
  Skill({this.name, this.level, this.levelModifier, this.started});

  Skill.fromMap(Map<String, dynamic> data) {
    name = data['name'];
    level = data['level'];
    levelModifier = data['level_modifier'];
    started = data['started'];
  }

  String? name;
  int? level;
  int? levelModifier;
  int? started;

  Map<String, dynamic> toMap() => {
    'name': name,
    'level': level,
    'level_modifier': levelModifier,
    'started': started,
  };
}