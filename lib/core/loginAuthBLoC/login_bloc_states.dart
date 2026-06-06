abstract class LoginAuthState {}

class LoginInitial extends LoginAuthState {}

class LoginLoading extends LoginAuthState {}

class LoginSuccess extends LoginAuthState {
  final dynamic userData;

  LoginSuccess(this.userData);
}

class LoginFailure extends LoginAuthState {
  final String message;

  LoginFailure(this.message);
}