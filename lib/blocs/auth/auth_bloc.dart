import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/api/api_exception.dart';
import '../../core/storage/token_storage.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final TokenStorage _tokenStorage;

  AuthBloc({
    required AuthService authService,
    required TokenStorage tokenStorage,
  })  : _authService = authService,
        _tokenStorage = tokenStorage,
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final token = await _tokenStorage.readToken();
    if (token == null || token.isEmpty) {
      emit(Unauthenticated());
      return;
    }

    try {
      final user = await _authService.getProfile();
      emit(Authenticated(user));
    } catch (_) {
      await _tokenStorage.clearToken();
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authService.login(
        email: event.email,
        password: event.password,
      );
      // Đợi một chút để đảm bảo storage đã ghi xong (quan trọng cho Web)
      await Future.delayed(const Duration(milliseconds: 100));
      emit(Authenticated(response.user));
    } catch (e) {
      if (e is ApiException) {
        emit(AuthError(e.message));
      } else {
        emit(AuthError(e.toString()));
      }
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authService.register(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        role: event.role,
      );
      await Future.delayed(const Duration(milliseconds: 100));
      emit(Authenticated(response.user));
    } catch (e) {
      if (e is ApiException) {
        emit(AuthError(e.message));
      } else {
        emit(AuthError(e.toString()));
      }
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.logout();
    emit(Unauthenticated());
  }
}
