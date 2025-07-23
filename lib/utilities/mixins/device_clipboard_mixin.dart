import 'package:flutter/services.dart';

import '../../features/shared/components/overlays/app_toast_widget.dart';

mixin DeviceClipboardMixin {
  void copyToClipboard(String text, {String? feedbackMessage}) {
    Clipboard.setData(ClipboardData(text: text));
    if (feedbackMessage != null) {
      AppToast.success(feedbackMessage).show();
    }
  }

  Future<String?> pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
}
