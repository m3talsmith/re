import 'dart:developer';

import 'package:flutter/material.dart';

import '../companies/model.dart';
import '../skills/model.dart';
import 'model.dart';

class ExperiencePage extends StatefulWidget {
  const ExperiencePage(
      {super.key,
      this.experiences,
      this.skills,
      this.companies,
      this.callback});

  final Function(List<Experience> experiences)? callback;
  final List<Experience>? experiences;
  final List<Skill>? skills;
  final List<Company>? companies;

  @override
  State<StatefulWidget> createState() => _ExperiencePageState();
}

class _ExperiencePageState extends State<ExperiencePage> {
  List<Experience> _experiences = [];

  @override
  void initState() {
    super.initState();
    _experiences = widget.experiences ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return _AddExperience(
                callback: (experience) {
                  Navigator.of(context).pop();
                  setState(() {
                    _experiences.add(experience);
                    if (widget.callback != null) {
                      widget.callback!(_experiences);
                    }
                  });
                },
                cancel: () {
                  Navigator.of(context).pop();
                },
                companies: widget.companies,
                skills: widget.skills,
              );
            },
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: ListView(
        children: [
          ..._experiences.map((e) {
            var size = MediaQuery.of(context).size;
            var yearsStarted = e.roles?.map((e) => e.started?.year).nonNulls ??
                [DateTime.timestamp().year];
            var yearsEnded = e.roles?.map((e) => e.ended?.year);
            var started = yearsStarted
                .reduce((value, element) => element < value ? element : value);
            var ended = yearsEnded?.reduce((value, element) {
              if (element == null) return value;
              if (value == null) return element;
              return element > value ? element : value;
            });
            var title = Row(
              children: [
                Text('$started - '),
                Text(ended == null ? 'Current' : '$ended'),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(e.company?.name ?? 'Unspecified'),
                )
              ],
            );

            var roleNames =
                e.roles?.map((e) => e.title ?? 'Unspecified').toList() ?? [];
            var skillNames = e.roles
                    ?.map((e) {
                      return e.skills
                              ?.map((e) => e.name ?? 'Unspecified')
                              .toList() ??
                          [];
                    })
                    .toList()
                    .reduce((value, element) {
                      for (var v in element) {
                        value.add(v);
                      }
                      return value;
                    }) ??
                [];
            var subtitle = Column(
              children: [
                SizedBox(
                  width: size.width / 2,
                  child: Wrap(
                    children: roleNames
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Chip(
                                label: Text(
                                  e,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                color: WidgetStatePropertyAll(Theme.of(context)
                                    .primaryColor
                                    .withAlpha(20)),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(4.0)),
                SizedBox(
                  width: size.width / 2,
                  child: Wrap(
                    children: skillNames
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Chip(
                                label: Text(
                                  e,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                color: WidgetStatePropertyAll(Theme.of(context)
                                    .primaryColor
                                    .withAlpha(60)),
                              ),
                            ))
                        .toList(),
                  ),
                )
              ],
            );
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        title,
                        Expanded(child: Container()),
                        IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: _EditExperience(
                                      companies: widget.companies,
                                      skills: widget.skills,
                                      cancel: () => Navigator.of(context).pop(),
                                      callback: (experience) {
                                        setState(() {
                                          _experiences.remove(e);
                                          _experiences.add(experience);
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      company: e.company!,
                                      roles: e.roles ?? [],
                                    ),
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.edit_rounded)),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                _experiences.remove(e);
                                if (widget.callback != null) {
                                  widget.callback!(_experiences);
                                }
                              });
                            },
                            icon: const Icon(Icons.delete_forever_rounded))
                      ],
                    ),
                    Row(
                      children: [subtitle],
                    )
                  ],
                ),
              ),
            );
          })
        ],
      ),
    );
  }
}

class _AddExperience extends StatefulWidget {
  const _AddExperience(
      {this.callback, this.cancel, this.companies, this.skills});

  final Function(Experience experience)? callback;
  final Function()? cancel;

  final List<Company>? companies;
  final List<Skill>? skills;

  @override
  State<StatefulWidget> createState() => _AddExperienceState();
}

class _AddExperienceState extends State<_AddExperience> {
  Company? _company;
  final List<Role> _roles = [];

  bool _addingRole = false;
  bool _addingSkill = false;
  final _roleTitle = TextEditingController();
  final _roleSummary = TextEditingController();
  final _roleStarted = TextEditingController();
  final _roleEnded = TextEditingController();
  final _roleSkills = <Skill>{};

  void _clearRole() {
    setState(() {
      _roleTitle.clear();
      _roleSummary.clear();
      _roleStarted.text = DateTime.timestamp().year.toString();
      _roleEnded.clear();
      _roleSkills.clear();
      _addingSkill = false;
    });
  }

