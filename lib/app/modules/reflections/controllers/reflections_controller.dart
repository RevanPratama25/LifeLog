import 'package:get/get.dart';

class ReflectionsController extends GetxController {
  final selectedCategory = 'ALL LOGS'.obs;

  final allLogs = [
    {
      'title': 'Completed Deep Work Sprint: Neural Architecture',
      'content': 'Finally cracked the core logic for the feedback loop. Felt a strange sense of clarity after the third hour. Remember to keep the focus narrow next time; the periphery is just noise.',
      'category': 'GROWTH',
      'date': 'OCT 24, 2023',
    },
    {
      'title': 'Early Morning Trail Run',
      'content': 'The fog was thick at the summit. Running through the silence reminded me why I do this. Physical strain is the only thing that quiets the mental chatter. Pace was consistent at 5:12.',
      'category': 'HEALTH',
      'date': 'OCT 23, 2023',
    },
    {
      'title': 'Weekend Digital Detox Reflection',
      'content': '48 hours without a screen. The first few hours were twitchy, but by Sunday afternoon, I was reading a physical book without checking my phone once. Need to make this a bi-weekly ritual.',
      'category': 'PERSONAL',
      'date': 'OCT 21, 2023',
    },
  ];

  void setCategory(String cat) {
    selectedCategory.value = cat;
  }
}