import 'package:flutter/material.dart';
import 'package:mars/widgets/app_drawer.dart';

class UsersScreen extends StatelessWidget {
  static const routeName = '/userManagement/users';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Users'),
        ),
        drawer: AppDrawer());
  }
}