  void _initRole() {
    setState(() {
      _addingRole = true;
      _clearRole();
    });
  }

  void _addRole() {
    if (_roleTitle.text.isEmpty) return;
    if (_roleStarted.text.isEmpty) return;
    if (_roleSkills.isEmpty) return;

    Role role = Role()
      ..title = _roleTitle.text
      ..summary = _roleSummary.text
      ..started = DateTime.tryParse(_roleStarted.text)
      ..ended = DateTime.tryParse(_roleEnded.text)
      ..skills = _roleSkills?.toList();
    setState(() {
      _roles.add(role);
      _addingRole = false;
      _clearRole();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Add Experience',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField(
              items: widget.companies
                  ?.map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.name ?? 'Unspecified'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _company = value;
                });
              },
              decoration: const InputDecoration(label: Text('Company')),
            ),
          ),
          if (_roles.isNotEmpty)
            ..._roles.map((e) => ListTile(title: Text(e.title!))),
          if (_addingRole)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Role',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextFormField(
                  controller: _roleTitle,
                  decoration: const InputDecoration(label: Text('Title')),
                ),
                TextFormField(
                  controller: _roleSummary,
                  decoration: const InputDecoration(
                    label: Text('Summary'),
                  ),
                ),
                Wrap(
                  children: _roleSkills.map((e) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Chip(
                            label: Text(e.name!),
                            deleteIcon: const Icon(Icons.remove_rounded),
                            onDeleted: () {
                              setState(() {
                                _roleSkills.remove(e);
                              });
                            },
                          ),
                        );
                      }).toList() ??
                      [],
                ),
                if (_addingSkill)
                  DropdownButtonFormField(
                    items: widget.skills
                        ?.map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.name!),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _roleSkills.add(value!);
                        _addingSkill = false;
                      });
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _addingSkill = true;
                            });
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Skill'))
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).shadowColor.withAlpha(60),
                      width: 2,
                    ),
                  )),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          'Started',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Expanded(child: Container()),
                        Text(_roleStarted.text),
                        IconButton(
                            onPressed: () async {
                              var date = await showDatePicker(
                                  context: context,
                                  firstDate:
                                      DateTime(DateTime.timestamp().year - 50),
                                  lastDate: DateTime.timestamp());
                              setState(() {
                                _roleStarted.text = date?.year.toString() ?? '';
                              });
                            },
                            icon: const Icon(Icons.calendar_month_rounded))
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).shadowColor.withAlpha(60),
                      width: 2,
                    ),
                  )),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          'Ended',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Expanded(child: Container()),
                        Text(_roleEnded.text),
                        IconButton(
                            onPressed: () async {
                              var date = await showDatePicker(
                                  context: context,
                                  firstDate:
                                      DateTime(DateTime.timestamp().year - 50),
                                  lastDate: DateTime.timestamp());
                              setState(() {
                                _roleEnded.text = date?.year.toString() ?? '';
                              });
                            },
                            icon: const Icon(Icons.calendar_month_rounded))
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          _addRole();
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Add Role'),
                      )
                    ],
                  ),
                ),
              ],
            ),
          if (!_addingRole)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _initRole,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Role'),
                )
              ],
            ),
          const Divider(),
          Row(
            children: [
              TextButton.icon(
                onPressed: widget.cancel,
                icon: const Icon(Icons.cancel_rounded),
                label: const Text('Cancel'),
              ),
              Expanded(child: Container()),
              FilledButton.icon(
                onPressed: () {
                  List<String> errors = [];
                  if (_company == null) {
                    errors.add('You must select a company');
                  }
                  if (_roles.isEmpty) {
                    errors.add('You must include at least one role');
                  }
                  if (errors.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Column(children: [
                          Expanded(child: Container()),
                          ...errors.map(
                            (e) => Card(
                              color: Colors.redAccent,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  e,
                                  style: TextStyle(
                                      color: Theme.of(context).canvasColor),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(),
                          ),
                        ]);
                      },
                    );
                    return;
                  }
                  var experience = Experience()
                    ..company = _company
                    ..roles = _roles;
                  widget.callback?.call(experience);
                },
                icon: const Icon(Icons.check_rounded),
                label: const Text('Add Experience'),
              )
            ],
          )
        ],
      ),
    );
  }
}

class _EditExperience extends StatefulWidget {
  const _EditExperience({
    this.callback,
    this.cancel,
    this.companies,
    this.skills,
    required this.company,
    required this.roles,
  });

  final Function(Experience experience)? callback;
  final Function()? cancel;

  final List<Company>? companies;
  final List<Skill>? skills;

  final Company company;
  final List<Role> roles;

  @override
  State<StatefulWidget> createState() => _EditExperienceState();
}

class _EditExperienceState extends State<_EditExperience> {
  late Company _company;
  late final List<Role> _roles;

