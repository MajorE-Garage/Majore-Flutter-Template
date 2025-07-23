import '../../../../core/domain/app_user.dart';

typedef LoginInfo = ({String token, UserModel user});

class UserModel extends AppUser {
  UserModel({required super.id, required super.email});
}
