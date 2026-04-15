import 'package:get/get.dart';

// Nanti lu uncomment import di bawah ini kalau file View & Binding-nya udah dibuat
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

// import '../modules/auth/bindings/auth_binding.dart';
// import '../modules/auth/views/login_view.dart';
// import '../modules/auth/views/register_view.dart';

// import '../modules/task/bindings/task_binding.dart';
// import '../modules/task/views/task_view.dart';

// import '../modules/log/bindings/log_binding.dart';
// import '../modules/log/views/log_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // Tentukan halaman pertama yang muncul saat aplikasi dibuka
  // Nanti setelah ada Firebase Auth, ini bisa diubah ke Routes.LOGIN
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),

    // CONTOH UNTUK MODUL LAINNYA NANTI:
    /*
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.TASK,
      page: () => const TaskView(),
      binding: TaskBinding(),
    ),
    GetPage(
      name: _Paths.LOG,
      page: () => const LogView(),
      binding: LogBinding(),
    ),
    */
  ];
}