  @override
  void initState() {
    super.initState();
    _company = widget.company;
    _roles = widget.roles;
  }

  bool _addingRole = false;
  bool _addingSkill = false;
  String? _roleTitle;
  String? _roleSummary;
  DateTime? _roleStarted;
  DateTime? _roleEnded;
  Set<Skill>? _roleSkills;

  void _clearRole() {
    setState(() {
      _roleTitle = null;
      _roleSummary = null;
      _roleStarted = DateTime.timestamp();
      _roleEnded = null;
      _roleSkills = null;
      _addingSkill = false;
    });
  }

  void _initRole() {
    setState(() {
      _addingRole = true;
      _clearRole();
    });
  }

  void _addRole() {
    Role role = Role()
      ..title = _roleTitle
      ..summary = _roleSummary
      ..started = _roleStarted
      ..ended = _roleEnded
      ..skills = _roleSkills?.toList();
    setState(() {
      _roles.add(role);
      _addingRole = false;
      _clearRole();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Edit Experience',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField(
              value: widget.companies!.contains(_company) ? _company : null,
              items: widget.companies
                  ?.map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.name ?? 'Unspecified'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _company = value!;
                });
              },
              decoration: const InputDecoration(label: Text('Company')),
            ),
          ),
          ..._roles.map((e) => ListTile(title: Text(e.title!))),
          if (_addingRole)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Role',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextFormField(
                  decoration: const InputDecoration(label: Text('Title')),
                  onChanged: (value) {
                    setState(() {
                      _roleTitle = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text('Summary'),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _roleSummary = value;
                    });
                  },
                ),
                Wrap(
                  children: _roleSkills?.map((e) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Chip(
                            label: Text(e.name!),
                            deleteIcon: const Icon(Icons.remove_rounded),
                            onDeleted: () {
                              setState(() {
                                _roleSkills?.remove(e);
                              });
                            },
                          ),
                        );
                      }).toList() ??
                      [],
                ),
                if (_addingSkill)
                  DropdownButtonFormField(
                    items: widget.skills
                        ?.map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.name!),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _roleSkills ??= <Skill>{};
                        _roleSkills?.add(value!);
                        _addingSkill = false;
                      });
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _addingSkill = true;
                            });
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Skill'))
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).shadowColor.withAlpha(60),
                      width: 2,
                    ),
                  )),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          'Started',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Expanded(child: Container()),
                        Text(_roleStarted?.year.toString() ?? ''),
                        IconButton(
                            onPressed: () async {
                              var date = await showDatePicker(
                                  context: context,
                                  firstDate:
                                      DateTime(DateTime.timestamp().year - 50),
                                  lastDate: DateTime.timestamp());
                              setState(() {
                                _roleStarted = date;
                              });
                            },
                            icon: const Icon(Icons.calendar_month_rounded))
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).shadowColor.withAlpha(60),
                      width: 2,
                    ),
                  )),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          'Ended',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Expanded(child: Container()),
                        Text(_roleEnded?.year.toString() ?? ''),
                        IconButton(
                            onPressed: () async {
                              var date = await showDatePicker(
                                  context: context,
                                  firstDate:
                                      DateTime(DateTime.timestamp().year - 50),
                                  lastDate: DateTime.timestamp());
                              setState(() {
                                _roleEnded = date;
                              });
                            },
                            icon: const Icon(Icons.calendar_month_rounded))
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _addRole();
                            _addingRole = false;
                          });
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Role'),
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).primaryColor),
                          foregroundColor: WidgetStatePropertyAll(
                              Theme.of(context).canvasColor),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          if (!_addingRole)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _initRole,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Role'),
                )
              ],
            ),
          const Divider(),
          Row(
            children: [
              TextButton.icon(
                onPressed: widget.cancel,
                icon: const Icon(Icons.cancel_rounded),
                label: const Text('Cancel'),
              ),
              Expanded(child: Container()),
              ElevatedButton.icon(
                onPressed: () {
                  List<String> errors = [];
                  if (_roles.isEmpty) {
                    errors.add('You must include at least one role');
                  }
                  if (errors.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Column(children: [
                          Expanded(child: Container()),
                          ...errors.map(
                            (e) => Card(
                              color: Colors.redAccent,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  e,
                                  style: TextStyle(
                                      color: Theme.of(context).canvasColor),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(),
                          ),
                        ]);
                      },
                    );
                    return;
                  }
                  var experience = Experience()
                    ..company = _company
                    ..roles = _roles;
                  if (widget.callback != null) widget.callback!(experience);
                },
                icon: const Icon(Icons.check_rounded),
                label: const Text('Update'),
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(Theme.of(context).primaryColor),
                  foregroundColor:
                      WidgetStatePropertyAll(Theme.of(context).canvasColor),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
