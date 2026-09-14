// ============================================================
// DepthFence Widget Tests
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:depthfenc/main.dart';

void main() {
  testWidgets('DepthFence app renders login screen when logged out',
      (WidgetTester tester) async {
    // Build our app with a fresh state
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DepthFenceState(),
        child: const DepthFenceApp(),
      ),
    );

    // Trigger a frame and let the initial route render
    await tester.pumpAndSettle();

    // The app should show the login screen by default
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.byType(LightningAction), findsOneWidget);
  });
}
