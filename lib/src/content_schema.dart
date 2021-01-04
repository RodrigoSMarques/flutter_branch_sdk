part of flutter_branch_sdk;

enum BranchContentSchema {
  COMMERCE_AUCTION,
  COMMERCE_BUSINESS,
  COMMERCE_OTHER,
  COMMERCE_PRODUCT,
  COMMERCE_RESTAURANT,
  COMMERCE_SERVICE,
  COMMERCE_TRAVEL_FLIGHT,
  COMMERCE_TRAVEL_HOTEL,
  COMMERCE_TRAVEL_OTHER,
  GAME_STATE,
  MEDIA_IMAGE,
  MEDIA_MIXED,
  MEDIA_MUSIC,
  MEDIA_OTHER,
  MEDIA_VIDEO,
  OTHER,
  TEXT_ARTICLE,
  TEXT_BLOG,
  TEXT_OTHER,
  TEXT_RECIPE,
  TEXT_REVIEW,
  TEXT_SEARCH_RESULTS,
  TEXT_STORY,
  TEXT_TECHNICAL_DOC
}

BranchContentSchema getValueContentSchema(String name) {
  BranchContentSchema schema;
  for (BranchContentSchema contentSchema in BranchContentSchema.values) {
    if (contentSchema.toString() == name) {
      schema = contentSchema;
      break;
    }
  }
  return schema;
}

String getContentSchemaString(BranchContentSchema contentSchema) {
  if (contentSchema == null) return "OTHER";
  return contentSchema.toString().split('.').last;
}
