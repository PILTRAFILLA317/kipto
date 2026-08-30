String formatLocalDate(DateTime date) {
  final local = date.toLocal();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[local.month - 1]} ${local.day}, ${local.year}';
}

String formatLocalDateTime(DateTime date) {
  final local = date.toLocal();
  final minute = local.minute.toString().padLeft(2, '0');
  return '${formatLocalDate(local)} · ${local.hour}:$minute';
}

String formatRelativeDate(DateTime date, DateTime now) {
  final local = date.toLocal();
  final localNow = now.toLocal();
  final day = DateTime(local.year, local.month, local.day);
  final today = DateTime(localNow.year, localNow.month, localNow.day);
  final difference = day.difference(today).inDays;
  return switch (difference) {
    -1 => 'Yesterday',
    0 => 'Today',
    1 => 'Tomorrow',
    _ => formatLocalDate(local),
  };
}

String formatRelativeDateTime(DateTime date, DateTime now) {
  final local = date.toLocal();
  final minute = local.minute.toString().padLeft(2, '0');
  return '${formatRelativeDate(local, now)} · ${local.hour}:$minute';
}

String formatExpiry(DateTime date, DateTime now) {
  final difference =
      DateTime(date.toLocal().year, date.toLocal().month, date.toLocal().day)
          .difference(
            DateTime(
              now.toLocal().year,
              now.toLocal().month,
              now.toLocal().day,
            ),
          )
          .inDays;
  return switch (difference) {
    < -1 => 'Expired ${-difference} days ago',
    -1 => 'Expired yesterday',
    0 => 'Expires today',
    1 => 'Expires tomorrow',
    _ when difference > 1 && difference <= 7 => 'Expires in $difference days',
    _ => 'Expires ${formatLocalDate(date)}',
  };
}
