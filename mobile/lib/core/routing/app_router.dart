import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../models/task_model.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/tasks/screens/task_details_screen.dart';
import '../../features/browser/screens/browser_screen.dart';
import '../../features/marketplace/screens/marketplace_screen.dart';
import '../../features/community/screens/community_screen.dart';
import '../../features/verification/screens/verification_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/wallet/screens/transaction_history_screen.dart';
import '../../features/wallet/screens/withdraw_screen.dart';
import '../widgets/feedback/app_error_state.dart';

/// Centralized Router for VEWRA application.
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.root:
      case AppRoutes.splash:
        return _buildRoute(const SplashScreen(), settings);

      case AppRoutes.welcome:
        return _buildRoute(const WelcomeScreen(), settings);

      case AppRoutes.login:
        return _buildRoute(const LoginScreen(), settings);

      case AppRoutes.register:
        return _buildRoute(const RegisterScreen(), settings);

      case AppRoutes.forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings);

      case AppRoutes.mainShell:
        return _buildRoute(const MainShell(initialIndex: 0), settings);

      case AppRoutes.home:
        return _buildRoute(const MainShell(initialIndex: 0), settings);

      case AppRoutes.tasks:
        return _buildRoute(const MainShell(initialIndex: 1), settings);

      case AppRoutes.rewards:
        return _buildRoute(const MainShell(initialIndex: 2), settings);

      case AppRoutes.wallet:
        return _buildRoute(const MainShell(initialIndex: 3), settings);

      case AppRoutes.transactionHistory:
        return _buildRoute(const TransactionHistoryScreen(), settings);

      case AppRoutes.withdraw:
        return _buildRoute(const WithdrawScreen(), settings);

      case AppRoutes.profile:
        return _buildRoute(const MainShell(initialIndex: 4), settings);

      case AppRoutes.taskDetails:
        final task = settings.arguments is TaskModel ? settings.arguments as TaskModel : null;
        return _buildRoute(TaskDetailsScreen(task: task), settings);

      case AppRoutes.browser:
        final task = settings.arguments is TaskModel ? settings.arguments as TaskModel : null;
        return _buildRoute(BrowserScreen(task: task), settings);

      case AppRoutes.marketplace:
        return _buildRoute(const MarketplaceScreen(), settings);

      case AppRoutes.community:
        return _buildRoute(const CommunityScreen(), settings);

      case AppRoutes.verification:
        return _buildRoute(const VerificationScreen(), settings);

      case AppRoutes.settings:
        return _buildRoute(const SettingsScreen(), settings);

      default:
        return _buildRoute(
          Scaffold(
            body: AppErrorState(
              title: 'Route Not Found',
              message: 'The requested route "${settings.name}" does not exist.',
            ),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(Widget screen, RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => screen,
      settings: settings,
    );
  }
}
