import 'package:ttd_bloc/models/credentials.dart';
import 'package:ttd_bloc/models/user.dart';

abstract class AuthService {
  Future<User> readAuthFromStorage();
  Future<User> signIn(Credentials credentials);
  Future<void> signOut();
}