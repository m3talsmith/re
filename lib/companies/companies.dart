import 'dart:developer';

import 'package:flutter/material.dart';

import 'model.dart';

class CompaniesPage extends StatefulWidget {
  const CompaniesPage({super.key, this.companies, this.callback});

  final Function(List<Company> companies)? callback;
  final List<Company>? companies;

  @override
  State<StatefulWidget> createState() => _CompaniesPageState(companies: companies);
}

class _CompaniesPageState extends State<CompaniesPage> {
  _CompaniesPageState({this.companies});
  
  List<Company>? companies;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ...?companies?.map((e) => Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(e.name ?? ''),
                  Expanded(child: Container()),
                  SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: _EditCompany(
                                  name: e.name!,
                                  callback: (company) {
                                    if (company.name != null && company.name != '') {
                                      Navigator.pop(context);
                                      setState(() {
                                        var i = companies!.indexOf(e);
                                        companies![i] = company;
                                        if (widget.callback != null) {
                                          widget.callback!(companies!);
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
                                companies!.remove(e);
                                if (widget.callback != null) {
                                  widget.callback!(companies!);
                                }
                              });
                            },
                            icon: const Icon(Icons.delete_forever_rounded)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: _AddCompany(
                  callback: (company) {
                    if (company.name != null && company.name != '') {
                      Navigator.pop(context);
                      setState(() {
                        companies ??= [];
                        companies!.add(company);
                        if (widget.callback != null) {
                          widget.callback!(companies!);
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

class _AddCompany extends StatefulWidget {
  const _AddCompany({super.key, this.callback, this.cancel});

  final Function(Company company)? callback;
  final Function()? cancel;

  @override
  State<StatefulWidget> createState() => _AddCompanyState();
}

class _AddCompanyState extends State<_AddCompany> {
  _AddCompanyState({String name=''}) : _name=name;

  String _name = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a Company',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        TextFormField(
          autofocus: true,
          decoration: const InputDecoration(label: Text('Name')),
          initialValue: _name,
          onChanged: (value) {
            setState(() {
              _name = value;
            });
          },
          onFieldSubmitted: (value) {
            setState(() {
              _name = value;
              if (widget.callback != null) {
                widget.callback!(Company(
                  name: _name,
                ));
              }
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
                  widget.callback!(Company(
                    name: _name,
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
        ),
      ],
    );
  }
}

class _EditCompany extends StatefulWidget {
  const _EditCompany({required this.name, this.callback, this.cancel});

  final String name;
  final Function(Company company)? callback;
  final Function()? cancel;

  @override
  State<StatefulWidget> createState() => _EditCompanyState(name: name);
}

class _EditCompanyState extends State<_EditCompany> {
  _EditCompanyState({String name=''}) : _name=name;

  String _name = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edit Company',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        TextFormField(
          autofocus: true,
          decoration: const InputDecoration(label: Text('Name')),
          initialValue: _name,
          onChanged: (value) {
            setState(() {
              _name = value;
            });
          },
          onFieldSubmitted: (value) {
            setState(() {
              _name = value;
              if (widget.callback != null) {
                widget.callback!(Company(
                  name: _name,
                ));
              }
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
                  widget.callback!(Company(
                    name: _name,
                  ));
                }
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Update'),
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
        ),
      ],
    );
  }
}
