import 'package:url_launcher/url_launcher.dart';

final class MapPoint {
  const MapPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  String get query => '$latitude,$longitude';
}

Future<bool> openMapRoute({
  MapPoint? pickupPoint,
  MapPoint? deliveryPoint,
  String? pickupAddress,
  String? deliveryAddress,
  String? fallbackLocation,
}) async {
  final origin = pickupPoint?.query ?? _cleanLocation(pickupAddress);
  final destination = deliveryPoint?.query ?? _cleanLocation(deliveryAddress);
  final fallback = _cleanLocation(fallbackLocation);

  Uri? uri;
  if (origin != null && destination != null && origin != destination) {
    uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'origin': origin,
      'destination': destination,
      'travelmode': 'driving',
    });
  } else {
    final query = destination ?? origin ?? fallback;
    if (query == null) return false;

    uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });
  }

  try {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Object {
    return false;
  }
}

String? _cleanLocation(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty || trimmed == '—') return null;
  return trimmed;
}
