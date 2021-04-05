import 'package:flutter/material.dart';
import 'package:mars/providers/user_roles.dart';
import 'package:mars/widgets/app_drawer.dart';
import 'package:mars/widgets/user_role_item.dart';
import 'package:provider/provider.dart';

import 'user_role_edit_screen.dart';

class UserRolesScreen extends StatelessWidget {
  static const routeName = '/userManagement/userRoles';

  Future<void> _refreshRoles(BuildContext context) async {
    await Provider.of<UserRoles>(context, listen: false).fetchAndSetRoles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Roles'),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(UserRoleEditScreen.routeName);
                  }))
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshRoles(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshRoles(context),
                    child: Consumer<UserRoles>(
                      builder: (ctx, rolesData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: rolesData.roles.length,
                          itemBuilder: (_, i) => Column(
                            children: [
                              UserRoleItem(
                                rolesData.roles[i].id,
                                rolesData.roles[i].name,
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
