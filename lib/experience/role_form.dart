import 'package:flutter/material.dart';

import '../skills/model.dart';
import 'model.dart';

class RoleForm extends StatefulWidget {
  const RoleForm(
      {super.key,
      this.role,
      this.skills = const [],
      this.callback,
      this.cancel});

  final Role? role;
  final List<Skill> skills;
  final Function(Role role)? callback;
  final Function()? cancel;

  @override
  State<RoleForm> createState() => _RoleFormState();
}

class _RoleFormState extends State<RoleForm> {
  final _roleTitle = TextEditingController();
  final _roleSummary = TextEditingController();
  final _roleStarted = TextEditingController();
  final _roleEnded = TextEditingController();
  final _roleSkills = <Skill>{};

  void _save() {
    if (_roleTitle.text.isEmpty) return;
    if (_roleStarted.text.isEmpty) return;
    if (_roleSkills.isEmpty) return;

    Role role = Role()
      ..title = _roleTitle.text
      ..summary = _roleSummary.text
      ..started = DateTime.tryParse(_roleStarted.text)
      ..ended = DateTime.tryParse(_roleEnded.text)
      ..skills = _roleSkills.toList();

    widget.callback?.call(role);
  }

  @override
  void initState() {
    super.initState();
    if (widget.role != null) {
      _roleTitle.text = widget.role!.title!;
      _roleSummary.text = widget.role!.summary!;
      _roleStarted.text = widget.role!.started!.year.toString();
      _roleEnded.text = widget.role!.ended!.year.toString();
      _roleSkills.addAll(widget.role!.skills!);
    }
  }

  @override
  void dispose() {
    _roleTitle.dispose();
    _roleSummary.dispose();
    _roleStarted.dispose();
    _roleEnded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.role == null ? 'Add a Role' : 'Edit Role',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Divider(),
        TextFormField(
          controller: _roleTitle,
          decoration: const InputDecoration(label: Text('Title')),
          autofocus: true,
        ),
        TextFormField(
          controller: _roleSummary,
          decoration: const InputDecoration(label: Text('Summary')),
        ),
        Wrap(
          children: _roleSkills
              .map((e) => Chip(
                    label: Text(e.name!),
                    deleteIcon: const Icon(Icons.remove_rounded),
                    onDeleted: () {
                      setState(() {
                        _roleSkills.remove(e);
                      });
                    },
                  ))
              .toList(),
        )
      ],
    );
  }
}
