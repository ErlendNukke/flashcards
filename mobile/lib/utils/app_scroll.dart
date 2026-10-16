import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Web/mobile-friendly scroll physics (avoids expensive bouncing on mobile web).
ScrollPhysics get appScrollPhysics {
  if (kIsWeb) {
    return const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
    default:
      return const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}
