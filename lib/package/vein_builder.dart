import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'vein_notifier.dart' as notifier;
export 'package:flutter/rendering.dart' show RelativeRect;

abstract class AnimatedWidget extends StatefulWidget {
  const AnimatedWidget({
    super.key,
    required this.logic,
  });

  final notifier.Listenable logic;

  @protected
  Widget build(BuildContext context);
}

class VeinBuilder extends AnimatedWidget {
  const VeinBuilder({
    super.key,
    required super.logic,
    required this.builder,
    this.child,
  });

  @override
  notifier.Listenable get logic => super.logic;

  final TransitionBuilder builder;

  final Widget? child;

  @override
  Widget build(BuildContext context) => builder(context, child);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<notifier.Listenable>('logic', logic));
  }

  @override
  State<AnimatedWidget> createState() => _AnimatedState();
}

class _AnimatedState extends State<AnimatedWidget> {
  @override
  void initState() {
    super.initState();
    widget.logic.addListener(_handleChange);
  }

  @override
  void didUpdateWidget(AnimatedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logic != oldWidget.logic) {
      oldWidget.logic.removeListener(_handleChange);
      widget.logic.addListener(_handleChange);
    }
  }

  @override
  void dispose() {
    widget.logic.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => widget.build(context);
}
