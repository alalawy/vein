import 'package:flutter/foundation.dart';
export 'dart:ui' show VoidCallback;

abstract class Listenable {
  const Listenable();

  factory Listenable.merge(List<Listenable?> listenables) = _MergingListenable;

  void addListener(VoidCallback listener);

  void removeListener(VoidCallback listener);
}

abstract class ValueListenable<T> extends Listenable {
  const ValueListenable();

  T get value;
}

const String _flutterFoundationLibrary = 'package:flutter/foundation.dart';

mixin class Notifier implements Listenable {
  int _count = 0;

  static final List<VoidCallback?> _emptyListeners =
      List<VoidCallback?>.filled(0, null);
  List<VoidCallback?> _listeners = _emptyListeners;
  int _notificationCallStackDepth = 0;
  int _reentrantlyRemovedListeners = 0;
  bool _debugDisposed = false;

  bool _creationDispatched = false;

  static bool debugAssertNotDisposed(Notifier notifier) {
    assert(() {
      if (notifier._debugDisposed) {
        throw FlutterError(
          'A ${notifier.runtimeType} was used after being disposed.\n'
          'Once you have called dispose() on a ${notifier.runtimeType}, it '
          'can no longer be used.',
        );
      }
      return true;
    }());
    return true;
  }

  @protected
  bool get hasListeners => _count > 0;

  @protected
  static void maybeDispatchObjectCreation(Notifier object) {
    if (kFlutterMemoryAllocationsEnabled && !object._creationDispatched) {
      FlutterMemoryAllocations.instance.dispatchObjectCreated(
        library: _flutterFoundationLibrary,
        className: '$Notifier',
        object: object,
      );
      object._creationDispatched = true;
    }
  }

  @override
  void addListener(VoidCallback listener) {
    assert(Notifier.debugAssertNotDisposed(this));

    if (kFlutterMemoryAllocationsEnabled) {
      maybeDispatchObjectCreation(this);
    }

    if (_count == _listeners.length) {
      if (_count == 0) {
        _listeners = List<VoidCallback?>.filled(1, null);
      } else {
        final List<VoidCallback?> newListeners =
            List<VoidCallback?>.filled(_listeners.length * 2, null);
        for (int i = 0; i < _count; i++) {
          newListeners[i] = _listeners[i];
        }
        _listeners = newListeners;
      }
    }
    _listeners[_count++] = listener;
  }

  void _removeAt(int index) {
    _count -= 1;
    if (_count * 2 <= _listeners.length) {
      final List<VoidCallback?> newListeners =
          List<VoidCallback?>.filled(_count, null);

      for (int i = 0; i < index; i++) {
        newListeners[i] = _listeners[i];
      }

      for (int i = index; i < _count; i++) {
        newListeners[i] = _listeners[i + 1];
      }

      _listeners = newListeners;
    } else {
      for (int i = index; i < _count; i++) {
        _listeners[i] = _listeners[i + 1];
      }
      _listeners[_count] = null;
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    for (int i = 0; i < _count; i++) {
      final VoidCallback? listenerAtIndex = _listeners[i];
      if (listenerAtIndex == listener) {
        if (_notificationCallStackDepth > 0) {
          _listeners[i] = null;
          _reentrantlyRemovedListeners++;
        } else {
          _removeAt(i);
        }
        break;
      }
    }
  }

  @mustCallSuper
  void dispose() {
    assert(Notifier.debugAssertNotDisposed(this));
    assert(
      _notificationCallStackDepth == 0,
      'The "dispose()" method on $this was called during the call to '
      '"refresh()". This is likely to cause errors since it modifies '
      'the list of listeners while the list is being used.',
    );
    assert(() {
      _debugDisposed = true;
      return true;
    }());
    if (kFlutterMemoryAllocationsEnabled && _creationDispatched) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
    _listeners = _emptyListeners;
    _count = 0;
  }

  @protected
  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  void refresh() {
    assert(Notifier.debugAssertNotDisposed(this));
    if (_count == 0) {
      return;
    }

    _notificationCallStackDepth++;

    final int end = _count;
    for (int i = 0; i < end; i++) {
      try {
        _listeners[i]?.call();
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'foundation library',
          context: ErrorDescription(
              'while dispatching notifications for $runtimeType'),
          informationCollector: () => <DiagnosticsNode>[
            DiagnosticsProperty<Notifier>(
              'The $runtimeType sending notification was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            ),
          ],
        ));
      }
    }

    _notificationCallStackDepth--;

    if (_notificationCallStackDepth == 0 && _reentrantlyRemovedListeners > 0) {
      final int newLength = _count - _reentrantlyRemovedListeners;
      if (newLength * 2 <= _listeners.length) {
        final List<VoidCallback?> newListeners =
            List<VoidCallback?>.filled(newLength, null);

        int newIndex = 0;
        for (int i = 0; i < _count; i++) {
          final VoidCallback? listener = _listeners[i];
          if (listener != null) {
            newListeners[newIndex++] = listener;
          }
        }

        _listeners = newListeners;
      } else {
        for (int i = 0; i < newLength; i += 1) {
          if (_listeners[i] == null) {
            int swapIndex = i + 1;
            while (_listeners[swapIndex] == null) {
              swapIndex += 1;
            }
            _listeners[i] = _listeners[swapIndex];
            _listeners[swapIndex] = null;
          }
        }
      }

      _reentrantlyRemovedListeners = 0;
      _count = newLength;
    }
  }
}

class _MergingListenable extends Listenable {
  _MergingListenable(this._children);

  final List<Listenable?> _children;

  @override
  void addListener(VoidCallback listener) {
    for (final Listenable? child in _children) {
      child?.addListener(listener);
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    for (final Listenable? child in _children) {
      child?.removeListener(listener);
    }
  }

  @override
  String toString() {
    return 'Listenable.merge([${_children.join(", ")}])';
  }
}

class VeinNotifier<T> extends Notifier implements ValueListenable<T> {
  VeinNotifier(this._value) {
    if (kFlutterMemoryAllocationsEnabled) {
      Notifier.maybeDispatchObjectCreation(this);
    }
  }

  @override
  T get value => _value;
  late T _value;
  set value(T newValue) {
    if (_value == newValue) {
      return;
    }
    _value = newValue;
    refresh();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}
