

const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// "Tuesday, 17 Nov", or "Tue, 17 Nov" when [short].
String todayLabel({bool short = false, DateTime? now}) {
  final d = now ?? DateTime.now();
  final day = _weekdays[d.weekday - 1];
  return '${short ? day.substring(0, 3) : day}, ${d.day} ${_months[d.month - 1]}';
}

String shortDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

String greeting({DateTime? now}) {
  final h = (now ?? DateTime.now()).hour;
  if (h < 12) return 'Good morning';
  if (h < 18) return 'Good afternoon';
  return 'Good evening';
}
