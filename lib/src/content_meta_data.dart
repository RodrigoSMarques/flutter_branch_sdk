part of flutter_branch_sdk_objects;

enum BranchCondition {
  OTHER,
  NEW,
  GOOD,
  FAIR,
  POOR,
  USED,
  REFURBISHED,
  EXCELLENT
}

enum BranchCurrencyType {
  AED,
  AFN,
  ALL,
  AMD,
  ANG,
  AOA,
  ARS,
  AUD,
  AWG,
  AZN,
  BAM,
  BBD,
  BDT,
  BGN,
  BHD,
  BIF,
  BMD,
  BND,
  BOB,
  BOV,
  BRL,
  BSD,
  BTN,
  BWP,
  BYN,
  BYR,
  BZD,
  CAD,
  CDF,
  CHE,
  CHF,
  CHW,
  CLF,
  CLP,
  CNY,
  COP,
  COU,
  CRC,
  CUC,
  CUP,
  CVE,
  CZK,
  DJF,
  DKK,
  DOP,
  DZD,
  EGP,
  ERN,
  ETB,
  EUR,
  FJD,
  FKP,
  GBP,
  GEL,
  GHS,
  GIP,
  GMD,
  GNF,
  GTQ,
  GYD,
  HKD,
  HNL,
  HRK,
  HTG,
  HUF,
  IDR,
  ILS,
  INR,
  IQD,
  IRR,
  ISK,
  JMD,
  JOD,
  JPY,
  KES,
  KGS,
  KHR,
  KMF,
  KPW,
  KRW,
  KWD,
  KYD,
  KZT,
  LAK,
  LBP,
  LKR,
  LRD,
  LSL,
  LYD,
  MAD,
  MDL,
  MGA,
  MKD,
  MMK,
  MNT,
  MOP,
  MRO,
  MUR,
  MVR,
  MWK,
  MXN,
  MXV,
  MYR,
  MZN,
  NAD,
  NGN,
  NIO,
  NOK,
  NPR,
  NZD,
  OMR,
  PAB,
  PEN,
  PGK,
  PHP,
  PKR,
  PLN,
  PYG,
  QAR,
  RON,
  RSD,
  RUB,
  RWF,
  SAR,
  SBD,
  SCR,
  SDG,
  SEK,
  SGD,
  SHP,
  SLL,
  SOS,
  SRD,
  SSP,
  STD,
  SYP,
  SZL,
  THB,
  TJS,
  TMT,
  TND,
  TOP,
  TRY,
  TTD,
  TWD,
  TZS,
  UAH,
  UGX,
  USD,
  USN,
  UYI,
  UYU,
  UZS,
  VEF,
  VND,
  VUV,
  WST,
  XAF,
  XAG,
  XAU,
  XBA,
  XBB,
  XBC,
  XBD,
  XCD,
  XDR,
  XFU,
  XOF,
  XPD,
  XPF,
  XPT,
  XSU,
  XTS,
  XUA,
  XXX,
  YER,
  ZAR,
  ZMW
}

String getCurrencyTypeString(BranchCurrencyType currencyType) {
  return currencyType.toString().split('.').last;
}

enum BranchProductCategory {
  ANIMALS_AND_PET_SUPPLIES,
  APPAREL_AND_ACCESSORIES,
  ARTS_AND_ENTERTAINMENT,
  BABY_AND_TODDLER,
  BUSINESS_AND_INDUSTRIAL,
  CAMERAS_AND_OPTICS,
  ELECTRONICS,
  FOOD_BEVERAGES_AND_TOBACCO,
  FURNITURE,
  HARDWARE,
  HEALTH_AND_BEAUTY,
  HOME_AND_GARDEN,
  LUGGAGE_AND_BAGS,
  MATURE,
  MEDIA,
  OFFICE_SUPPLIES,
  RELIGIOUS_AND_CEREMONIAL,
  SOFTWARE,
  SPORTING_GOODS,
  TOYS_AND_GAMES,
  VEHICLES_AND_PARTS,
}

/*
Class for describing metadata for a piece of content represented by a FlutterBranchUniversalObject
*/
class BranchContentMetaData {
  /// Schema for the qualifying content item. Please see [BranchContentSchema]
  BranchContentSchema? contentSchema;

  /// Quantity of the thing associated with the qualifying content item
  double quantity = 0;

  /// Any price associated with the qualifying content item
  double price = 0;

  /// Currency type associated with the price
  BranchCurrencyType? currencyType;

  /// Holds any associated store keeping unit
  String sku = '';

  /// Name of any product specified by this metadata
  String productName = '';

  /// Any brand name associated with this metadata
  String productBrand = '';

  /// Category of product if this metadata is for a product
  /// Value should be one of the enumeration from {@link ProductCategory}
  BranchProductCategory? productCategory;

  /// Condition of the product item. Value is one of the enum constants from {@link CONDITION}
  BranchCondition? condition;

  /// Variant of product if this metadata is for a product
  String productVariant = '';

  /// Rating for the qualifying content item
  double rating = 0;

  /// Average rating for the qualifying content item
  double ratingAverage = 0;

  /// Total number of ratings for the qualifying content item
  int ratingCount = 0;

  ///Maximum ratings for the qualifying content item
  double ratingMax = 0;

  /// Street address associated with the qualifying content item
  String _addressStreet = '';

  /// City name associated with the qualifying content item
  String _addressCity = '';

  /// Region or province name associated with the qualifying content item
  String _addressRegion = '';

  /// Country name associated with the qualifying content item
  String _addressCountry = '';

