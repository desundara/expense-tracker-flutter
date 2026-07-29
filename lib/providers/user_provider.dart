import 'package:flutter/foundation.dart';
import '../models/user.dart';

/// Holds the currently logged-in user for the session.
/// Set on successful login, read by any screen that needs to know
/// who's using the app (Dashboard, Add Expense, Settings, etc).
class UserProvider extends ChangeNotifier {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  void setUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}