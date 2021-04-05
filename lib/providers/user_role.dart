import 'package:flutter/material.dart';

class UserRole {
  String id;
  String name;
  List<Permission> permissions;
  UserRole(
      {@required this.id, @required this.name, @required this.permissions});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'permissions': permissions.map((e) => e.toJson()).toList()
      };

  UserRole.fromJson(String id, dynamic data) {
    this.id = id;
    this.name = data['name'];
    this.permissions = (data['permissions'] as List<dynamic>)
        .map((e) => Permission.fromJson(e))
        .toList();
  }
}

class Permission {
  PermissionType type;
  String value;
  String displayText;
  List<Permission> includes;
  Permission(
      {@required this.type,
      @required this.value,
      @required this.displayText,
      this.includes});

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'value': value,
        'displayText': displayText,
        'includes': includes != null && includes.isNotEmpty
            ? includes.map((e) => e.toJson()).toList()
            : []
      };

  Permission.fromJson(dynamic data) {
    type = PermissionType.values[data['type'] as int];
    value = data['value'];
    displayText = data['displayText'];
    includes = (data['includes'] as List<dynamic>)
            ?.map((e) => Permission.fromJson(e))
            ?.toList() ??
        [];
  }
}

enum PermissionType { Access, View, Edit }
