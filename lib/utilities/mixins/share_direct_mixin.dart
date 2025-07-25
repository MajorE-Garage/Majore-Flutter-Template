import 'dart:io';

import 'package:share_plus/share_plus.dart';

mixin class ShareDirectMixin {
  Future<void> shareText(String message) {
    return SharePlus.instance.share(ShareParams(text: message));
  }

  Future<void> shareFiles(List<File> files, [String? message]) {
    assert(files.isNotEmpty);
    return SharePlus.instance.share(
      ShareParams(files: files.map((e) => XFile(e.path)).toList(), subject: message),
    );
  }
}
