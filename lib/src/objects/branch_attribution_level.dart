enum BranchAttributionLevel {
  /// Full Attribution (Default)
  /// - Advertising Ids
  /// - Device Ids
  /// - Local IP
  /// - Persisted Non-Aggregate Ids
  /// - Persisted Aggregate Ids
  /// - Ads Postbacks / Webhooks
  /// - Data Integrations Webhooks
  /// - SAN Callouts
  /// - Privacy Frameworks
  /// - Deep Linking
  FULL,

  /// Reduced Attribution (Non-Ads + Privacy Frameworks)
  /// - Device Ids
  /// - Local IP
  /// - Data Integrations Webhooks
  /// - Privacy Frameworks
  /// - Deep Linking
  REDUCED,

  /// Minimal Attribution - Analytics Only
  /// - Device Ids
  /// - Local IP
  /// - Data Integrations Webhooks
  /// - Deep Linking
  MINIMAL,

  /// No Attribution - No Analytics (GDPR, CCPA)
  /// - Only Deterministic Deep Linking
  /// - Disables all other Branch requests
  NONE
}

String getBranchAttributionLevelString(
    BranchAttributionLevel branchAttributionLevel) {
  return branchAttributionLevel.toString().split('.').last;
}
