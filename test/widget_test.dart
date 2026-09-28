import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculatorapp/main.dart';
import 'package:calculatorapp/calculator_engine.dart';

void main() {
  group('CalculatorEngine Percentage Tests', () {
    late CalculatorEngine engine;

    setUp(() {
      engine = CalculatorEngine();
    });

    test('Unary percentage (no operator)', () {
      engine.inputDigit('1');
      engine.inputDigit('0');
      engine.percentage();
      expect(engine.currentInput, '0.1');
      expect(engine.expression, '10%');
    });

    test('Addition percentage (A + B%)', () {
      engine.inputDigit('2');
      engine.inputDigit('0');
      engine.inputDigit('0');
      engine.inputOperator('+');
      engine.inputDigit('1');
      engine.inputDigit('0');
      engine.percentage(); // 10% of 200 is 20
      expect(engine.currentInput, '20');
      expect(engine.expression, '200 + 10%');

      engine.calculate(); // 200 + 20 = 220
      expect(engine.currentInput, '220');
      expect(engine.expression, '200 + 10% =');
    });

    test('Subtraction percentage (A - B%)', () {
      engine.inputDigit('2');
      engine.inputDigit('0');
      engine.inputDigit('0');
      engine.inputOperator('-');
      engine.inputDigit('1');
      engine.inputDigit('0');
      engine.percentage(); // 10% of 200 is 20
      expect(engine.currentInput, '20');
      expect(engine.expression, '200 - 10%');

      engine.calculate(); // 200 - 20 = 180
      expect(engine.currentInput, '180');
      expect(engine.expression, '200 - 10% =');
    });

    test('Multiplication percentage (A × B%)', () {
      engine.inputDigit('2');
      engine.inputDigit('0');
      engine.inputDigit('0');
      engine.inputOperator('×');
      engine.inputDigit('1');
      engine.inputDigit('0');
      engine.percentage(); // 10% is 0.1
      expect(engine.currentInput, '0.1');
      expect(engine.expression, '200 × 10%');

      engine.calculate(); // 200 × 0.1 = 20
      expect(engine.currentInput, '20');
      expect(engine.expression, '200 × 10% =');
    });

    test('Division percentage (A ÷ B%)', () {
      engine.inputDigit('2');
      engine.inputDigit('0');
      engine.inputDigit('0');
      engine.inputOperator('÷');
      engine.inputDigit('1');
      engine.inputDigit('0');
      engine.percentage(); // 10% is 0.1
      expect(engine.currentInput, '0.1');
      expect(engine.expression, '200 ÷ 10%');

      engine.calculate(); // 200 ÷ 0.1 = 2000
      expect(engine.currentInput, '2000');
      expect(engine.expression, '200 ÷ 10% =');
    });

    test('Repeated percentage presses', () {
      engine.inputDigit('2');
      engine.inputDigit('0');
      engine.inputDigit('0');
      engine.inputOperator('+');
      engine.inputDigit('1');
      engine.inputDigit('0');
      engine.percentage(); // 1st press -> 20 (10% of 200)
      expect(engine.currentInput, '20');
      engine.percentage(); // 2nd press -> 40 (20% of 200)
      expect(engine.currentInput, '40');
      engine.percentage(); // 3rd press -> 80 (40% of 200)
      expect(engine.currentInput, '80');

      engine.calculate(); // 200 + 80 = 280
      expect(engine.currentInput, '280');
    });

    test('Digit entry resets after percentage (no operator)', () {
      engine.inputDigit('1');
      engine.inputDigit('0');
      engine.percentage(); // 0.1
      engine.inputDigit('5'); // should start a new number
      expect(engine.currentInput, '5');
      expect(engine.expression, '');
    });

    test('Digit entry resets after percentage (with operator)', () {
      engine.inputDigit('2');
      engine.inputDigit('0');
      engine.inputDigit('0');
      engine.inputOperator('+');
      engine.inputDigit('1');
      engine.inputDigit('0');
      engine.percentage(); // 20
      engine.inputDigit('5'); // should start a new number, clearing expression
      expect(engine.currentInput, '5');
      expect(engine.expression, '');
    });
  });

  testWidgets('Calculator Smoke Test', (WidgetTester tester) async {
    // Set screen size to a standard portrait smartphone (e.g. 400x800) to avoid RenderFlex overflow.
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const CalculatorApp());

    // Helper finder for the main result text widget inside the display container.
    Finder getResultDisplayFinder() {
      return find.descendant(
        of: find.byKey(const Key('display_container')),
        matching: find.byType(Text),
      ).last;
    }

    // Initially display should show '0'
    expect(tester.widget<Text>(getResultDisplayFinder()).data, '0');

    // Tap '1'
    await tester.tap(find.text('1'));
    await tester.pump();
    expect(tester.widget<Text>(getResultDisplayFinder()).data, '1');

    // Tap '2'
    await tester.tap(find.text('2'));
    await tester.pump();
    expect(tester.widget<Text>(getResultDisplayFinder()).data, '12');
  });
}
