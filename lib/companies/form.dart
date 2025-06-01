import 'package:flutter/material.dart';

import 'model.dart';

class CompanyForm extends StatefulWidget {
  const CompanyForm({this.callback, this.cancel, this.company});

  final Function(Company company)? callback;
  final Function()? cancel;
  final Company? company;

  @override
  State<CompanyForm> createState() => _CompanyFormState();
}

class _CompanyFormState extends State<CompanyForm> {
  final _nameController = TextEditingController();

  void _save() {
    if (_nameController.text.isEmpty) {
      return;
    }
    if (widget.callback != null) {
      widget.callback!(Company(name: _nameController.text));
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.company?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.company == null ? 'Add a Company' : 'Edit Company',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        TextFormField(
          autofocus: true,
          controller: _nameController,
          decoration: const InputDecoration(label: Text('Name')),
          onFieldSubmitted: (value) => _save(),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
                onPressed: () {
                  widget.cancel != null
                      ? widget.cancel!()
                      : Navigator.pop(context);
                },
                icon: const Icon(Icons.cancel_rounded),
                label: const Text('Cancel')),
            FilledButton.icon(
                onPressed: () => _save(),
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save')),
          ],
        )
      ],
    );
  }
}
