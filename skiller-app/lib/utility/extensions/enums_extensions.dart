import '../../config/enums.dart';

extension PostTypeExtension on PostType {
  String get toStr {
    switch (this) {
      case PostType.technology:
        return 'Technology';
      case PostType.project:
        return 'Project';
      case PostType.tipsAndTrick:
        return 'Tips & Trick';
      case PostType.talk:
        return 'Talks';
      case PostType.news:
        return 'News';
      case PostType.event:
        return 'Event';
      case PostType.other:
      default:
        return '';
    }
  }
}
