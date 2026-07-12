typedef TimeSource = Duration Function();

class RoundTimer {
  RoundTimer({TimeSource? now}) : _now = now ?? _defaultNow;

  static final Stopwatch _systemClock = Stopwatch()..start();

  final TimeSource _now;

  Duration _accumulated = Duration.zero;
  Duration? _startedAt;

  bool get isRunning => _startedAt != null;

  Duration get elapsed {
    final startedAt = _startedAt;

    if (startedAt == null) {
      return _accumulated;
    }

    final currentInterval = _safeDifference(_now(), startedAt);
    return _accumulated + currentInterval;
  }

  void start() {
    if (isRunning) {
      return;
    }

    _startedAt = _now();
  }

  void stop() {
    final startedAt = _startedAt;

    if (startedAt == null) {
      return;
    }

    _accumulated += _safeDifference(_now(), startedAt);
    _startedAt = null;
  }

  void reset() {
    _accumulated = Duration.zero;
    _startedAt = null;
  }

  static Duration _defaultNow() {
    return _systemClock.elapsed;
  }

  static Duration _safeDifference(
      Duration later,
      Duration earlier,
      ) {
    final difference = later - earlier;

    if (difference.isNegative) {
      return Duration.zero;
    }

    return difference;
  }
}
