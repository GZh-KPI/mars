import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'package:mars/providers/user_role.dart';
import 'package:mars/providers/user_roles.dart';
import 'package:provider/provider.dart';

class UserRoleEditScreen extends StatefulWidget {
  static const routeName = '/userManagement/userRoles/edit';

  @override
  State<StatefulWidget> createState() => _UserRoleEditScreenState();
}

class _UserRoleEditScreenState extends State<UserRoleEditScreen> {
  final _permissionsFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedRole = UserRole(id: null, name: '', permissions: []);
  var _initValues = {
    'name': '',
    'permissions': List<Permission>.empty(growable: true)
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final roleID = ModalRoute.of(context).settings.arguments as String;
      if (roleID != null) {
        _editedRole =
            Provider.of<UserRoles>(context, listen: false).findById(roleID);
        _initValues = {
          'name': _editedRole.name,
          'permissions': _editedRole.permissions
        };
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _permissionsFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedRole.id != null) {
      await Provider.of<UserRoles>(context, listen: false)
          .updateRole(_editedRole.id, _editedRole);
    } else {
      try {
        await Provider.of<UserRoles>(context, listen: false)
            .addRole(_editedRole);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              TextButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  var permissionsStub = [
    Permission(
        type: PermissionType.Access,
        value: "/dashboard",
        displayText: "Dashboard",
        includes: [
          Permission(
              type: PermissionType.View,
              value: "/dashboard/view",
              displayText: "Dashboard View"),
          Permission(
              type: PermissionType.Edit,
              value: "/dashboard/edit",
              displayText: "Dashboard Edit")
        ]),
    Permission(
        type: PermissionType.Access,
        value: "/componentsHierarchy",
        displayText: "Components Hierarchy",
        includes: [
          Permission(
              type: PermissionType.View,
              value: "/componentsHierarchy/view",
              displayText: "Components Hierarchy View"),
          Permission(
              type: PermissionType.Edit,
              value: "/componentsHierarchy/edit",
              displayText: "Components Hierarchy Edit")
        ]),
    Permission(
        type: PermissionType.Access,
        value: "/userManagement",
        displayText: "User Management",
        includes: [
          Permission(
              type: PermissionType.View,
              value: "/userManagement/view",
              displayText: "User Management View",
              includes: [
                Permission(
                    type: PermissionType.View,
                    value: "/userManagement/users/view",
                    displayText: "Users View"),
                Permission(
                    type: PermissionType.View,
                    value: "/userManagement/userRoles/view",
                    displayText: "User Roles View"),
              ]),
          Permission(
              type: PermissionType.Edit,
              value: "/userManagement/edit",
              displayText: "User Management Edit",
              includes: [
                Permission(
                    type: PermissionType.Edit,
                    value: "/userManagement/users/edit",
                    displayText: "Users Edit"),
                Permission(
                    type: PermissionType.Edit,
                    value: "/userManagement/userRoles/edit",
                    displayText: "User Roles Edit")
              ])
        ])
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_editedRole.id == null ? 'Add User Role' : 'Edit User Role'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _form,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        initialValue: _initValues['name'],
                        decoration: InputDecoration(labelText: 'Name'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_permissionsFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a value.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedRole = UserRole(
                              id: _editedRole.id,
                              name: value,
                              permissions: _editedRole.permissions);
                        },
                      ),
                      PermissionsTreeFormField(
                        initialValue: _initValues['permissions'],
                        seed: List.from(permissionsStub),
                        onSaved: (value) {
                          _editedRole = UserRole(
                              id: _editedRole.id,
                              name: _editedRole.name,
                              permissions: value);
                        },
                      )
                    ],
                  ))),
    );
  }
}

class PermissionsTreeFormField extends FormField<List<Permission>> {
  PermissionsTreeFormField(
      {@required FormFieldSetter<List<Permission>> onSaved,
      FormFieldValidator<List<Permission>> validator,
      @required List<Permission> initialValue,
      @required List<Permission> seed,
      AutovalidateMode autoValidateMode = AutovalidateMode.disabled})
      : super(
            autovalidateMode: autoValidateMode,
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<List<Permission>> state) {
              return Expanded(
                  child: Container(
                      child: PermissionsTree(
                          onSelectedChanged: (selection) {
                            state.didChange(selection);
                          },
                          permissions: seed,
                          selectedPermissions: initialValue)));
            });
}

class PermissionsTree extends StatefulWidget {
  final Function(List<Permission>) onSelectedChanged;
  final List<Permission> permissions;
  final List<Permission> selectedPermissions;
  List<Permission> permissionsFlattened;
  PermissionsTree(
      {@required this.onSelectedChanged,
      @required this.permissions,
      @required this.selectedPermissions}) {
    permissionsFlattened = List<Permission>.empty(growable: true);
    for (var p in permissions) {
      permissionsFlattened.addAll(getAllNested(p) + [p]);
    }
  }
  @override
  _PermissionsTreeState createState() => _PermissionsTreeState();

  List<Permission> getAllNested(Permission permission) {
    if (permission.includes == null || permission.includes.isEmpty) {
      return [];
    }
    return permission.includes +
        permission.includes.expand((e) => getAllNested(e)).toList();
  }
}

class _PermissionsTreeState extends State<PermissionsTree> {
  TreeViewController controller;
  List<Permission> selectedPermissions;

