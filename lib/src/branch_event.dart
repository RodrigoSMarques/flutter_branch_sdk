part of flutter_branch_sdk;

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
  BranchStandardEvent _branchStandardEvent;
  String _eventName;
  bool _isStandardEvent;
  String transactionID;
  BranchCurrencyType currency;
  double revenue;
  double shipping;
  double tax;
  String coupon;
  String affiliation;
  String eventDescription;
  String searchQuery;
  BranchEventAdType adType;
  Map<String, String> _customData;

  BranchEvent.standardEvent(this._branchStandardEvent) {
    this._eventName = getBranchStandardEventString(this._branchStandardEvent);
    this._isStandardEvent = true;
    this._customData = {};
  }

  BranchEvent.customEvent(this._eventName) {
    this._isStandardEvent = false;
    this._customData = {};
  }

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
    if (this.transactionID != null && this.transactionID.isNotEmpty)
      ret["transactionID"] = this.transactionID;
    if (this.currency != null)
      ret["currency"] = getCurrencyTypeString(this.currency);
    if (this.revenue != null) ret["revenue"] = this.revenue;
    if (this.shipping != null) ret["shipping"] = this.shipping;
    if (this.tax != null) ret["tax"] = this.tax;
    if (this.coupon != null && this.coupon.isNotEmpty)
      ret["coupon"] = this.coupon;
    if (this.affiliation != null && this.affiliation.isNotEmpty)
      ret["affiliation"] = this.affiliation;
    if (this.eventDescription != null && this.eventDescription.isNotEmpty)
      ret["eventDescription"] = this.eventDescription;
    if (this.searchQuery != null && this.searchQuery.isNotEmpty)
      ret["searchQuery"] = this.searchQuery;
    if (this.adType != null)
      ret["adType"] = getBranchEventAdTypeString(this.adType);
    if (this._customData != null && this._customData.isNotEmpty)
      ret["customData"] = _customData;
    return ret;
  }
}
