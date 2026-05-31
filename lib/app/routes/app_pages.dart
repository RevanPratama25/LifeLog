import 'package:get/get.dart';

//Home
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

//Add Entry
import '../modules/add_entry/bindings/add_entry_binding.dart';
import '../modules/add_entry/views/add_entry_view.dart';

//Timeline
import '../modules/timeline/bindings/timeline_binding.dart';
import '../modules/timeline/views/timeline_view.dart';

//Auth
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';

//Base
import '../modules/base/bindings/base_binding.dart';
import '../modules/base/views/base_view.dart';

//Tasks
import '../modules/tasks/bindings/tasks_binding.dart';
import '../modules/tasks/views/tasks_view.dart';

//Root
import '../modules/root/bindings/root_binding.dart';
import '../modules/root/views/root_view.dart';

//Reflections
import '../modules/reflections/bindings/reflections_binding.dart';
import '../modules/reflections/views/reflections_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // First page displayed when the app launches
  static const initial = Routes.root;

  static final routes = [
    GetPage(
      name: _Paths.root,
      page: () => const RootView(),
      binding: RootBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: _Paths.base,
      page: () => const BaseView(),
      binding: BaseBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: _Paths.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: _Paths.addEntry,
      page: () => const AddEntryView(),
      binding: AddEntryBinding(),
    ),

    GetPage(
      name: _Paths.timeline,
      page: () => const TimelineView(),
      binding: TimelineBinding(),
    ),

    GetPage(
      name: _Paths.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: _Paths.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: _Paths.task,
      page: () => const TaskView(),
      binding: TaskBinding(),
    ),

    GetPage(
      name: _Paths.reflections,
      page: () => const ReflectionView(),
      binding: ReflectionsBinding(),
    ),
  ];
}
