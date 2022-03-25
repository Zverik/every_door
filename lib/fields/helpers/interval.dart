import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'hours_model.dart';

/// Advanced editor for a double time field in format of "12:34-18:59".
/// Allows negative intervals, e.g. "12:00-04:00".
class IntervalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final kDigits = '0123456789'.split('');
    bool didDelete =
        newValue.selection.baseOffset < oldValue.selection.baseOffset;
    String newChar = didDelete
        ? ''
        : newValue.text.substring(
        oldValue.selection.baseOffset, newValue.selection.baseOffset);
    // print('Old: ${oldValue.text}, sel ${oldValue.selection}');
    // print('New: ${newValue.text}, sel ${newValue.selection}');
    String oldText = oldValue.text.isEmpty
        ? ''
        : oldValue.text.substring(0, oldValue.selection.baseOffset);
    String numbers =
        oldText.characters.where((p0) => kDigits.contains(p0)).string;
    if (didDelete) {
      numbers = numbers.substring(0, numbers.length - 1);
    } else {
      if (newChar == ':') {
        if (numbers.length == 1) {
          numbers = '0' + numbers;
        } else if (numbers.length == 5) {
          numbers = numbers.substring(0, 4) + '0' + numbers.substring(4);
        }
      } else if (newChar == '-') {
        if (numbers.length >= 1 && numbers.length <= 4) {
          if (numbers.length == 1) {
            numbers = '0' + numbers;
          } else {
            numbers = numbers.padRight(4, '0');
          }
        }
      } else if (kDigits.contains(newChar)) {
        numbers = numbers + newChar;
      }
    }

    // first hours
    if ((numbers.length == 1 && int.parse(numbers) > 2) ||
        (numbers.length >= 2 && int.parse(numbers.substring(0, 2)) >= 24)) {
      numbers = '0' + numbers;
    }
    // second hours
    if ((numbers.length == 5 && int.parse(numbers.substring(4)) > 2) ||
        (numbers.length >= 6 && int.parse(numbers.substring(4, 6)) > 28)) {
      numbers = numbers.substring(0, 4) + '0' + numbers.substring(4);
    }

    int offset = numbers.length;
    if (numbers.length < 2 || numbers.length == 4 || numbers.length == 5) {
      // When entering hours, hide 00 placeholder for minutes
      numbers = numbers.padRight(8, '_');
    } else {
      if (numbers.length < 4) {
        numbers = numbers.padRight(4, '0').padRight(8, '_');
      } else {
        numbers = numbers.padRight(8, '0');
      }
    }
    final formatted =
        '${numbers.substring(0, 2)}:${numbers.substring(2, 4)}-${numbers.substring(4, 6)}:${numbers.substring(6, 8)}';
    offset += (offset / 2).floor();
    if (offset > formatted.length) offset = formatted.length;
    return oldValue.copyWith(
        text: formatted, selection: TextSelection.collapsed(offset: offset));
  }
}

class DigitIntervalField extends StatefulWidget {
  final HoursInterval interval;
  final Function(HoursInterval) onChange;
  final bool autofocus;

  const DigitIntervalField(
      {required this.interval, required this.onChange, this.autofocus = false});

  @override
  State<DigitIntervalField> createState() => _DigitIntervalFieldState();
}

class _DigitIntervalFieldState extends State<DigitIntervalField> {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.interval.toString());
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isValid(value) {
    if (value.length != 11) return false;
    final hours = int.tryParse(value.substring(0, 2));
    if (hours == null || hours >= 24) return false;
    final min = int.tryParse(value.substring(3, 5));
    if (min == null || min >= 60) return false;
    final hours2 = int.tryParse(value.substring(6, 8));
    if (hours2 == null || hours2 > 28) return false;
    final min2 = int.tryParse(value.substring(9, 11));
    if (min2 == null || min2 > 60) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      inputFormatters: [IntervalTextInputFormatter()],
      keyboardType: TextInputType.number,
      autocorrect: false,
      enableInteractiveSelection: false,
      enableSuggestions: false,
      style: TextStyle(fontFamily: 'monospace'),
      controller: _controller,
      onTap: () {
        _controller.text = '__:__-__:__';
        _controller.selection = TextSelection.collapsed(offset: 0);
      },
      onChanged: (value) {
        if (isValid(value)) {
          widget.onChange(
              HoursInterval(value.substring(0, 5), value.substring(6, 11)));
        }
      },
      onSubmitted: (value) {
        if (isValid(value)) {
          widget.onChange(
              HoursInterval(value.substring(0, 5), value.substring(6, 11)));
        } else {
          _controller.text = widget.interval.toString();
        }
      },
    );
  }
}
