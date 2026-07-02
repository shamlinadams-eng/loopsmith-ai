import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'router/app_router.dart';
import 'services/audio_player_service.dart';
import 'services/auth_service.dart';
import 'services/loop_service.dart';
import 'services/replicate_service.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase native channels are unavailable in the web preview — skip init
  // on web so the UI renders correctly. On Android/iOS builds it runs fully.
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const LoopSmithApp());
}

class LoopSmithApp extends StatelessWidget {
  const LoopSmithApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReplicateService()),
        ProxyProvider<ReplicateService, LoopService>(
          create: (ctx) => LoopService(ctx.read<ReplicateService>()),
          update: (_, replicate, prev) => prev ?? LoopService(replicate),
        ),
        ChangeNotifierProvider(create: (_) => AudioPlayerService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp.router(
        title: 'LoopSmith AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}