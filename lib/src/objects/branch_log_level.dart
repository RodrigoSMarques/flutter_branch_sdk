/// Defines the log level for Branch SDK logging.
///
/// Controls the verbosity of logs emitted by the native Branch SDK.
enum BranchLogLevel {
  /// All logs including verbose messages (most detailed)
  VERBOSE,

  /// Debug level logs for development
  DEBUG,

  /// Informational messages
  INFO,

  /// Warning messages only
  WARNING,

  /// Error messages only
  ERROR,

  /// No logging
  NONE
}

/// Extension to convert BranchLogLevel to string representation
extension BranchLogLevelExtension on BranchLogLevel {
  String get value {
    switch (this) {
      case BranchLogLevel.VERBOSE:
        return 'VERBOSE';
      case BranchLogLevel.DEBUG:
        return 'DEBUG';
      case BranchLogLevel.INFO:
        return 'INFO';
      case BranchLogLevel.WARNING:
        return 'WARNING';
      case BranchLogLevel.ERROR:
        return 'ERROR';
      case BranchLogLevel.NONE:
        return 'NONE';
    }
  }
}
