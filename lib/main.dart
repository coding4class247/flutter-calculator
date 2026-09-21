import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Copilot Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff1f6f78),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _result = '';
  String? _error;
  bool _justEvaluated = false;

  bool _isOperator(String value) => '+-*/'.contains(value);

  void _press(String value) {
    setState(() {
      if (_justEvaluated && RegExp(r'^[0-9.]$').hasMatch(value)) {
        _expression = '';
        _result = '';
      }
      if (value == '=') {
        _calculate();
        return;
      }
      if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (_isOperator(value)) {
        if (_expression.isEmpty && value != '-') return;
        if (_isOperator(
          _expression.isNotEmpty ? _expression[_expression.length - 1] : '',
        )) {
          _expression =
              _expression.substring(0, _expression.length - 1) + value;
        } else {
          _expression += value;
        }
      } else if (value == '.') {
        final currentNumber = _expression.split(RegExp(r'[+\-*/]')).last;
        if (!currentNumber.contains('.')) _expression += value;
      } else {
        _expression += value;
      }
      _error = null;
      _result = '';
      _justEvaluated = false;
    });
  }

  void _calculate() {
    if (_expression.isEmpty) return;
    try {
      final parsed = Expression.parse(_expression);
      final value = const ExpressionEvaluator().eval(parsed, {});
      if (value is! num || value.isNaN || value.isInfinite) {
        throw const FormatException('The result is not a valid number.');
      }
      _result = value == value.roundToDouble()
          ? value.toInt().toString()
          : value.toString();
      _error = null;
      _justEvaluated = true;
    } catch (_) {
      _result = '';
      _error = 'Cannot calculate this expression';
      _justEvaluated = false;
    }
  }

  void _clear() {
    setState(() {
      _expression = '';
      _result = '';
      _error = null;
      _justEvaluated = false;
    });
  }

  String _displayExpression() {
    return _expression.replaceAllMapped(
      RegExp(r'([+\-*/])'),
      (match) => ' ${match.group(1)} ',
    );
  }

  Color _buttonColor(String label, ColorScheme colors) {
    if (label == '=') return colors.primary;
    if (label == 'C') return colors.errorContainer;
    if (_isOperator(label) || label == '⌫') return colors.secondaryContainer;
    return colors.surfaceContainerHighest;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const buttons = [
      ['C', '⌫', '/', '*'],
      ['7', '8', '9', '-'],
      ['4', '5', '6', '+'],
      ['1', '2', '3', '='],
      ['0', '.', '', ''],
    ];
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'GitHub Copilot Calculator',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.bottomRight,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: SingleChildScrollView(
                        reverse: true,
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _expression.isEmpty
                                  ? '0'
                                  : '${_displayExpression()}${_result.isNotEmpty ? ' = $_result' : ''}',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: colors.onPrimaryContainer),
                              textAlign: TextAlign.right,
                            ),
                            if (_error != null)
                              Text(
                                _error!,
                                style: TextStyle(
                                  color: colors.error,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    flex: 5,
                    child: GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (final row in buttons)
                          for (final label in row)
                            if (label.isNotEmpty)
                              _CalculatorButton(
                                label: label,
                                color: _buttonColor(label, colors),
                                foregroundColor: label == '='
                                    ? colors.onPrimary
                                    : colors.onSurface,
                                onPressed: label == 'C'
                                    ? _clear
                                    : () => _press(label),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({
    required this.label,
    required this.color,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label == '⌫' ? 'Backspace' : label,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
