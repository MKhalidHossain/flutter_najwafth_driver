import 'package:flutter_najwafth_driver/core/utils/typedefs.dart';

final class DriverRequest {
  const DriverRequest({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.phone,
    required this.customerName,
    required this.item,
    required this.location,
    required this.orderId,
    required this.message,
    required this.status,
    this.orderDate,
    this.totalAmount,
    this.price,
    this.driverId,
    this.pickupAddress,
    this.pickupLat,
    this.pickupLng,
    this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String shopId;
  final String shopName;
  final String phone;
  final String customerName;
  final String item;
  final String location;
  final String orderId;
  final String message;
  final String status;
  final DateTime? orderDate;
  final double? totalAmount;
  final double? price;
  final String? driverId;
  final String? pickupAddress;
  final double? pickupLat;
  final double? pickupLng;
  final String? deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory DriverRequest.fromJson(JsonMap json) {
    return DriverRequest(
      id: _readId(json['_id'] ?? json['id']),
      shopId: _readId(json['shopId']),
      shopName: json['shopName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      item: json['item'] as String? ?? '',
      location: json['location'] as String? ?? '',
      orderId: _readId(json['orderId']),
      message: json['message'] as String? ?? '',
      status: _readStatus(json),
      orderDate: _readDate(json['orderDate']),
      totalAmount: _readDouble(json['totalAmount']),
      price: _readDouble(json['price']),
      driverId: _readNullableId(json['driver']),
      pickupAddress: _readAddress(
        json['pickupAddress'] ?? json['pickup'] ?? json['shopAddress'],
      ),
      pickupLat: _readDouble(json['pickupLat'] ?? json['pickupLatitude']),
      pickupLng: _readDouble(
        json['pickupLng'] ?? json['pickupLon'] ?? json['pickupLongitude'],
      ),
      deliveryAddress: _readAddress(
        json['deliveryAddress'] ??
            json['delivery'] ??
            json['dropoffAddress'] ??
            json['customerAddress'] ??
            json['address'],
      ),
      deliveryLat: _readDouble(json['deliveryLat'] ?? json['deliveryLatitude']),
      deliveryLng: _readDouble(
        json['deliveryLng'] ?? json['deliveryLon'] ?? json['deliveryLongitude'],
      ),
      createdAt: _readDate(json['createdAt']),
      updatedAt: _readDate(json['updatedAt']),
    );
  }
}

final class DriverRequestsPage {
  const DriverRequestsPage({
    required this.requests,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<DriverRequest> requests;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory DriverRequestsPage.fromList(List<DriverRequest> requests) {
    return DriverRequestsPage(
      requests: requests,
      page: 1,
      limit: requests.length,
      total: requests.length,
      totalPages: 1,
    );
  }

  factory DriverRequestsPage.fromJson(JsonMap json) {
    final rawRequests = json['requests'];
    final requests = rawRequests is List
        ? rawRequests
              .whereType<JsonMap>()
              .map(DriverRequest.fromJson)
              .toList(growable: false)
        : const <DriverRequest>[];

    return DriverRequestsPage(
      requests: requests,
      page: _readInt(json['page'], fallback: 1),
      limit: _readInt(json['limit'], fallback: requests.length),
      total: _readInt(json['total'], fallback: requests.length),
      totalPages: _readInt(
        json['totalPage'] ?? json['totalPages'],
        fallback: 1,
      ),
    );
  }
}

final class CreateDriverRequestPayload {
  const CreateDriverRequestPayload({
    required this.shopId,
    required this.shopName,
    required this.phone,
    required this.orderDate,
    required this.totalAmount,
    required this.customerName,
    required this.item,
    required this.location,
    required this.orderId,
    required this.price,
    required this.message,
  });

  final String shopId;
  final String shopName;
  final String phone;
  final DateTime orderDate;
  final num totalAmount;
  final String customerName;
  final String item;
  final String location;
  final String orderId;
  final num price;
  final String message;

  JsonMap toJson() {
    return {
      'shopId': shopId,
      'shopName': shopName,
      'phone': phone,
      'orderDate': orderDate.toUtc().toIso8601String(),
      'totalAmount': totalAmount,
      'customerName': customerName,
      'item': item,
      'location': location,
      'orderId': orderId,
      'price': price,
      'message': message,
    };
  }
}

final class UpdateDriverRequestPayload {
  const UpdateDriverRequestPayload({
    this.status,
    this.shopName,
    this.phone,
    this.orderDate,
    this.totalAmount,
    this.customerName,
    this.item,
    this.location,
    this.orderId,
    this.price,
    this.message,
  });

  final String? status;
  final String? shopName;
  final String? phone;
  final DateTime? orderDate;
  final num? totalAmount;
  final String? customerName;
  final String? item;
  final String? location;
  final String? orderId;
  final num? price;
  final String? message;

  JsonMap toJson() {
    return {
      if (status != null) 'status': status,
      if (shopName != null) 'shopName': shopName,
      if (phone != null) 'phone': phone,
      if (orderDate != null) 'orderDate': orderDate!.toUtc().toIso8601String(),
      if (totalAmount != null) 'totalAmount': totalAmount,
      if (customerName != null) 'customerName': customerName,
      if (item != null) 'item': item,
      if (location != null) 'location': location,
      if (orderId != null) 'orderId': orderId,
      if (price != null) 'price': price,
      if (message != null) 'message': message,
    };
  }
}

String _readId(Object? value) => _readNullableId(value) ?? '';

String? _readNullableId(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is JsonMap) {
    return value['_id'] as String? ?? value['id'] as String?;
  }
  return value.toString();
}

DateTime? _readDate(Object? value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}

double? _readDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String? _readAddress(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is JsonMap) {
    final parts = [
      value['address'],
      value['street'],
      value['city'],
      value['state'],
      value['country'],
      value['zipCode'],
    ].whereType<String>().where((part) => part.trim().isNotEmpty);
    final joined = parts.join(', ');
    return joined.isEmpty ? null : joined;
  }
  return value.toString();
}

int _readInt(Object? value, {required int fallback}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

String _readStatus(JsonMap json) {
  final drStatus = json['status'] as String? ?? 'pending';
  
  // Only override if the driver request is accepted.
  if (drStatus != 'accepted') return drStatus;

  final order = json['orderId'];
  if (order is JsonMap) {
    final orderStatus = order['status'] as String?;
    if (orderStatus != null) {
      final os = orderStatus.toLowerCase();
      // If the order has progressed beyond pending, use the order's status
      if (os == 'picked_up' || os == 'in_progress' || os == 'shipped' || os == 'on_way' || os == 'delivered') {
        return orderStatus;
      }
    }
  }
  return drStatus;
}
