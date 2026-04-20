part of 'app_pages.dart';
// JANGAN IMPORT APAPUN DI SINI

abstract class Routes {
  Routes._();
  
  // Ini yang akan dipanggil di UI, contoh: Get.toNamed(Routes.HOME);
  static const BASE = _Paths.BASE;
  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const TASK = _Paths.TASK;
  static const LOG = _Paths.LOG;
  static const ADD_ENTRY = _Paths.ADD_ENTRY;
  static const TIMELINE = _Paths.TIMELINE;
  static const INITIAL = _Paths.INITIAL;
}

abstract class _Paths {
  _Paths._();
  
  // Ini definisi path URL-nya (berguna kalau app lu di-build ke Web)
  static const BASE = '/base';
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const TASK = '/task';
  static const LOG = '/log';
  static const ADD_ENTRY = '/add_entry';
  static const TIMELINE = '/timeline';
  static const INITIAL = '/initial';
}