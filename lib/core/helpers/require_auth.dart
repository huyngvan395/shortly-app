// core/helpers/require_auth.dart


import 'package:flutter/material.dart';
import '../notifier/auth_notifier.dart';
import '../../di/injector.dart';
import '../widgets/auth_bottom_sheet.dart';

// ─── Extension on BuildContext ─────────────────────────────────────────────────

extension RequireAuthExtension on BuildContext {

  void requireAuth(VoidCallback action, {bool runAfterLogin = true}) {
    final auth = sl<AuthNotifier>();
    if (auth.isAuthenticated) {
      action();
    } else {
      AuthBottomSheet.show(this, pendingAction: runAfterLogin ? action : null);
    }
  }

  /// Kiểm tra trạng thái auth hiện tại (không side-effect).
  bool get isAuthenticated => sl<AuthNotifier>().isAuthenticated;
}



class AuthGuard extends StatelessWidget {
  /// Widget hiển thị khi đã đăng nhập.
  final Widget child;

  /// Widget hiển thị khi chưa đăng nhập.
  /// Nếu null và chưa đăng nhập, widget sẽ ẩn (SizedBox.shrink).
  final Widget? fallback;

  const AuthGuard({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sl<AuthNotifier>(),
      builder: (context, guardedChild) {
        if (sl<AuthNotifier>().isAuthenticated) {
          return guardedChild ?? child;
        }
        return fallback ?? const SizedBox.shrink();
      },
      child: child,
    );
  }
}
