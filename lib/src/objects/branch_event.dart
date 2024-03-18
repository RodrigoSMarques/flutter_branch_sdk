part of 'branch_universal_object.dart';
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
  CLICK_AD,
  RESERVE,
  VIEW_AD,
  // Content Events
  SEARCH,
  VIEW_ITEM,
  VIEW_ITEMS,
  RATE,
  SHARE,
  INITIATE_STREAM,
  COMPLETE_STREAM,
  // User Lifecycle Events
  COMPLETE_REGISTRATION,
  COMPLETE_TUTORIAL,
  ACHIEVE_LEVEL,
  UNLOCK_ACHIEVEMENT,
  INVITE,
  LOGIN,
  START_TRIAL,
  SUBSCRIBE
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
  String alias = '';

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
    Map<String, dynamic> data = <String, dynamic>{};

    if (!kIsWeb) {
      data["eventName"] = _eventName;
      data["isStandardEvent"] = _isStandardEvent;
      if (transactionID.isNotEmpty) {
        data["transactionID"] = transactionID;
      }
      if (currency != null) {
        data["currency"] = getCurrencyTypeString(currency!);
      }
      if (revenue != -1) data["revenue"] = revenue;
      if (shipping != -1) data["shipping"] = shipping;
      if (tax != -1) data["tax"] = tax;
      if (coupon.isNotEmpty) data["coupon"] = coupon;
      if (affiliation.isNotEmpty) data["affiliation"] = affiliation;
      if (eventDescription.isNotEmpty) {
        data["eventDescription"] = eventDescription;
      }
      if (searchQuery.isNotEmpty) {
        data["searchQuery"] = searchQuery;
      }
      if (adType != null) {
        data["adType"] = getBranchEventAdTypeString(adType!);
      }
      if (_customData.isNotEmpty) data["customData"] = _customData;
      if (alias.isNotEmpty) data["alias"] = alias;
    } else {
      if (_isStandardEvent) {
        if (transactionID.isNotEmpty) {
          data["transactionID"] = transactionID;
        }
        if (currency != null) {
          data["currency"] = getCurrencyTypeString(currency!);
        }
        if (revenue != -1) data["revenue"] = revenue;
        if (shipping != -1) data["shipping"] = shipping;
        if (tax != -1) data["tax"] = tax;
        if (coupon.isNotEmpty) data["coupon"] = coupon;
        if (affiliation.isNotEmpty) data["affiliation"] = affiliation;
        if (eventDescription.isNotEmpty) {
          data["eventDescription"] = eventDescription;
        }
        if (searchQuery.isNotEmpty) {
          data["searchQuery"] = searchQuery;
        }
        if (adType != null) {
          data["adType"] = getBranchEventAdTypeString(adType!);
        }
      }
      _customData.forEach((key, value) {
        data[key] = value;
      });
    }
    return data;
  }
}
