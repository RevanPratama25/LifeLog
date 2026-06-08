part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  
  // Route constants used in navigation, e.g. Get.toNamed(Routes.home);
  static const root = _Paths.root;
  static const base = _Paths.base;
  static const home = _Paths.home;
  static const login = _Paths.login;
  static const register = _Paths.register;
  static const task = _Paths.task;
  static const log = _Paths.log;
  static const addEntry = _Paths.addEntry;
  static const timeline = _Paths.timeline;
  static const reflections = _Paths.reflections;
  static const initial = _Paths.initial;
  static const editProfile = _Paths.editProfile;
}

abstract class _Paths {
  _Paths._();
  
  // URL path definitions
  static const root = '/root';
  static const base = '/base';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const task = '/task';
  static const log = '/log';
  static const addEntry = '/add_entry';
  static const timeline = '/timeline';
  static const reflections = '/reflections';
  static const initial = '/initial';
  static const editProfile = '/edit_profile';
}