  /// Postal code associated with the qualifying content item
  String _addressPostalCode = '';

  /// Latitude value  associated with the qualifying content item
  double _latitude = -1;

  /// Latitude value  associated with the qualifying content item
  double _longitude = -1;

  List<String> _imageCaptions = const [];
  Map<String, dynamic> _customMetadata = {};

  String? _getProductConditionString(BranchCondition? productCondition) {
    if (productCondition == null) return null;
    return productCondition.toString().split('.').last;
  }

  String? _getProductCategoryString(BranchProductCategory? productCategory) {
    if (productCategory == null) return null;
    switch (productCategory) {
      case BranchProductCategory.ANIMALS_AND_PET_SUPPLIES:
        return "Animals & Pet Supplies";
      case BranchProductCategory.APPAREL_AND_ACCESSORIES:
        return "Apparel & Accessories";
      case BranchProductCategory.ARTS_AND_ENTERTAINMENT:
        return "Arts & Entertainment";
      case BranchProductCategory.BABY_AND_TODDLER:
        return "Baby & Toddler";
      case BranchProductCategory.BUSINESS_AND_INDUSTRIAL:
        return "Business & Industrial";
      case BranchProductCategory.CAMERAS_AND_OPTICS:
        return "Cameras & Optics";
      case BranchProductCategory.ELECTRONICS:
        return "Electronics";
      case BranchProductCategory.FOOD_BEVERAGES_AND_TOBACCO:
        return "Food, Beverages & Tobacco";
      case BranchProductCategory.FURNITURE:
        return "Furniture";
      case BranchProductCategory.HARDWARE:
        return "Hardware";
      case BranchProductCategory.HEALTH_AND_BEAUTY:
        return "Health & Beauty";
      case BranchProductCategory.HOME_AND_GARDEN:
        return "Home & Garden";
      case BranchProductCategory.LUGGAGE_AND_BAGS:
        return "Luggage & Bags";
      case BranchProductCategory.MATURE:
        return "Mature";
      case BranchProductCategory.MEDIA:
        return "Media";
      case BranchProductCategory.OFFICE_SUPPLIES:
        return "Office Supplies";
      case BranchProductCategory.RELIGIOUS_AND_CEREMONIAL:
        return "Religious & Ceremonial";
      case BranchProductCategory.SOFTWARE:
        return "Software";
      case BranchProductCategory.SPORTING_GOODS:
        return "Sporting Goods";
      case BranchProductCategory.TOYS_AND_GAMES:
        return "Toys & Games";
      case BranchProductCategory.VEHICLES_AND_PARTS:
        return "Vehicles & Parts";
      default:
        return "Home & Garden";
    }
  }

  BranchContentMetaData addImageCaptions(List<String> captions) {
    this._imageCaptions = captions;
    return this;
  }

  BranchContentMetaData addCustomMetadata(String key, dynamic value) {
    this._customMetadata[key] = value;
    return this;
  }

  BranchContentMetaData setAddress(
      {String? street,
      String? city,
      String? region,
      String? country,
      String? postalCode}) {
    if (street != null) this._addressStreet = street;
    if (city != null) this._addressCity = city;
    if (region != null) this._addressRegion = region;
    if (country != null) this._addressCountry = country;
    if (postalCode != null) this._addressPostalCode = postalCode;
    return this;
  }

  BranchContentMetaData setLocation(double latitude, double longitude) {
    this._latitude = latitude;
    this._longitude = longitude;
    return this;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = Map<String, dynamic>();
    if (this.contentSchema != null)
      ret["content_schema"] = getContentSchemaString(this.contentSchema);
    if (this.quantity > 0) ret["quantity"] = this.quantity;
    if (this.price > 0) ret["price"] = this.price;
    if (this.currencyType != null)
      ret["currency"] = getCurrencyTypeString(this.currencyType!);
    if (this.sku.isNotEmpty) ret["sku"] = this.sku;
    if (this.productName.isNotEmpty) ret["product_name"] = this.productName;
    if (this.productBrand.isNotEmpty) ret["product_brand"] = this.productBrand;
    if (this.productCategory != null)
      ret["product_category"] = _getProductCategoryString(this.productCategory);
    if (this.productVariant.isNotEmpty)
      ret["product_variant"] = this.productVariant;
    if (this.condition != null)
      ret["condition"] = _getProductConditionString(this.condition);
    if (this.ratingAverage > 0) ret["rating_average"] = this.ratingAverage;
    if (this.ratingCount > 0) ret["rating_count"] = this.ratingCount;
    if (this.ratingMax > 0) ret["rating_max"] = this.ratingMax;
    if (this.rating > 0) ret["rating"] = this.rating;
    if (this._addressStreet.isNotEmpty)
      ret["address_street"] = this._addressStreet;
    if (this._addressCity.isNotEmpty) ret["address_city"] = this._addressCity;
    if (this._addressRegion.isNotEmpty)
      ret["address_region"] = this._addressRegion;
    if (this._addressCountry.isNotEmpty)
      ret["address_country"] = this._addressCountry;
    if (this._addressPostalCode.isNotEmpty)
      ret["address_postal_code"] = this._addressPostalCode;
    if (this._latitude > -1) ret["latitude"] = this._latitude;
    if (this._longitude > -1) ret["longitude"] = this._longitude;
    if (_imageCaptions.isNotEmpty) ret["image_captions"] = this._imageCaptions;
    if (this._customMetadata.isNotEmpty) {
      ret["customMetadata"] = this._customMetadata;
    }
    return ret;
  }
}
