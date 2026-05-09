import 'package:flutter_najwafth_driver/core/errors/result.dart';
import 'package:flutter_najwafth_driver/core/network/api_client.dart';
import 'package:flutter_najwafth_driver/core/network/network_providers.dart';
import 'package:flutter_najwafth_driver/core/utils/typedefs.dart';
import 'package:flutter_najwafth_driver/features/driver_requests/domain/driver_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final driverApiProvider = Provider<DriverApi>((ref) {
  return DriverApi(ref.watch(apiClientProvider));
});

final class DriverApi {
  const DriverApi(this._apiClient);

  static const _basePath = '/api/v1/driver-request';

  final ApiClient _apiClient;

  Future<Result<DriverRequestsPage>> getDriverRequests({
    int page = 1,
    int limit = 10,
  }) {
    return _apiClient.get(
      '$_basePath/driver-requests',
      queryParameters: {'page': page, 'limit': limit},
      parser: (data) => DriverRequestsPage.fromJson(
        data['data'] as JsonMap? ?? const <String, dynamic>{},
      ),
    );
  }

  Future<Result<DriverRequest>> getDriverRequestById(String driverRequestId) {
    return _apiClient.get(
      '$_basePath/driver-requests/$driverRequestId',
      parser: (data) => DriverRequest.fromJson(data['data'] as JsonMap),
    );
  }

  Future<Result<DriverRequestsPage>> getShopDriverRequests(String shopId) {
    return _apiClient.get(
      '$_basePath/driver-requests/shop/$shopId',
      parser: (data) =>
          DriverRequestsPage.fromList(_readRequestList(data['data'])),
    );
  }

  Future<Result<DriverRequestsPage>> getDriverRequestsByDriver(
    String driverId,
  ) {
    return _apiClient.get(
      '$_basePath/driver-requests/driver/$driverId',
      parser: (data) =>
          DriverRequestsPage.fromList(_readRequestList(data['data'])),
    );
  }

  Future<Result<DriverRequest>> createDriverRequest(
    CreateDriverRequestPayload payload,
  ) {
    return _apiClient.post(
      '$_basePath/driver-request',
      data: payload.toJson(),
      parser: (data) => DriverRequest.fromJson(data['data'] as JsonMap),
    );
  }

  Future<Result<DriverRequest>> updateDriverRequest(
    String driverRequestId,
    UpdateDriverRequestPayload payload,
  ) {
    return _apiClient.patch(
      '$_basePath/driver-requests/$driverRequestId',
      data: payload.toJson(),
      parser: (data) => DriverRequest.fromJson(data['data'] as JsonMap),
    );
  }

  Future<Result<void>> deleteDriverRequest(String driverRequestId) {
    return _apiClient.delete(
      '$_basePath/driver-requests/$driverRequestId',
      parser: (_) {},
    );
  }

  Future<Result<DriverRequest>> assignDriverToRequest({
    required String driverRequestId,
    required String driverId,
  }) {
    return _apiClient.patch(
      '$_basePath/driver-requests/$driverRequestId/assign-driver',
      data: {'driverId': driverId},
      parser: (data) => DriverRequest.fromJson(data['data'] as JsonMap),
    );
  }

  Future<Result<DriverRequest>> updateDriverRequestStatus({
    required String driverRequestId,
    required String status,
  }) {
    return _apiClient.patch(
      '$_basePath/driver-requests/$driverRequestId/update-status',
      data: {'status': status},
      parser: (data) => DriverRequest.fromJson(data['data'] as JsonMap),
    );
  }

  // TODO: Add service methods only after backend supports online/offline,
  // pickup, on-way, delivered confirmation, earnings, history, vehicle
  // profile, location update, and route metadata endpoints.
}

List<DriverRequest> _readRequestList(Object? data) {
  if (data is! List) return const <DriverRequest>[];
  return data
      .whereType<JsonMap>()
      .map(DriverRequest.fromJson)
      .toList(growable: false);
}
