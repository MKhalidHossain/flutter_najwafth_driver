import 'package:flutter_riverpod/flutter_riverpod.dart';

final driverRequestEventProvider =
    NotifierProvider<DriverRequestEventNotifier, DriverRequestEvent?>(
      DriverRequestEventNotifier.new,
    );

final class DriverRequestEvent {
  const DriverRequestEvent({
    required this.sequence,
    required this.type,
    this.driverRequestId,
  });

  final int sequence;
  final String type;
  final String? driverRequestId;
}

final class DriverRequestEventNotifier extends Notifier<DriverRequestEvent?> {
  int _sequence = 0;

  @override
  DriverRequestEvent? build() => null;

  void emit({required String type, String? driverRequestId}) {
    state = DriverRequestEvent(
      sequence: ++_sequence,
      type: type,
      driverRequestId: driverRequestId,
    );
  }
}
