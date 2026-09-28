// Calculator Engine - Handles all arithmetic logic and history

/// A single history entry
class HistoryEntry {
  final String expression;
  final String result;
  final DateTime timestamp;

  const HistoryEntry({
    required this.expression,
    required this.result,
    required this.timestamp,
  });
}

class CalculatorEngine {
  String _currentInput = '0';
  String _previousInput = '';
  String _operator = '';
  String _expression = '';
  bool _shouldResetInput = false;
  bool _justCalculated = false;

  // History
  final List<HistoryEntry> _history = [];

  String get currentInput => _currentInput;
  String get expression => _expression;
  List<HistoryEntry> get history => List.unmodifiable(_history);

  /// Handle digit input (0-9 and .)
  void inputDigit(String digit) {
    if (_justCalculated && digit != '.') {
      _currentInput = digit;
      _expression = '';
      _justCalculated = false;
      return;
    }

    if (_shouldResetInput) {
      _currentInput = digit == '.' ? '0.' : digit;
      _shouldResetInput = false;
      return;
    }

    // Handle decimal point
    if (digit == '.') {
      if (_currentInput.contains('.')) return;
      _currentInput += '.';
      return;
    }

    // Limit input length
    if (_currentInput.length >= 12) return;

    if (_currentInput == '0') {
      _currentInput = digit;
    } else {
      _currentInput += digit;
    }
  }

  /// Handle operator input (+, -, ×, ÷)
  void inputOperator(String op) {
    _justCalculated = false;

    if (_operator.isNotEmpty && !_shouldResetInput) {
      // Chain operations: calculate previous first
      _calculate();
    }

    _previousInput = _currentInput;
    _operator = op;
    _expression = '${_formatForExpression(_previousInput)} $op';
    _shouldResetInput = true;
  }

  /// Toggle positive/negative
  void toggleSign() {
    if (_currentInput == '0') return;
    if (_currentInput.startsWith('-')) {
      _currentInput = _currentInput.substring(1);
    } else {
      _currentInput = '-$_currentInput';
    }
  }

  /// Convert to percentage
  void percentage() {
    final b = double.tryParse(_currentInput) ?? 0;
    double percentValue;
    if (_operator.isNotEmpty && _previousInput.isNotEmpty) {
      final a = double.tryParse(_previousInput) ?? 0;
      if (_operator == '+' || _operator == '-') {
        percentValue = a * b / 100;
      } else {
        percentValue = b / 100;
      }
      _expression = '${_formatForExpression(_previousInput)} $_operator ${_formatForExpression(_currentInput)}%';
    } else {
      percentValue = b / 100;
      _expression = '${_formatForExpression(_currentInput)}%';
    }
    _currentInput = _formatResult(percentValue);
    _justCalculated = true;
  }

  /// Backspace - delete last character
  void backspace() {
    if (_shouldResetInput || _currentInput == '0') return;
    if (_justCalculated) {
      clear();
      return;
    }
    if (_currentInput.length == 1 ||
        (_currentInput.length == 2 && _currentInput.startsWith('-'))) {
      _currentInput = '0';
    } else {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
    }
  }

  /// Clear all
  void clear() {
    _currentInput = '0';
    _previousInput = '';
    _operator = '';
    _expression = '';
    _shouldResetInput = false;
    _justCalculated = false;
  }

  /// Clear history
  void clearHistory() {
    _history.clear();
  }

  /// Load a history entry back into the calculator
  void loadFromHistory(HistoryEntry entry) {
    _currentInput = entry.result;
    _previousInput = '';
    _operator = '';
    _expression = entry.expression;
    _shouldResetInput = false;
    _justCalculated = true;
  }

  /// Calculate result
  void calculate() {
    if (_operator.isEmpty || _shouldResetInput) return;

    final String fullExpression;
    if (_expression.endsWith('%')) {
      fullExpression = _expression;
    } else {
      fullExpression =
          '${_formatForExpression(_previousInput)} $_operator ${_formatForExpression(_currentInput)}';
    }
    _expression = '$fullExpression =';

    _calculate();

    // Save to history only if calculation was successful
    if (_currentInput != 'Error') {
      _history.insert(
        0,
        HistoryEntry(
          expression: '$fullExpression =',
          result: _currentInput,
          timestamp: DateTime.now(),
        ),
      );
      // Keep max 50 history entries
      if (_history.length > 50) {
        _history.removeLast();
      }
    }

    _justCalculated = true;
    _operator = '';
    _shouldResetInput = false;
  }

  void _calculate() {
    final a = double.tryParse(_previousInput) ?? 0;
    final b = double.tryParse(_currentInput) ?? 0;
    double result;

    switch (_operator) {
      case '+':
        result = a + b;
        break;
      case '-':
        result = a - b;
        break;
      case '×':
        result = a * b;
        break;
      case '÷':
        if (b == 0) {
          _currentInput = 'Error';
          _previousInput = '';
          _operator = '';
          _shouldResetInput = true;
          return;
        }
        result = a / b;
        break;
      default:
        return;
    }

    _currentInput = _formatResult(result);
    _previousInput = _currentInput;
  }

  String _formatResult(double value) {
    // If it's an integer, don't show decimal
    if (value == value.truncateToDouble() && value.abs() < 1e12) {
      return value.toInt().toString();
    }
    // Limit to 10 significant figures
    String result = value.toStringAsPrecision(10);
    // Remove trailing zeros after decimal
    if (result.contains('.')) {
      result = result.replaceAll(RegExp(r'0+$'), '');
      result = result.replaceAll(RegExp(r'\.$'), '');
    }
    return result;
  }

  String _formatForExpression(String value) {
    return value;
  }

  /// Format display number with commas for readability
  String get formattedDisplay {
    if (_currentInput == 'Error') return 'Error';
    final parts = _currentInput.split('.');
    final intPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // Add commas to integer part
    final absInt = intPart.startsWith('-') ? intPart.substring(1) : intPart;
    final sign = intPart.startsWith('-') ? '-' : '';

    final formattedInt = absInt.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );

    return '$sign$formattedInt$decimalPart';
  }
}
