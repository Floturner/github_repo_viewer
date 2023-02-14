import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:github_repo_viewer/core/shared/providers.dart';
import 'package:github_repo_viewer/auth/application/auth_notifier.dart';
import 'package:github_repo_viewer/auth/shared/providers.dart';
import 'package:github_repo_viewer/core/presentation/routes/app_router.gr.dart';

final initializationProvider = FutureProvider<void>((ref) async {
  await dotenv.load();
  await ref.read(sembastProvider).init();
  ref.read(dioProvider)
    ..options = BaseOptions(
      headers: {'Accept': 'application/vnd.github.v3.html+json'},
      validateStatus: (status) =>
          status != null && status >= 200 && status < 400,
    )
    ..interceptors.add(
      ref.read(oAuth2InterceptorProvider),
    );
  final authNotifier = ref.read(authNotifierProvider.notifier);
  await authNotifier.checkAndUpdateAuthStatus();
});

class AppWidget extends ConsumerWidget {
  final appRouter = AppRouter();

  AppWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(initializationProvider, (_, __) {});

    ref.listen<AuthState>(authNotifierProvider, (_, state) {
      state.maybeMap(
        orElse: (() {}),
        authenticated: (_) {
          appRouter.pushAndPopUntil(
            const StarredReposRoute(),
            predicate: (_) => false,
          );
        },
        unauthenticated: (_) {
          appRouter.pushAndPopUntil(
            const SignInRoute(),
            predicate: (_) => false,
          );
        },
      );
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Repo Viewer',
      theme: _setUpThemeData(context),
      routerDelegate: appRouter.delegate(),
      routeInformationParser: appRouter.defaultRouteParser(),
    );
  }

  ThemeData _setUpThemeData(BuildContext context) {
    return ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.headline6?.color,
      ),
    );
  }
}
