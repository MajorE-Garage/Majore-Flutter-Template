import 'dart:async';

import 'package:flutter/foundation.dart';

mixin class DebounceMixin {
  Timer? _timer;

  void debounceCallback(
    VoidCallback callback, {
    Duration waitTime = const Duration(milliseconds: 800),
  }) {
    if (_timer != null) _timer!.cancel();
    _timer = Timer(waitTime, callback);
  }

  void cancelDebounceCallback() {
    _timer?.cancel();
  }
}
