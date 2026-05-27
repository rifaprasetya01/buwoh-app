import 'package:flutter_test/flutter_test.dart';

import 'package:buwoh_app/main.dart';

void main() {
  testWidgets('Splash screen shows Buwoh branding', (WidgetTester tester) async {
    await tester.pumpWidget(const BuwohApp());

    // Verifikasi teks branding muncul
    expect(find.text('Buwoh'), findsOneWidget);
    expect(find.text('DIGITALISASI TRADISI HAJATAN'), findsOneWidget);
  });
}
