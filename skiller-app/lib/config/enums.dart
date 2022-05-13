enum PostType { technology, project, tipsAndTrick, internship, job, talk, news, event, other }

Map<int, PostType> postTypes = {
  1: PostType.technology,
  2: PostType.project,
  3: PostType.tipsAndTrick,
  4: PostType.internship,
  5: PostType.job,
  6: PostType.talk,
  7: PostType.news,
  8 : PostType.event,
  9 : PostType.other,
};

enum UserType { student, alumni, professor, admin }
Map<int, UserType> userTypes = {
  1: UserType.admin,
  2: UserType.professor,
  3: UserType.alumni,
  4: UserType.student,
};
