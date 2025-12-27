import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/config/config.dart';
import 'package:teslo_shop/config/const/env.dart';
import 'package:teslo_shop/config/router/app_router.dart';
import 'package:teslo_shop/config/theme/app_theme.dart';
import 'package:teslo_shop/config/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await EnveriomentConfig.initEnv();
  } catch (e) {
    rethrow;
  }

  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = AppTheme();
    final themeMode = ref.watch(themeModeProvider);

    if (PlatformHelper.isIOS) {
      return CupertinoApp.router(
        routerConfig: appRouter,
        theme: appTheme.getCupertinoTheme(isDark: themeMode == ThemeMode.dark),
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: MediaQuery.of(context).textScaler.clamp(
                    minScaleFactor: 0.8,
                    maxScaleFactor: 1.2,
                  ),
            ),
            child: child!,
          );
        },
      );
    } else {
      return MaterialApp.router(
        routerConfig: appRouter,
        theme: appTheme.getTheme(isDark: false),
        darkTheme: appTheme.getTheme(isDark: true),
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: MediaQuery.of(context).textScaler.clamp(
                    minScaleFactor: 0.8,
                    maxScaleFactor: 1.2,
                  ),
            ),
            child: child!,
          );
        },
      );
    }
  }
}
