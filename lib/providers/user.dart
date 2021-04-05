import 'package:flutter/cupertino.dart';

import 'user_role.dart';

class User with ChangeNotifier {
  final List<UserRole> roles;
  User({@required this.roles});

  Map<String, dynamic> toJson() => {'roles': roles};
}
