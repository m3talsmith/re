import 'package:flutter/material.dart';
import 'model.dart';

class SkillForm extends StatefulWidget {
  const SkillForm({super.key, this.skill, this.callback, this.cancel});
  final Skill? skill;
  final Function(Skill skill)? callback;
  final Function()? cancel;

  @override
  State<SkillForm> createState() => _SkillFormState();
}

class _SkillFormState extends State<SkillForm> {
  final _nameController = TextEditingController();
  int _level = 0;
  int _started = DateTime.timestamp().year;

  void save() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name is required'),
        ),
      );
      return;
    }
    final skill = Skill(
      name: _nameController.text,
      level: _level,
      started: _started,
    );
    if (widget.callback != null) {
      widget.callback!(skill);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.skill != null) {
      _nameController.text = widget.skill!.name ?? '';
      _level = widget.skill!.level ?? 0;
      _started = widget.skill!.started ?? DateTime.timestamp().year;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final year = DateTime.timestamp().year;
    final items = List.generate(50, (i) => year - i);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.skill != null ? 'Edit Skill' : 'Add Skill',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(label: Text('Name')),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            'Used Since',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        DropdownButtonFormField(
          items: items
              .map((item) =>
                  DropdownMenuItem(value: item, child: Text(item.toString())))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _started = value;
              });
            }
          },
          value: _started,
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
            FilledButton.icon(
              onPressed: () {
                save();
              },
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}
