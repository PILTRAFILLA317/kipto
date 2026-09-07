import 'package:flutter/material.dart';
import 'package:kipto/app/theme/app_tokens.dart';

/// Adapts ordered repository snapshots to Flutter's lazy animated sliver.
/// Account changes replace the sliver immediately, including outgoing rows.
class KiptoAnimatedSliverList<T> extends StatefulWidget {
  const KiptoAnimatedSliverList({
    super.key,
    required this.items,
    required this.idOf,
    required this.itemBuilder,
    required this.accountScope,
  });
  final List<T> items;
  final String Function(T) idOf;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final String? accountScope;

  @override
  State<KiptoAnimatedSliverList<T>> createState() =>
      _KiptoAnimatedSliverListState<T>();
}

class _KiptoAnimatedSliverListState<T>
    extends State<KiptoAnimatedSliverList<T>> {
  GlobalKey<SliverAnimatedListState> _listKey = GlobalKey();
  late List<T> _items;
  bool _reduced = false;
  bool _initialPending = true;
  final Map<String, double> _initialDelays = {};

  @override
  void initState() {
    super.initState();
    _items = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_initialPending) return;
      _initialPending = false;
      final state = _listKey.currentState;
      if (state == null) return;
      _items.addAll(widget.items);
      for (var i = 0; i < _items.length; i++) {
        final delay = i < 5 ? 30 * i : 0;
        if (i < 5) {
          _initialDelays[widget.idOf(_items[i])] = delay / (280 + delay);
        }
        state.insertItem(
          i,
          duration: i < 5 ? Duration(milliseconds: 280 + delay) : Duration.zero,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced && !_reduced) {
      // Drop any outgoing animation when the user disables motion mid-flight.
      _listKey = GlobalKey();
      _items = List.of(widget.items);
      _initialPending = false;
      _initialDelays.clear();
    }
    _reduced = reduced;
  }

  @override
  void didUpdateWidget(covariant KiptoAnimatedSliverList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.items.map(widget.idOf).toSet().length == widget.items.length);
    if (widget.accountScope != oldWidget.accountScope || _reduced) {
      _listKey = GlobalKey();
      _items = List.of(widget.items);
      _initialPending = false;
      _initialDelays.clear();
      return;
    }
    if (_initialPending) return;
    final state = _listKey.currentState;
    if (state == null) {
      _items = List.of(widget.items);
      return;
    }
    final wanted = widget.items.map(widget.idOf).toSet();
    void remove(int index) {
      final removed = _items.removeAt(index);
      _initialDelays.remove(widget.idOf(removed));
      final originalIndex = oldWidget.items.indexWhere(
        (item) => oldWidget.idOf(item) == widget.idOf(removed),
      );
      state.removeItem(
        index,
        (context, animation) => ExcludeSemantics(
          child: ExcludeFocus(
            child: IgnorePointer(
              child: HeroMode(
                enabled: false,
                child: _transition(
                  animation,
                  oldWidget.itemBuilder(context, removed, originalIndex),
                ),
              ),
            ),
          ),
        ),
        duration: AppDurations.slow,
      );
    }

    for (var i = _items.length - 1; i >= 0; i--) {
      if (!wanted.contains(widget.idOf(_items[i]))) remove(i);
    }
    for (var i = 0; i < widget.items.length; i++) {
      final next = widget.items[i];
      final id = widget.idOf(next);
      if (i < _items.length && widget.idOf(_items[i]) == id) {
        _items[i] = next;
        continue;
      }
      final previous = _items.indexWhere((item) => widget.idOf(item) == id);
      if (previous >= 0) remove(previous);
      _items.insert(i, next);
      state.insertItem(i, duration: AppDurations.slow);
    }
  }

  Widget _transition(
    Animation<double> animation,
    Widget child, {
    double delay = 0,
  }) {
    final eased = animation.drive(
      CurveTween(
        curve: delay == 0
            ? Curves.easeInOutCubic
            : Interval(delay, 1, curve: Curves.easeOutCubic),
      ),
    );
    return SizeTransition(
      sizeFactor: eased,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: eased,
        child: AnimatedBuilder(
          animation: eased,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, 12 * (1 - eased.value)),
            child: child,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SliverAnimatedList(
    key: _listKey,
    initialItemCount: _items.length,
    itemBuilder: (context, index, animation) => _transition(
      animation,
      KeyedSubtree(
        key: ValueKey(widget.idOf(_items[index])),
        child: widget.itemBuilder(context, _items[index], index),
      ),
      delay: _initialDelays[widget.idOf(_items[index])] ?? 0,
    ),
  );
}
