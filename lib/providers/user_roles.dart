import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mars/models/http_exception.dart';

import 'user_role.dart';

class UserRoles with ChangeNotifier {
  List<UserRole> _roles = [];
  final String authToken;
  final String userId;

  UserRoles(this.authToken, this.userId, this._roles);

  List<UserRole> get roles {
    return [..._roles];
  }

  UserRole findById(String id) {
    return _roles.firstWhere((x) => x.id == id);
  }

  Future<void> fetchAndSetRoles() async {
    var url = Uri.https("diploma-mars-default-rtdb.firebaseio.com",
        "/userManagement/roles.json", {'auth': authToken});

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<UserRole> loadedRoles = [];
      extractedData.forEach((id, data) {
        loadedRoles.add(UserRole.fromJson(id, data));
      });
      _roles = loadedRoles;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addRole(UserRole role) async {
    final url = Uri.https("diploma-mars-default-rtdb.firebaseio.com",
        "/userManagement/roles.json", {'auth': authToken});
    try {
      final response = await http.post(url, body: json.encode(role.toJson()));
      final newRole = UserRole(
          id: json.decode(response.body)['name'],
          name: role.name,
          permissions: role.permissions);
      _roles.add(newRole);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateRole(String id, UserRole newRole) async {
    final roleIndex = _roles.indexWhere((prod) => prod.id == id);
    if (roleIndex >= 0) {
      final url = Uri.https("diploma-mars-default-rtdb.firebaseio.com",
          "/userManagement/roles/$id.json", {'auth': authToken});
      var requestBody = newRole.toJson();
      requestBody.remove('id');
      await http.patch(url, body: json.encode(requestBody));
      _roles[roleIndex] = newRole;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteRole(String id) async {
    final url = Uri.https("diploma-mars-default-rtdb.firebaseio.com",
        "/userManagement/roles/$id.json", {'auth': authToken});
    final existingIndex = _roles.indexWhere((e) => e.id == id);
    var existing = _roles[existingIndex];
    _roles.removeAt(existingIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _roles.insert(existingIndex, existing);
      notifyListeners();
      throw HttpException('Could not delete role.');
    }
    existing = null;
  }
}
