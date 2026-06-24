import 'package:equatable/equatable.dart';
import '../../models/api_enums.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final UserRole role;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
    this.role = UserRole.customer,
  });

  @override
  List<Object?> get props => [email, password, fullName, role];
}

class LogoutRequested extends AuthEvent {}
