abstract class LoginAuthEvent {}

class LoginRequested extends LoginAuthEvent {
  final String username;
  final String password;

  LoginRequested({
    required this.username,
    required this.password,
  });
}