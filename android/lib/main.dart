import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:waste2ways/config/constants.dart';
import 'package:waste2ways/config/theme.dart';
import 'package:waste2ways/models/trash_report_model.dart';
import 'package:waste2ways/screens/permission_screen.dart';
import 'package:waste2ways/screens/profile_screen.dart';
import 'package:waste2ways/screens/report_trash_screen.dart';
import 'package:waste2ways/services/permission_service.dart';
import 'package:waste2ways/widgets/auth_state_wrapper.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/main_screen.dart';
import 'screens/trash_report_result_screen.dart';
import 'screens/hotspot_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    name: "ocean-beacon",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Constants.initializeBaseUrl();

  runApp(const Waste2Way());
}

class Waste2Way extends StatefulWidget {
  const Waste2Way({super.key});

  @override
  State<Waste2Way> createState() => _Waste2WayState();
}

class _Waste2WayState extends State<Waste2Way> {
  final PermissionService _permissionService = PermissionService();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _permissionService.checkPermissions();
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider.value(value: _permissionService),
      ],
      child: MaterialApp(
        title: 'Waste 2 Ways',
        theme: AppTheme.lightTheme,
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
          '/hotspot': (context) => const HotspotScreen(),
          '/home': (context) => const MainScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/report-trash': (context) => ReportTrashScreen(userId: ''),
          '/report-result':
              (context) => TrashReportResultScreen(
                report: TrashClassificationResponse(
                  material: "",
                  confidence: 0,
                  recyclability: "",
                  infrastructureSuitability: {},
                  environmentalImpact: {},
                  notes: "",
                  image: "",
                  id: 0,
                ),
              ),
          '/permissions': (context) => const PermissionScreen(),
          '/my-reports': (context) => const ReportsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/main': (context) => const MainScreen(),
        },
        initialRoute:
            !_initialized
                ? '/'
                : _permissionService.permissionsChecked &&
                    !_permissionService.allPermissionsGranted
                ? '/permissions'
                : null,
        home:
            !_initialized
                ? const SplashScreen()
                : _permissionService.permissionsChecked &&
                    !_permissionService.allPermissionsGranted
                ? const PermissionScreen()
                : AuthStateWrapper(
                  authenticatedRoute: const MainScreen(),
                  unauthenticatedRoute: const LoginScreen(),
                  loadingWidget: const SplashScreen(),
                  publicRoutes: const ['/settings', '/login', '/register'],
                ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco_outlined, size: 80, color: AppTheme.primaryColor),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
