import 'package:flutter/material.dart';
import 'calculator_engine.dart';
import 'calc_button.dart';
import 'history_sheet.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  final CalculatorEngine _engine = CalculatorEngine();

  // ── Color Palette ──────────────────────────────────────────────────────────
  static const Color _bgDark = Color(0xFF0F0F14);
  static const Color _displayBg = Color(0xFF16161F);
  static const Color _btnDark = Color(0xFF1E1E2A);        // number buttons
  static const Color _btnMid = Color(0xFF252535);         // function buttons
  static const Color _btnOrange = Color(0xFFFF7A00);      // operator buttons
  static const Color _btnOrangePale = Color(0xFFFF9A40);  // equals
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF9090A8);

  // Animation for display update
  late AnimationController _displayAnimCtrl;
  late Animation<double> _displayAnim;

  @override
  void initState() {
    super.initState();
    _displayAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _displayAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _displayAnimCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _displayAnimCtrl.dispose();
    super.dispose();
  }

  void _flashDisplay() async {
    await _displayAnimCtrl.forward();
    await _displayAnimCtrl.reverse();
  }

  void _onButton(String label) {
    setState(() {
      switch (label) {
        case 'AC':
          _engine.clear();
          break;
        case '+/-':
          _engine.toggleSign();
          break;
        case '%':
          _engine.percentage();
          break;
        case '÷':
        case '×':
        case '-':
        case '+':
          _engine.inputOperator(label);
          break;
        case '=':
          _engine.calculate();
          _flashDisplay();
          break;
        case '⌫':
          _engine.backspace();
          break;
        default:
          _engine.inputDigit(label);
      }
    });
  }

  // Determine font size based on display length
  double _displayFontSize(String text) {
    final len = text.replaceAll(',', '').replaceAll('-', '').length;
    if (len <= 6) return 72;
    if (len <= 9) return 56;
    if (len <= 11) return 44;
    return 36;
  }

  @override
  Widget build(BuildContext context) {
    final display = _engine.formattedDisplay;
    final expression = _engine.expression;

    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CALC',
                    style: TextStyle(
                      color: _btnOrange,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showHistory(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _engine.history.isNotEmpty
                            ? _btnOrange.withValues(alpha: 0.15)
                            : _btnDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        color: _engine.history.isNotEmpty
                            ? _btnOrange
                            : _textMuted,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Display Area ─────────────────────────────────────────────────
            Expanded(
              child: Container(
                key: const Key('display_container'),
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _displayBg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Expression line
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          expression,
                          key: ValueKey(expression),
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Main result display
                      ScaleTransition(
                        scale: _displayAnim,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: Text(
                            display,
                            key: ValueKey(display),
                            style: TextStyle(
                              color: display == 'Error'
                                  ? Colors.redAccent
                                  : _textWhite,
                              fontSize: _displayFontSize(display),
                              fontWeight: FontWeight.w300,
                              letterSpacing: -2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Button Grid ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20),
              child: Column(
                children: [
                  // Row 1: AC  +/-  %  ÷
                  _buildRow([
                    _ButtonDef(label: 'AC', bg: _btnMid, fg: _btnOrange),
                    _ButtonDef(label: '+/-', bg: _btnMid, fg: _textWhite),
                    _ButtonDef(label: '%', bg: _btnMid, fg: _textWhite),
                    _ButtonDef(label: '÷', bg: _btnOrange, fg: _textWhite, fontSize: 30),
                  ]),
                  // Row 2: 7  8  9  ×
                  _buildRow([
                    _ButtonDef(label: '7', bg: _btnDark, fg: _textWhite),
                    _ButtonDef(label: '8', bg: _btnDark, fg: _textWhite),
                    _ButtonDef(label: '9', bg: _btnDark, fg: _textWhite),
                    _ButtonDef(label: '×', bg: _btnOrange, fg: _textWhite, fontSize: 28),
                  ]),
                  // Row 3: 4  5  6  -
                  _buildRow([
                    _ButtonDef(label: '4', bg: _btnDark, fg: _textWhite),
                    _ButtonDef(label: '5', bg: _btnDark, fg: _textWhite),
                    _ButtonDef(label: '6', bg: _btnDark, fg: _textWhite),
                    _ButtonDef(label: '-', bg: _btnOrange, fg: _textWhite, fontSize: 32),
                  ]),
                  // Row 4: 1  2  3  +
                  _buildRow([
                    _ButtonDef(label: '1', bg: _btnDark, fg: _textWhite),
                    _ButtonDef(label: '2', bg: _btnDark, fg: _textWhite),
                    _ButtonDef(label: '3', bg: _btnDark, fg: _textWhite),
                    _ButtonDef(label: '+', bg: _btnOrange, fg: _textWhite, fontSize: 30),
                  ]),
                  // Row 5: ⌫  0  .  =
                  _buildRow([
                    _ButtonDef(
                        label: '⌫',
                        bg: _btnMid,
                        fg: _btnOrange,
                        icon: Icons.backspace_outlined,
                        fontSize: 22),
                    _ButtonDef(label: '0', bg: _btnDark, fg: _textWhite),
                    _ButtonDef(label: '.', bg: _btnDark, fg: _textWhite),
                    _ButtonDef(label: '=', bg: _btnOrangePale, fg: _textDark, fontSize: 28),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistory() {
    HistorySheet.show(
      context,
      history: _engine.history,
      onTapEntry: (entry) {
        setState(() {
          _engine.loadFromHistory(entry);
        });
      },
      onClearHistory: () {
        setState(() {
          _engine.clearHistory();
        });
      },
    );
  }

  Widget _buildRow(List<_ButtonDef> buttons) {
    return Row(
      children: buttons
          .map((b) => CalcButton(
                label: b.label,
                backgroundColor: b.bg,
                textColor: b.fg,
                fontSize: b.fontSize,
                icon: b.icon,
                onPressed: () => _onButton(b.label),
              ))
          .toList(),
    );
  }
}

/// Simple data class for button configuration
class _ButtonDef {
  final String label;
  final Color bg;
  final Color fg;
  final double fontSize;
  final IconData? icon;

  const _ButtonDef({
    required this.label,
    required this.bg,
    required this.fg,
    this.fontSize = 26,
    this.icon,
  });
}
