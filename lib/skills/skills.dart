import 'package:flutter/material.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key, this.skills, this.callback});

  final Function(List<Skill> skill)? callback;
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
          ...?skills?.map((skill) {
            int year = DateTime.timestamp().year;
            int diff = year-(skill.started ?? 0);
            return ListTile(
              leading: Text('$diff ${diff != 1 ? "years" : "year"}'),
              title: Text(skill.name ?? ''),
              subtitle: LinearProgressIndicator(value: skill.level!.toDouble()/10.0,),
              trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      skills!.remove(skill);
                      if (widget.callback != null) {
                        widget.callback!(skills!);
                      }
                    });
                  },
                  icon: const Icon(Icons.delete_forever_rounded)),
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
