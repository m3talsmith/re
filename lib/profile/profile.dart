import 'dart:convert';

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
  String? _name;
  String? _address;
  String? _email;
  String? _phone;

  _saveName(value) {
    setState(() {
      _name = value;
    });
  }

  _saveAddress(value) {
    setState(() {
      _address = value;
    });
  }

  _saveEmail(value) {
    setState(() {
      _email = value;
    });
  }

  _savePhone(value) {
    setState(() {
      _phone = value;
    });
  }

  _saveProfile() {
    Profile profile = Profile()
      ..name = _name
      ..address = _address
      ..email = _email
      ..phone = _phone;
    if (widget.callback != null) widget.callback!(profile);
  }

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      setState(() {
        _address = widget.profile?.address;
        _name = widget.profile?.name;
        _phone = widget.profile?.phone;
        _email = widget.profile?.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextFormField(
          decoration: const InputDecoration(label: Text('Name')),
          onChanged: _saveName,
          onFieldSubmitted: (value) => _saveProfile(),
          initialValue: _name,
        ),
        TextFormField(
          decoration: const InputDecoration(label: Text('Address')),
          onChanged: _saveAddress,
          onFieldSubmitted: (value) => _saveProfile(),
          initialValue: _address,
        ),
        TextFormField(
          decoration: const InputDecoration(label: Text('Email')),
          onChanged: _saveEmail,
          onFieldSubmitted: (value) => _saveProfile(),
          initialValue: _email,
        ),
        TextFormField(
          decoration: const InputDecoration(label: Text('Phone')),
          onChanged: _savePhone,
          onFieldSubmitted: (value) => _saveProfile(),
          initialValue: _phone,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: ElevatedButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save_alt_rounded),
            label: const Text('Save Profile'),
          ),
        )
      ],
    );
  }
}