  @override
  void initState() {
    selectedPermissions = widget.selectedPermissions;
    controller = TreeViewController(
        children: widget.permissions
            .map((permission) => _mapPermission(permission))
            .toList());
    super.initState();
  }

  void _expandNode(String key, bool expanded) {
    Node node = controller.getNode(key);
    if (node != null) {
      var updated =
          controller.updateNode(key, node.copyWith(expanded: expanded));
      setState(() {
        controller = controller.copyWith(children: updated);
      });
    }
  }

  Node<Permission> _mapPermission(Permission permission) {
    return Node<Permission>(
        key: permission.value,
        label: permission.displayText,
        data: permission,
        icon: NodeIcon(codePoint: getIconCode(selectedPermissions, permission)),
        children: permission.includes != null
            ? permission.includes.map((e) => _mapPermission(e)).toList()
            : []);
  }

  int getIconCode(List<Permission> selected, Permission permission) {
    if (((permission.includes == null || permission.includes.isEmpty) &&
            _isSelected(selected, permission)) ||
        _allNestedSelected(permission, selected)) {
      return Icons.check_box_rounded.codePoint;
    } else if (_isAnyNestedSelected(permission, selected)) {
      return Icons.check_box_outlined.codePoint;
    } else {
      return Icons.check_box_outline_blank.codePoint;
    }
  }

  bool _isSelected(List<Permission> selection, Permission permission) {
    return selection.any((s) => s.value == permission.value);
  }

  bool _isAnyNestedSelected(Permission permission, List<Permission> selected) =>
      permission.includes != null &&
      permission.includes.isNotEmpty &&
      permission.includes.fold(
          permission.includes.any((i) => _isSelected(selected, i)),
          (anySelected, nestedPerm) =>
              anySelected || _isAnyNestedSelected(nestedPerm, selected));
  bool _allNestedSelected(Permission permission, List<Permission> selected) =>
      permission.includes != null &&
      permission.includes.isNotEmpty &&
      widget.getAllNested(permission).every((p) => _isSelected(selected, p));

  Permission _getParent(Permission permission) =>
      widget.permissionsFlattened.firstWhere(
          (p) =>
              p.includes != null &&
              p.includes.isNotEmpty &&
              p.includes.contains(permission),
          orElse: () => null);

  List<Permission> _getAllParents(Permission permission, List<Permission> acc) {
    var currP = _getParent(permission);
    if (currP == null) {
      return acc;
    } else {
      acc.add(currP);
      return _getAllParents(currP, acc);
    }
  }

  List<Permission> _getParentsToRemove(
      Permission permission, List<Permission> toRemove) {
    var parent = _getParent(permission);
    if (parent == null) {
      return toRemove;
    }
    if (!_isAnyNestedSelected(parent,
        selectedPermissions.where((sp) => !toRemove.contains(sp)).toList())) {
      toRemove.add(parent);
    }
    return _getParentsToRemove(parent, toRemove);
  }

  @override
  Widget build(BuildContext context) {
    return TreeView(
        allowParentSelect: true,
        supportParentDoubleTap: false,
        controller: controller,
        theme: TreeViewTheme(
          expanderTheme: ExpanderThemeData(
            type: ExpanderType.caret,
            modifier: ExpanderModifier.none,
            position: ExpanderPosition.end,
            color: Colors.pinkAccent,
            size: 20,
          ),
          labelStyle: Theme.of(context).textTheme.bodyText1,
          parentLabelStyle: Theme.of(context).textTheme.bodyText2,
          iconTheme: IconThemeData(
            size: 18,
            color: Colors.blueGrey,
          ),
          colorScheme: ColorScheme.light(),
        ),
        onNodeTap: (key) {
          setState(() {
            var alreadySelected = selectedPermissions
                .firstWhere((p) => p.value == key, orElse: () => null);
            if (alreadySelected == null) {
              var permission = controller.getNode(key).data as Permission;
              selectedPermissions.add(permission);
              var toAdd = widget.getAllNested(permission);
              toAdd += _getAllParents(permission, toAdd);
              if (toAdd.isNotEmpty) {
                selectedPermissions.addAll(
                    toAdd.where((n) => !_isSelected(selectedPermissions, n)));
              }
            } else {
              selectedPermissions.remove(alreadySelected);
              var toRemove = widget.getAllNested(alreadySelected);
              toRemove += _getParentsToRemove(alreadySelected, toRemove);
              toRemove.forEach((p) {
                if (_isSelected(selectedPermissions, p)) {
                  selectedPermissions.remove(p);
                }
              });
            }
            controller = controller.copyWith(
                children: controller.children.map(_mapOldNode).toList());
            widget.onSelectedChanged(selectedPermissions);
          });
        },
        onExpansionChanged: (key, expanded) => _expandNode(key, expanded));
  }

  Node<Permission> _mapOldNode(Node<dynamic> e) {
    var permission = e.data as Permission;
    return Node<Permission>(
        key: e.key,
        label: e.label,
        expanded: e.expanded,
        data: permission,
        icon: NodeIcon(codePoint: getIconCode(selectedPermissions, permission)),
        children: e.children.isNotEmpty
            ? e.children.map((c) => _mapOldNode(c)).toList()
            : []);
  }
}
