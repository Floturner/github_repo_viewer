import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:github_repo_viewer/auth/application/auth_notifier.dart';
import 'package:github_repo_viewer/auth/infrastructure/credentials_storage/secure_credentials_storage.dart';
import 'package:github_repo_viewer/auth/infrastructure/github_authenticator.dart';
import 'package:github_repo_viewer/auth/infrastructure/oauth2_interceptor.dart';

final flutterSecureStorageProvider =
    Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

final dioForAuthProvider = Provider((ref) => Dio());

final oAuth2InterceptorProvider = Provider<OAuth2Interceptor>(
  (ref) => OAuth2Interceptor(
    ref.watch(githubAuthenticatorProvider),
    ref.watch(authNotifierProvider.notifier),
    ref.watch(dioForAuthProvider),
  ),
);

final credentialsStorageProvider = Provider<SecureCredentialsStorage>(
  (ref) => SecureCredentialsStorage(ref.watch(flutterSecureStorageProvider)),
);

final githubAuthenticatorProvider = Provider<GithubAuthenticator>(
  (ref) => GithubAuthenticator(
    ref.watch(credentialsStorageProvider),
    ref.watch(dioForAuthProvider),
  ),
);

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(githubAuthenticatorProvider)),
);
