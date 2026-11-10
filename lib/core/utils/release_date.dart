import '../i18n/locale_service.dart';

const _uzMonths = [
  'yanvar', 'fevral', 'mart', 'aprel', 'may', 'iyun',
  'iyul', 'avgust', 'sentabr', 'oktabr', 'noyabr', 'dekabr',
];
const _ruMonths = [
  'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
  'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
];
const _uzDays = ['dushanba', 'seshanba', 'chorshanba', 'payshanba', 'juma', 'shanba', 'yakshanba'];
const _ruDays = ['понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота', 'воскресенье'];
const _uzShortDays = ['Du', 'Se', 'Chor', 'Pay', 'Ju', 'Sha', 'Yak'];
const _ruShortDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

String _two(int n) => n.toString().padLeft(2, '0');

String formatReleaseDate(DateTime at) {
  final t = at.toLocal();
  final time = '${_two(t.hour)}:${_two(t.minute)}';
  if (LocaleService.isRussian) {
    return '${t.day} ${_ruMonths[t.month - 1]}, ${_ruDays[t.weekday - 1]} $time';
  }
  return '${t.day}-${_uzMonths[t.month - 1]}, ${_uzDays[t.weekday - 1]} $time';
}

String formatReleaseShort(DateTime at) {
  final t = at.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(t.year, t.month, t.day);
  final diff = day.difference(today).inDays;
  final time = '${_two(t.hour)}:${_two(t.minute)}';
  final ru = LocaleService.isRussian;
  if (diff == 0) return '${ru ? 'Сегодня' : 'Bugun'}, $time';
  if (diff == 1) return '${ru ? 'Завтра' : 'Ertaga'}, $time';
  if (diff > 1 && diff < 7) return '${(ru ? _ruShortDays : _uzShortDays)[t.weekday - 1]}, $time';
  return ru ? '${t.day} ${_ruMonths[t.month - 1]}, $time' : '${t.day}-${_uzMonths[t.month - 1]}, $time';
}

String formatReleaseLeft(DateTime at) {
  final left = at.difference(DateTime.now());
  final ru = LocaleService.isRussian;
  if (left.inMinutes <= 0) return ru ? 'Совсем скоро' : 'Hademay';
  final days = left.inDays;
  final hours = left.inHours % 24;
  final minutes = left.inMinutes % 60;
  if (days > 0) return ru ? 'через $days д $hours ч' : '$days kun $hours soatdan keyin';
  if (hours > 0) return ru ? 'через $hours ч $minutes мин' : '$hours soat $minutes daqiqadan keyin';
  return ru ? 'через $minutes мин' : '$minutes daqiqadan keyin';
}
