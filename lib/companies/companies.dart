import 'package:flutter/material.dart';

import 'form.dart';
import 'model.dart';

class CompaniesPage extends StatefulWidget {
  const CompaniesPage({super.key, this.companies, this.callback});

  final Function(List<Company> companies)? callback;
  final List<Company>? companies;

  @override
  State<StatefulWidget> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  List<Company>? companies;

  @override
  void initState() {
    super.initState();
    companies = widget.companies;
  }

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
                            IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: CompanyForm(
                                          company: e,
                                          callback: (company) {
                                            if (company.name != null &&
                                                company.name != '') {
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
                                },
                                icon: const Icon(Icons.edit_rounded)),
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
                child: CompanyForm(
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
