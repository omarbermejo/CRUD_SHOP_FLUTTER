import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/config/config.dart';
import 'package:teslo_shop/config/const/env.dart';
import 'package:teslo_shop/config/router/app_router.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await EnveriomentConfig.initEnv();
  } catch (e) {
    rethrow;
  }
  
  runApp( 
    ProviderScope(child: MainApp())
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp.router(
      routerConfig: appRouter,
      theme: AppTheme().getTheme(),
      debugShowCheckedModeBanner: false,
    );
  }
}
