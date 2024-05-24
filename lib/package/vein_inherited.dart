import 'package:flutter/widgets.dart';

import 'vein_notifier.dart';

class VeinInherited<T> extends InheritedWidget {
  final VeinNotifier<T> notifier;

  const VeinInherited({
    required this.notifier,
    required super.child,
    super.key,
  });

  static VeinInherited<T> of<T>(BuildContext context) {
    final VeinInherited<T>? inherited =
        context.dependOnInheritedWidgetOfExactType<VeinInherited<T>>();
    if (inherited == null) {
      throw FlutterError(
        'VeinInherited<$T> not found in context. Make sure to wrap your widget tree '
        'with VeinInherited<$T> to access the notifier.',
      );
    }
    return inherited;
  }

  @override
  bool updateShouldNotify(VeinInherited<T> oldWidget) =>
      oldWidget.notifier != notifier;
}
