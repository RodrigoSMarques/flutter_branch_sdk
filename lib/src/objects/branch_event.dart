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
  final Map<String, String> _customData = {};

  BranchEvent.standardEvent(BranchStandardEvent branchStandardEvent) {
    _eventName = getBranchStandardEventString(branchStandardEvent);
    _isStandardEvent = true;
  }

  BranchEvent.customEvent(this._eventName) {
    _isStandardEvent = false;
  }

  String get eventName => _eventName;
  bool get isStandardEvent => _isStandardEvent;

  void addCustomData(String key, dynamic value) {
    _customData[key] = value;
  }

  void removeCustomData(String key) {
    _customData.remove(key);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = <String, dynamic>{};

    if (!kIsWeb) {
      ret["eventName"] = _eventName;
      ret["isStandardEvent"] = _isStandardEvent;
      if (transactionID.isNotEmpty) {
        ret["transactionID"] = transactionID;
      }
      if (currency != null) {
        ret["currency"] = getCurrencyTypeString(currency!);
      }
      if (revenue != -1) ret["revenue"] = revenue;
      if (shipping != -1) ret["shipping"] = shipping;
      if (tax != -1) ret["tax"] = tax;
      if (coupon.isNotEmpty) ret["coupon"] = coupon;
      if (affiliation.isNotEmpty) ret["affiliation"] = affiliation;
      if (eventDescription.isNotEmpty) {
        ret["eventDescription"] = eventDescription;
      }
      if (searchQuery.isNotEmpty) {
        ret["searchQuery"] = searchQuery;
      }
      if (adType != null) {
        ret["adType"] = getBranchEventAdTypeString(adType!);
      }
      if (_customData.isNotEmpty) ret["customData"] = _customData;
    } else {
      if (_isStandardEvent) {
        if (transactionID.isNotEmpty) {
          ret["transactionID"] = transactionID;
        }
        if (currency != null) {
          ret["currency"] = getCurrencyTypeString(currency!);
        }
        if (revenue != -1) ret["revenue"] = revenue;
        if (shipping != -1) ret["shipping"] = shipping;
        if (tax != -1) ret["tax"] = tax;
        if (coupon.isNotEmpty) ret["coupon"] = coupon;
        if (affiliation.isNotEmpty) ret["affiliation"] = affiliation;
        if (eventDescription.isNotEmpty) {
          ret["eventDescription"] = eventDescription;
        }
        if (searchQuery.isNotEmpty) {
          ret["searchQuery"] = searchQuery;
        }
        if (adType != null) {
          ret["adType"] = getBranchEventAdTypeString(adType!);
        }
      }
      _customData.forEach((key, value) {
        ret[key] = value;
      });
    }
    return ret;
  }
}
