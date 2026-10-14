import 'package:flashcards/core/config.dart';
import 'package:flashcards/screens/auth_gate.dart';
import 'package:flashcards/services/api_client.dart';
import 'package:flashcards/services/auth_service.dart';
import 'package:flashcards/services/card_service.dart';
import 'package:flashcards/services/device_id_service.dart';
import 'package:flashcards/services/folder_service.dart';
import 'package:flashcards/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

String resolveApiBaseUrl() {
  const fromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  if (fromEnv.isNotEmpty) return fromEnv;
  if (kIsWeb) {
    return kReleaseMode ? AppConfig.productionApiBaseUrl : 'http://localhost:8080';
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:8080';
    default:
      return 'http://localhost:8080';
  }
}

const _enableSemantics = bool.fromEnvironment('ENABLE_SEMANTICS', defaultValue: false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb && _enableSemantics) {
    SemanticsBinding.instance.ensureSemantics();
  }
  final deviceId = await DeviceIdService().loadOrCreate();
  final api = ApiClient(baseUrl: resolveApiBaseUrl(), deviceId: deviceId);
  final auth = AuthService(api);
  await auth.bootstrap();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: api),
        ChangeNotifierProvider.value(value: auth),
        Provider(create: (_) => CardService(api)),
        Provider(create: (_) => FolderService(api)),
      ],
      child: const FlashcardsApp(),
    ),
  );
}

class FlashcardsApp extends StatelessWidget {
  const FlashcardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcards',
      debugShowCheckedModeBanner: false,
      theme: buildFlashcardsTheme(),
      home: const AuthGate(),
    );
  }
}
