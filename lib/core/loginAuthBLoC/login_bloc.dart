import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_design_demo/core/app_services/auth_repo.dart';
import 'package:new_design_demo/core/loginAuthBLoC/login_bloc_events.dart';
import 'package:new_design_demo/core/loginAuthBLoC/login_bloc_states.dart';

class LoginAuthBloc extends Bloc<LoginAuthEvent, LoginAuthState> {
  final AuthRepo authRepository;

  LoginAuthBloc(this.authRepository) : super(LoginInitial()) {

    on<LoginRequested>((event, emit) async {
      emit(LoginLoading());

      try {
        final result = await AuthRepo.login(
          event.username,
          event.password,
        );

        if (result.toString().toLowerCase().contains("success")) {
          emit(LoginSuccess(result));
        } else {
          emit(LoginFailure("Invalid credentials"));
        }

      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }
}