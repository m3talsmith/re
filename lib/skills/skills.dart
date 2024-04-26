import 'package:flutter/material.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key, this.skills, this.callback});

  final Function(List<Skill> skills)? callback;
  final List<Skill>? skills;

  @override
  State<StatefulWidget> createState() => _SkillsPageState(skills: skills);
}

class _SkillsPageState extends State<SkillsPage> {
  _SkillsPageState({this.skills});

  List<Skill>? skills;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ...?skills?.map((e) {
            int year = DateTime.timestamp().year;
            int diff = year-(e.started ?? 0);
            return ListTile(
              leading: SizedBox(width: 60, child: Text('$diff ${diff != 1 ? "years" : "year"}',)),
              title: Text(e.name ?? ''),
              subtitle: LinearProgressIndicator(value: e.level!.toDouble()/10.0,),
              trailing: SizedBox(
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(onPressed: () {
                      showBottomSheet(
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: _EditSkill(
                              name: e.name!,
                              started: e.started!,
                              level: e.level!,
                              callback: (skill) {
                                if (skill.name != null && skill.name != '') {
                                  Navigator.pop(context);
                                  setState(() {
                                    var i = skills!.indexOf(e);
                                    skills![i] = skill;
                                    if (widget.callback != null) {
                                      widget.callback!(skills!);
                                    }
                                  });
                                }
                              },
                              cancel: () {
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      );
                    }, icon: const Icon(Icons.edit_rounded)),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            skills!.remove(e);
                            if (widget.callback != null) {
                              widget.callback!(skills!);
                            }
                          });
                        },
                        icon: const Icon(Icons.delete_forever_rounded)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheet(
            context: context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: _AddSkill(
                  callback: (skill) {
                    if (skill.name != null && skill.name != '') {
                      Navigator.pop(context);
                      setState(() {
                        skills ??= [];
                        skills!.add(skill);
                        if (widget.callback != null) {
                          widget.callback!(skills!);
                        }
                      });
                    }
                  },
                  cancel: () {
                    Navigator.pop(context);
                  },
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _AddSkill extends StatefulWidget {
  const _AddSkill({super.key, this.callback, this.cancel});

  final Function(Skill skill)? callback;
  final Function()? cancel;

  @override
  State<StatefulWidget> createState() => _AddSkillState();
}

class _AddSkillState extends State<_AddSkill> {
  String _name = "";
  int _started = DateTime.timestamp().year;
  int _level = 0;

  @override
  Widget build(BuildContext context) {
    var year = DateTime.timestamp().year;
    var items = List.generate(50, (i) => year - i);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a Skill',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        TextFormField(
          decoration: const InputDecoration(label: Text('Name')),
          initialValue: _name,
          onChanged: (value) {
            setState(() {
              _name = value;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            'Used Since',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        DropdownButtonFormField<int>(
          value: _started,
          items: items
              .map((e) => DropdownMenuItem<int>(
                    value: e,
                    child: Text(e.toString()),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _started = value!;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            'Comfort Level',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Slider(
          min: 0,
          max: 10,
          value: _level.toDouble(),
          onChanged: (value) {
            setState(() {
              _level = value.toInt();
            });
          },
        ),
        const Divider(),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                if (widget.cancel != null) widget.cancel!();
              },
              icon: const Icon(Icons.cancel_rounded),
              label: const Text('Cancel'),
            ),
            Expanded(child: Container()),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.callback != null) {
                  widget.callback!(Skill(
                    name: _name,
                    level: _level,
                    levelModifier: 0,
                    started: _started,
                  ));
                }
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Add'),
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Theme.of(context).primaryColor,
                ),
                foregroundColor: MaterialStatePropertyAll(
                  Theme.of(context).canvasColor,
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}

class _EditSkill extends StatefulWidget {
  const _EditSkill({super.key, required this.name, required this.started, required this.level, this.callback, this.cancel});

  final String name;
  final int started;
  final int level;
  
  final Function(Skill skill)? callback;
  final Function()? cancel;

  @override
  State<StatefulWidget> createState() => _EditSkillState(name: name, started: started, level: level);
}

class _EditSkillState extends State<_EditSkill> {
  _EditSkillState({required String name, required int started, required level}) : _name=name, _started=started, _level=level;
  
  String _name = '';
  int _started = DateTime.timestamp().year;
  int _level = 0;

  @override
  Widget build(BuildContext context) {
    var year = DateTime.timestamp().year;
    var items = List.generate(50, (i) => year - i);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a Skill',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        TextFormField(
          decoration: const InputDecoration(label: Text('Name')),
          initialValue: _name,
          onChanged: (value) {
            setState(() {
              _name = value;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            'Used Since',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        DropdownButtonFormField<int>(
          value: _started,
          items: items
              .map((e) => DropdownMenuItem<int>(
            value: e,
            child: Text(e.toString()),
          ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _started = value!;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            'Comfort Level',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Slider(
          min: 0,
          max: 10,
          value: _level.toDouble(),
          onChanged: (value) {
            setState(() {
              _level = value.toInt();
            });
          },
        ),
        const Divider(),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                if (widget.cancel != null) widget.cancel!();
              },
              icon: const Icon(Icons.cancel_rounded),
              label: const Text('Cancel'),
            ),
            Expanded(child: Container()),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.callback != null) {
                  widget.callback!(Skill(
                    name: _name,
                    level: _level,
                    levelModifier: 0,
                    started: _started,
                  ));
                }
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Add'),
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Theme.of(context).primaryColor,
                ),
                foregroundColor: MaterialStatePropertyAll(
                  Theme.of(context).canvasColor,
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}

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
