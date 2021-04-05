import 'package:flutter/material.dart';
import 'package:mars/providers/user_roles.dart';
import 'package:mars/screens/usersManagement/user_role_edit_screen.dart';
import 'package:provider/provider.dart';

class UserRoleItem extends StatelessWidget {
  final String id;
  final String name;

  UserRoleItem(this.id, this.name);

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(name),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(UserRoleEditScreen.routeName, arguments: id);
              },
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                try {
                  await Provider.of<UserRoles>(context, listen: false)
                      .deleteRole(name);
                } catch (error) {
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Deleting failed!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
              },
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
