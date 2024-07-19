import 'package:flutter/material.dart';
import 'package:medipal/Individual/appoinment_dependet_screen.dart';
import 'package:medipal/Individual/gaurdian_view_screen.dart';
import 'package:medipal/Individual/inventory_dependet_guardian.dart';

class TabChange extends StatefulWidget {
  final dependentId;

  const TabChange({required this.dependentId});

  @override
  _TabChangeState createState() => _TabChangeState();
}

class _TabChangeState extends State<TabChange> {
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      GaurdianView(dependentId: widget.dependentId),
      InventoryDependentGuardian(dependentId: widget.dependentId),
      AppointmentGaurdianScreen(dependentId:  widget.dependentId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color.fromARGB(255, 0, 0, 0)),
            // Customize back button
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          bottom: const TabBar(
            labelColor: Color.fromRGBO(41, 45, 92, 1.0),
            tabs: [
              Tab(
                icon: Icon(
                  Icons.home,
                  color: Color.fromRGBO(41, 45, 92, 1.0),
                ),
                text: 'Home',
              ),
              Tab(
                icon: Icon(
                  Icons.favorite,
                  color: Color.fromRGBO(41, 45, 92, 1.0),
                ),
                text: 'Inventory',
              ),
              Tab(
                icon: Icon(
                  Icons.medical_information,
                  color: Color.fromRGBO(41, 45, 92, 1.0),
                ),
                text: 'Appoinment',
              )
            ],
          ),
        ),
        body: TabBarView(
          children: _tabs,
        ),
      ),
    );
  }
}
