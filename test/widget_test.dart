import 'package:flutter_test/flutter_test.dart';
import 'package:tulimovie/app.dart';

void main() {
  testWidgets('TuliMovieApp monta sem erros', (tester) async {
    await tester.pumpWidget(const TuliMovieApp());
    expect(find.text('TuliMovie'), findsOneWidget);
  });
}
