import 'package:flutter/material.dart';

import 'address_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _name;
  AddressModel? _address;
  String? _email;
  String? _phone;

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: [
          const Center(child: Text('Profile')),
          TextFormField(decoration: const InputDecoration(label: Text('Name')),),
          TextFormField(decoration: const InputDecoration(label: Text('Address Line 1')),),
          TextFormField(decoration: const InputDecoration(label: Text('Address Line 2')),),
          TextFormField(decoration: const InputDecoration(label: Text('City')),),
          TextFormField(decoration: const InputDecoration(label: Text('State')),),
          TextFormField(decoration: const InputDecoration(label: Text('Zip Code')),),
          TextFormField(decoration: const InputDecoration(label: Text('Country')),),
          TextFormField(decoration: const InputDecoration(label: Text('Email')),),
          TextFormField(decoration: const InputDecoration(label: Text('Phone')),)
        ],
    );
  }
}