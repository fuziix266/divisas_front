import 'package:flutter_test/flutter_test.dart';
import 'package:divisas/main.dart';

void main() {
  testWidgets('App arranca correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const DivisasApp());
    // Verificar que la app inicia sin errores
    expect(find.byType(DivisasApp), findsOneWidget);
  });
}
