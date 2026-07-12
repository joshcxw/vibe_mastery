import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_mastery/game/round_timer.dart';

void main() {
  late Duration currentTime;
  late RoundTimer timer;

  setUp(() {
    currentTime = Duration.zero;
    timer = RoundTimer(now: () => currentTime);
  });

  test('starts at zero', () {
    expect(timer.elapsed, Duration.zero);
    expect(timer.isRunning, isFalse);
  });

  test('counts elapsed time while running', () {
    timer.start();
    currentTime = const Duration(seconds: 7);

    expect(timer.elapsed, const Duration(seconds: 7));
  });

  test('calling start twice does not count overlapping time', () {
    timer.start();

    currentTime = const Duration(seconds: 3);
    timer.start();

    currentTime = const Duration(seconds: 8);
    timer.stop();

    expect(timer.elapsed, const Duration(seconds: 8));
  });

  test('calling stop twice does not count time twice', () {
    timer.start();

    currentTime = const Duration(seconds: 5);
    timer.stop();

    currentTime = const Duration(seconds: 20);
    timer.stop();

    expect(timer.elapsed, const Duration(seconds: 5));
  });

  test('can resume without losing earlier elapsed time', () {
    timer.start();

    currentTime = const Duration(seconds: 4);
    timer.stop();

    currentTime = const Duration(seconds: 10);
    timer.start();

    currentTime = const Duration(seconds: 13);
    timer.stop();

    expect(timer.elapsed, const Duration(seconds: 7));
  });

  test('reset clears elapsed time and running state', () {
    timer.start();

    currentTime = const Duration(seconds: 9);
    timer.reset();

    expect(timer.elapsed, Duration.zero);
    expect(timer.isRunning, isFalse);
  });

  test('clock moving backward does not create negative time', () {
    currentTime = const Duration(seconds: 10);
    timer.start();

    currentTime = const Duration(seconds: 5);
    timer.stop();

    expect(timer.elapsed, Duration.zero);
  });
}