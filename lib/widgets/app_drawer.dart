import 'package:flutter/material.dart';
import 'package:mars/screens/usersManagement/user_roles_screen.dart';
import 'package:mars/screens/usersManagement/users_screen.dart';
import 'package:provider/provider.dart';

import '../screens/orders_screen.dart';
import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> menuItems = [
      MenuItem(Icons.dashboard, 'Dashboard', routeName: '/'),
      MenuItem(Icons.developer_board, 'Components hierarchy',
          routeName: OrdersScreen.routeName),
      MenuItem(Icons.people, 'User Management', expandable: true, nested: [
        MenuItem(Icons.person, 'Users', routeName: UsersScreen.routeName),
        MenuItem(Icons.pan_tool, 'User Roles',
            routeName: UserRolesScreen.routeName),
      ]),
      MenuItem(Icons.exit_to_app, 'Logout', onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed('/');
        Provider.of<Auth>(context, listen: false).logout();
      })
    ].expand((e) => [e, Divider()]).toList();
    return Drawer(
      child: Column(children: <Widget>[AppBar()] + menuItems),
    );
  }

  Color getIconColor(BuildContext context, String routeName) =>
      ModalRoute.of(context).settings.name == routeName
          ? Theme.of(context).accentColor
          : Theme.of(context).primaryColor;
}

class MenuItem extends StatefulWidget {
  final IconData icon;
  final String routeName;
  final String title;
  final bool expandable;
  final List<MenuItem> nested;
  final Function onTap;
  MenuItem(this.icon, this.title,
      {this.routeName, this.expandable = false, this.nested, this.onTap});
  @override
  State<StatefulWidget> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    var column = Column(children: <Widget>[
      ListTile(
          leading: Icon(
            widget.icon,
            color: _getIconColor(context, widget.routeName),
          ),
          title: Text(widget.title),
          onTap: () {
            if (widget.expandable) {
              setState(() {
                _expanded = !_expanded;
              });
            } else {
              if (widget.onTap == null) {
                Navigator.of(context).pushReplacementNamed(widget.routeName);
              } else {
                widget.onTap();
              }
            }
          },
          trailing: widget.expandable
              ? IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                )
              : null),
    ]);
    if (widget.expandable) {
      column.children.add(AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          height: _expanded ? widget.nested.length * 60.0 : 0,
          child: ListView(
              children: widget.nested
                  .expand((element) => [element, Divider()])
                  .take(widget.nested.length * 2 - 1)
                  .toList())));
    }
    return column;
  }

  Color _getIconColor(BuildContext context, String routeName) =>
      ModalRoute.of(context).settings.name == routeName
          ? Theme.of(context).accentColor
          : Theme.of(context).primaryColor;
}
