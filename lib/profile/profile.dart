import 'package:flutter/material.dart';

import 'model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.profile, this.callback});

  final Profile? profile;
  final Function(Profile profile)? callback;

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  void _saveProfile() {
    Profile profile = Profile()
      ..name = _nameController.text
      ..address = _addressController.text
      ..email = _emailController.text
      ..phone = _phoneController.text;
    if (widget.callback != null) widget.callback!(profile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved')),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      setState(() {
        _addressController.text = widget.profile?.address ?? '';
        _nameController.text = widget.profile?.name ?? '';
        _phoneController.text = widget.profile?.phone ?? '';
        _emailController.text = widget.profile?.email ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextFormField(
          decoration: const InputDecoration(label: Text('Name')),
          onFieldSubmitted: (value) => _saveProfile(),
          controller: _nameController,
        ),
        TextFormField(
          decoration: const InputDecoration(label: Text('Address')),
          onFieldSubmitted: (value) => _saveProfile(),
          controller: _addressController,
        ),
        TextFormField(
          decoration: const InputDecoration(label: Text('Email')),
          onFieldSubmitted: (value) => _saveProfile(),
          controller: _emailController,
        ),
        TextFormField(
          decoration: const InputDecoration(label: Text('Phone')),
          onFieldSubmitted: (value) => _saveProfile(),
          controller: _phoneController,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: FilledButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save_alt_rounded),
            label: const Text('Save Profile'),
          ),
        )
      ],
    );
  }
}
