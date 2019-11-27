part of flutter_branch_sdk;

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

enum BranchCurrencyType { USD, EUR, BRL, CAD }

String getCurrencyTypeString(BranchCurrencyType currencyType) {
  //if (currencyType == null) return "USD";
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
  BranchContentSchema contentSchema;

  /// Quantity of the thing associated with the qualifying content item
  double quantity;

  /// Any price associated with the qualifying content item
  double price;

  /// Currency type associated with the price
  BranchCurrencyType currencyType;

  /// Holds any associated store keeping unit
  String sku;

  /// Name of any product specified by this metadata
  String productName;

  /// Any brand name associated with this metadata
  String productBrand;

  /// Category of product if this metadata is for a product
  /// Value should be one of the enumeration from {@link ProductCategory}
  BranchProductCategory productCategory;

  /// Condition of the product item. Value is one of the enum constants from {@link CONDITION}
  BranchCondition condition;

  /// Variant of product if this metadata is for a product
  String productVariant;

  /// Rating for the qualifying content item
  double rating;

  /// Average rating for the qualifying content item
  double ratingAverage;

  /// Total number of ratings for the qualifying content item
  int ratingCount;

  ///Maximum ratings for the qualifying content item
  double ratingMax;

  /// Street address associated with the qualifying content item
  String _addressStreet;

  /// City name associated with the qualifying content item
  String _addressCity;

  /// Region or province name associated with the qualifying content item
  String _addressRegion;

  /// Country name associated with the qualifying content item
  String _addressCountry;

  /// Postal code associated with the qualifying content item
  String _addressPostalCode;

  /// Latitude value  associated with the qualifying content item
  double _latitude;

  /// Latitude value  associated with the qualifying content item
  double _longitude;
  List<String> _imageCaptions;
  Map<String, dynamic> customMetadata;

  BranchContentMetaData() {
    this.customMetadata = {};
  }

  String _getProductConditionString(BranchCondition productCondition) {
    if (productCondition == null) return "OTHER";
    return productCondition.toString().split('.').last;
  }

  String _getProductCategoryString(BranchProductCategory productCategory) {
    if (productCategory == null) return "Home & Garden";
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

  BranchContentMetaData addImageCaptions(List<dynamic> captions) {
    this._imageCaptions = captions;
    return this;
  }

  BranchContentMetaData addCustomMetadata(String key, dynamic value) {
    customMetadata[key] = value;
    return this;
  }

  BranchContentMetaData setAddress(
      {String street,
      String city,
      String region,
      String country,
      String postalCode}) {
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
    if (this.quantity != null && this.quantity > 0)
      ret["quantity"] = this.quantity;
    if (this.price != null && this.price > 0) ret["price"] = this.price;
    if (this.currencyType != null)
      ret["currency"] = getCurrencyTypeString(this.currencyType);
    if (this.sku != null && this.sku.isNotEmpty) ret["sku"] = this.sku;
    if (this.productName != null && this.productName.isNotEmpty)
      ret["product_name"] = this.productName;
    if (this.productBrand != null && this.productBrand.isNotEmpty)
      ret["product_brand"] = this.productBrand;
    if (this.productCategory != null)
      ret["product_category"] = _getProductCategoryString(this.productCategory);
    if (this.productVariant != null && this.productVariant.isNotEmpty)
      ret["product_variant"] = this.productVariant;
    if (this.condition != null)
      ret["condition"] = _getProductConditionString(this.condition);
    if (this.ratingAverage != null && this.ratingAverage > 0)
      ret["rating_average"] = this.ratingAverage;
    if (this.ratingCount != null && this.ratingCount > 0)
      ret["rating_count"] = this.ratingCount;
    if (this.ratingMax != null && this.ratingMax > 0)
      ret["rating_max"] = this.ratingMax;
    if (this.rating != null && this.rating > 0) ret["rating"] = this.rating;
    if (this._addressStreet != null && this._addressStreet.isNotEmpty)
      ret["address_street"] = this._addressStreet;
    if (this._addressCity != null && this._addressCity.isNotEmpty)
      ret["address_city"] = this._addressCity;
    if (this._addressRegion != null && this._addressRegion.isNotEmpty)
      ret["address_region"] = this._addressRegion;
    if (this._addressCountry != null && this._addressCountry.isNotEmpty)
      ret["address_country"] = this._addressCountry;
    if (this._addressPostalCode != null && this._addressPostalCode.isNotEmpty)
      ret["address_postal_code"] = this._addressPostalCode;
    if (this._latitude != null) ret["latitude"] = this._latitude;
    if (this._longitude != null) ret["longitude"] = this._longitude;
    if (this._imageCaptions != null && _imageCaptions.isNotEmpty)
      ret["image_captions"] = this._imageCaptions;
    if (this.customMetadata != null && this.customMetadata.isNotEmpty) {
      ret["customMetadata"] = this.customMetadata;
    }
    return ret;
  }
}
