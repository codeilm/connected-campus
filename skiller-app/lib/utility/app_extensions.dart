extension DateExtension on DateTime {
  dynamic timeAgo() {
    int seconds = DateTime.now().difference(this).inSeconds;
    int minutes = DateTime.now().difference(this).inMinutes;
    int hours = DateTime.now().difference(this).inHours;
    if (seconds ~/ 60 == 0) {
      return '$seconds s';
    }  else if (hours ~/ 24 == 0) {
      return '$hours h';
    } else if (hours ~/ 168 == 0) {
      return '${hours ~/ 24} d';
    }  else if (hours ~/ 8640 == 0) {
      return '${hours ~/ 720} m';
    } else {
      return '${hours ~/ 8640} y';
    }
  }
}
