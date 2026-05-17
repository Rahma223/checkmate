import '../../domain/entities/entities.dart';

class AuthResponse {
  final UserEntity user;
  final String token;

  AuthResponse({
    required this.user,
    required this.token,
  });
}