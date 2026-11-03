import 'dart:collection';

/// Represents an error event captured while offline or during app runtime.
class ErrorEvent {
  const ErrorEvent({
    required this.id,
    required this.message,
    required this.stackTrace,
    required this.timestamp,
    this.reason,
    this.fatal = false,
    this.extras = const {},
  });

  final String id;
  final String message;
  final String stackTrace;
  final DateTime timestamp;
  final String? reason;
  final bool fatal;
  final Map<String, dynamic> extras;

  Map<String, dynamic> toJson() => {
        'id': id,
        'message': message,
        'stackTrace': stackTrace,
        'timestamp': timestamp.toIso8601String(),
        'reason': reason,
        'fatal': fatal,
        'extras': extras,
      };

  factory ErrorEvent.fromJson(Map<String, dynamic> json) {
    return ErrorEvent(
      id: json['id'] as String,
      message: json['message'] as String,
      stackTrace: json['stackTrace'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      reason: json['reason'] as String?,
      fatal: json['fatal'] as bool? ?? false,
      extras: (json['extras'] as Map<String, dynamic>?) ?? const {},
    );
  }
}

/// In-memory & bounded queue for offline error logs to prevent memory leaks.
class OfflineErrorQueue {
  OfflineErrorQueue({this.maxCapacity = 50});

  final int maxCapacity;
  final Queue<ErrorEvent> _queue = Queue<ErrorEvent>();

  int get length => _queue.length;
  bool get isEmpty => _queue.isEmpty;
  bool get isNotEmpty => _queue.isNotEmpty;

  /// Enqueues an error event. If capacity is exceeded, drops oldest (FIFO).
  void enqueue(ErrorEvent event) {
    if (_queue.length >= maxCapacity) {
      _queue.removeFirst();
    }
    _queue.addLast(event);
  }

  /// Drains and returns all queued error events.
  List<ErrorEvent> drain() {
    final list = _queue.toList();
    _queue.clear();
    return list;
  }

  /// Clears the queue.
  void clear() {
    _queue.clear();
  }

  List<ErrorEvent> peekAll() => List.unmodifiable(_queue);
}
