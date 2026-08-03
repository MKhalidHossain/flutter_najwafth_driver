import 'package:flutter_najwafth_driver/features/driver_requests/application/driver_request_event.dart';
import 'package:flutter_najwafth_driver/features/driver_requests/domain/driver_request.dart';
import 'package:flutter_najwafth_driver/features/user/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('user profile reads persisted online availability', () {
    final profile = UserProfile.fromJson(const {
      '_id': 'driver-1',
      'role': 'driver',
      'isOnline': true,
    });

    expect(profile.isOnline, isTrue);
  });

  test('completed driver requests appear as delivered in the driver UI', () {
    final request = DriverRequest.fromJson(const {
      '_id': 'request-1',
      'shopId': 'shop-1',
      'status': 'completed',
    });

    expect(request.status, 'delivered');
  });

  test(
    'acceptance emits an event that can switch and refresh dashboard tabs',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(driverRequestEventProvider.notifier)
          .emit(type: 'driver_request_accepted', driverRequestId: 'request-1');

      final event = container.read(driverRequestEventProvider);
      expect(event?.type, 'driver_request_accepted');
      expect(event?.driverRequestId, 'request-1');
    },
  );
}
