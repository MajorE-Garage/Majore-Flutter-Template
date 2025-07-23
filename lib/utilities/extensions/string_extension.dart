import 'package:flutter/widgets.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return '';
    final chars = characters;
    final first = chars.first.toUpperCase();
    final rest = (chars.toList()..removeAt(0)).join();
    return '$first$rest';
  }

  String truncate(int limit) {
    if (limit < 0) return this;
    return substring(
      0,
      length.clamp(0, limit),
    );
  }

  String pluralise(int count) {
    if (count > 1) {
      return '$count ${this}s';
    } else {
      return '$count $this';
    }
  }

  String toWordCase() {
    final parts = toLowerCase().split(' ');

    final a = parts.map((e) {
      if (e.isNotEmpty) {
        return e.replaceRange(0, 1, e[0].toUpperCase());
      } else {
        return e;
      }
    });

    return a.join(' ');
  }
}
