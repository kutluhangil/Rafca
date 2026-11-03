import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/features/capture/state/capture_notifier.dart';
import 'package:rafca/features/capture/state/capture_state.dart';

void main() {
  group('CaptureState', () {
    test('CaptureCapturing canShoot logic matches leveling and stability', () {
      const leveledAndStable = CaptureCapturing(
        isLeveled: true,
        isStable: true,
      );
      expect(leveledAndStable.canShoot, isTrue);

      const unlevel = CaptureCapturing(
        isLeveled: false,
        isStable: true,
      );
      expect(unlevel.canShoot, isFalse);

      const unstable = CaptureCapturing(
        isLeveled: true,
        isStable: false,
      );
      expect(unstable.canShoot, isFalse);
    });

    test('CaptureController updateSensors enforces 7 degree tolerance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(captureControllerProvider.notifier);

      // Force state to Capturing
      controller.state = const CaptureCapturing();

      // Case 1: Within +/- 7 degrees
      controller.updateSensors(
        rollDegrees: 4.5,
        pitchDegrees: -5.0,
        isStable: true,
      );

      var state = container.read(captureControllerProvider) as CaptureCapturing;
      expect(state.isLeveled, isTrue);
      expect(state.canShoot, isTrue);

      // Case 2: Exceeding 7 degrees roll
      controller.updateSensors(
        rollDegrees: 8.2,
        pitchDegrees: 2.0,
        isStable: true,
      );

      state = container.read(captureControllerProvider) as CaptureCapturing;
      expect(state.isLeveled, isFalse);
      expect(state.canShoot, isFalse);

      // Case 3: Exceeding 7 degrees pitch
      controller.updateSensors(
        rollDegrees: -3.0,
        pitchDegrees: -7.5,
        isStable: true,
      );

      state = container.read(captureControllerProvider) as CaptureCapturing;
      expect(state.isLeveled, isFalse);
      expect(state.canShoot, isFalse);
    });
  });
}
