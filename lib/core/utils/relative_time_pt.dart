/// Formata tempo relativo curto em português.
String formatRelativeTimePt(DateTime dateTime, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final diff = reference.difference(dateTime);
  if (diff.isNegative || diff.inMinutes < 1) return 'agora';
  if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'há ${diff.inHours} h';
  if (diff.inDays < 7) return 'há ${diff.inDays} d';
  if (diff.inDays < 30) return 'há ${diff.inDays ~/ 7} sem';
  return 'há ${diff.inDays ~/ 30} mês';
}
