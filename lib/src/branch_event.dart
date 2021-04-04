part of flutter_branch_sdk_objects;
/*
* Enum for creating Branch events for tracking and analytical purpose.
* Enum class represent a standard or custom BranchEvents. Standard Branch events are defined with BRANCH_STANDARD_EVENT}.
* Please use #logEvent() method to log the events for tracking.
*/

enum BranchStandardEvent {
  // Commerce events
  ADD_TO_CART,
  ADD_TO_WISHLIST,
  VIEW_CART,
  INITIATE_PURCHASE,
  ADD_PAYMENT_INFO,
  PURCHASE,
  SPEND_CREDITS,
  // Content Events
  SEARCH,
  VIEW_ITEM,
  VIEW_ITEMS,
  RATE,
  SHARE,
  // User Lifecycle Events
  COMPLETE_REGISTRATION,
  COMPLETE_TUTORIAL,
  ACHIEVE_LEVEL,
  UNLOCK_ACHIEVEMENT
}

String getBranchStandardEventString(BranchStandardEvent branchStandardEvent) {
  return branchStandardEvent.toString().split('.').last;
}

enum BranchEventAdType { BANNER, INTERSTITIAL, REWARDED_VIDEO, NATIVE }

String getBranchEventAdTypeString(BranchEventAdType branchEventAdType) {
  return branchEventAdType.toString().split('.').last;
}

class BranchEvent {
  String _eventName = '';
  bool _isStandardEvent = true;
  String transactionID = '';
  BranchCurrencyType? currency;
  double revenue = -1;
  double shipping = -1;
  double tax = -1;
  String coupon = '';
  String affiliation = '';
  String eventDescription = '';
  String searchQuery = '';
  BranchEventAdType? adType;
  Map<String, String> _customData = {};

  BranchEvent.standardEvent(BranchStandardEvent branchStandardEvent) {
    this._eventName = getBranchStandardEventString(branchStandardEvent);
    this._isStandardEvent = true;
  }

  BranchEvent.customEvent(this._eventName) {
    this._isStandardEvent = false;
  }

  String get eventName => _eventName;

  void addCustomData(String key, dynamic value) {
    this._customData[key] = value;
  }

  void removeCustomData(String key) {
    this._customData.remove(key);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = Map<String, dynamic>();

    ret["eventName"] = this._eventName;
    ret["isStandardEvent"] = this._isStandardEvent;
    if (this.transactionID.isNotEmpty)
      ret["transactionID"] = this.transactionID;
    if (this.currency != null)
      ret["currency"] = getCurrencyTypeString(this.currency!);
    if (this.revenue != -1) ret["revenue"] = this.revenue;
    if (this.shipping != -1) ret["shipping"] = this.shipping;
    if (this.tax != -1) ret["tax"] = this.tax;
    if (this.coupon.isNotEmpty) ret["coupon"] = this.coupon;
    if (this.affiliation.isNotEmpty) ret["affiliation"] = this.affiliation;
    if (this.eventDescription.isNotEmpty)
      ret["eventDescription"] = this.eventDescription;
    if (this.searchQuery.isNotEmpty) ret["searchQuery"] = this.searchQuery;
    if (this.adType != null)
      ret["adType"] = getBranchEventAdTypeString(this.adType!);
    if (this._customData.isNotEmpty) ret["customData"] = _customData;
    return ret;
  }
}
