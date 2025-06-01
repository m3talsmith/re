import 'package:flutter/material.dart';

import 'form.dart';
import 'model.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key, this.skills, this.callback});

  final Function(List<Skill> skills)? callback;
  final List<Skill>? skills;

  @override
  State<StatefulWidget> createState() => _SkillsPageState(skills: skills);
}

class _SkillsPageState extends State<SkillsPage> {
  _SkillsPageState({List<Skill>? skills}) : _skills = skills;

  List<Skill>? _skills;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ...?_skills?.map((e) {
            int year = DateTime.timestamp().year;
            int diff = year - (e.started ?? 0);
            return ListTile(
              leading: SizedBox(
                  width: 60,
                  child: Text(
                    '$diff ${diff != 1 ? "years" : "year"}',
                  )),
              title: Text(e.name ?? ''),
              subtitle: LinearProgressIndicator(
                value: e.level!.toDouble() / 10.0,
              ),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: SkillForm(
                                  skill: e,
                                  callback: (skill) {
                                    if (skill.name != null &&
                                        skill.name != '') {
                                      setState(() {
                                        _skills!.remove(e);
                                        _skills!.add(skill);
                                        if (widget.callback != null) {
                                          widget.callback!(_skills!.toList());
                                        }
                                        Navigator.of(context).pop();
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
                        icon: const Icon(Icons.edit_rounded)),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _skills!.remove(e);
                            if (widget.callback != null) {
                              widget.callback!(_skills!.toList());
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
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: SkillForm(
                  callback: (skill) {
                    if (_skills != null &&
                        _skills!
                            .map((e) => e.name?.toLowerCase())
                            .contains(skill.name?.toLowerCase())) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${skill.name} already exists')));
                      return;
                    }
                    setState(() {
                      _skills!.add(skill);
                      if (widget.callback != null) {
                        widget.callback!(_skills!.toList());
                      }
                      Navigator.pop(context);
                    });
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
