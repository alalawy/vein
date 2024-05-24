import 'package:flutter/widgets.dart';

import 'vein_notifier.dart';

typedef VeinBuilderNotifier<T> = Widget Function(
    BuildContext context, T value, Widget? child);

class VeinListen<T> extends StatefulWidget {
  const VeinListen({
    super.key,
    required this.listen,
    required this.builder,
    this.child,
  });

  final ValueListenable<T> listen;
  final VeinBuilderNotifier<T> builder;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _VeinListenState<T>();
}

class _VeinListenState<T> extends State<VeinListen<T>> {
  late T value;

  @override
  void initState() {
    super.initState();
    value = widget.listen.value;
    widget.listen.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(VeinListen<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listen != widget.listen) {
      oldWidget.listen.removeListener(_valueChanged);
      value = widget.listen.value;
      widget.listen.addListener(_valueChanged);
    }
  }

  @override
  void dispose() {
    widget.listen.removeListener(_valueChanged);
    super.dispose();
  }

  void _valueChanged() {
    final newValue = widget.listen.value;
    if (newValue != value) {
      value = newValue;
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, widget.child);
  }
}
