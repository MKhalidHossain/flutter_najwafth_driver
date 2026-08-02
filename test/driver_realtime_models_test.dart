import 'package:flutter_najwafth_driver/features/driver_requests/domain/driver_request.dart';
import 'package:flutter_najwafth_driver/features/user/domain/user_profile.dart';
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
}
