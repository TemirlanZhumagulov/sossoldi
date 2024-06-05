import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../authentication_service.dart';

final authenticationServiceProvider = Provider<AuthenticationService>((ref) {
  return AuthenticationService();
});

