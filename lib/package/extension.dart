import 'package:flutter/widgets.dart';

import 'vein_notifier.dart';

extension VeinInt on int {
  VeinNotifier<int> get spec {
    final VeinNotifier<int> val = VeinNotifier(this);
    return val;
  }
}

extension VeinString on String {
  VeinNotifier<String> get spec {
    final VeinNotifier<String> val = VeinNotifier(this);
    return val;
  }
}

extension VeinBool on bool {
  VeinNotifier<bool> get spec {
    final VeinNotifier<bool> val = VeinNotifier(this);
    return val;
  }
}

extension VeinDouble on double {
  VeinNotifier<double> get spec {
    final VeinNotifier<double> val = VeinNotifier(this);
    return val;
  }
}

extension VeinList<T> on List<T> {
  VeinNotifier<List<T>> get spec {
    final VeinNotifier<List<T>> val = VeinNotifier(this);
    return val;
  }
}

extension VeinMap<K, V> on Map<K, V> {
  VeinNotifier<Map<K, V>> get spec {
    final VeinNotifier<Map<K, V>> val = VeinNotifier(this);
    return val;
  }
}

extension VeinSet<T> on Set<T> {
  VeinNotifier<Set<T>> get spec {
    final VeinNotifier<Set<T>> val = VeinNotifier(this);
    return val;
  }
}

extension VeinWidget on Widget {
  VeinNotifier<Widget> get spec {
    final VeinNotifier<Widget> val = VeinNotifier(this);
    return val;
  }
}

extension VeinT<T> on T {
  VeinNotifier<T> get spec {
    final VeinNotifier<T> val = VeinNotifier(this);
    return val;
  }
}

extension SpacerExt on double {
  Widget get h => SizedBox(height: this);
  Widget get w => SizedBox(width: this);
}

extension SpacerIntExt on int {
  Widget get h => SizedBox(height: toDouble());
  Widget get w => SizedBox(width: toDouble());
}
