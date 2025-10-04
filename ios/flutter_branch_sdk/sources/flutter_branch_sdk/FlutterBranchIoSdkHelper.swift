import Foundation
import BranchSDK
import UIKit

//---------------------------------------------------------------------------------------------
// Object Conversion Functions
// --------------------------------------------------------------------------------------------
func convertToBUO(dict: [String: Any?]) -> BranchUniversalObject? {
    guard let canonicalIdentifier = dict["canonicalIdentifier"] as? String else {
        return nil
    }
    let buo = BranchUniversalObject(canonicalIdentifier: canonicalIdentifier)
    
    if let canonicalUrl = dict["canonicalUrl"] as? String {
        buo.canonicalUrl = canonicalUrl
    }
    if let title = dict["title"] as? String {
        buo.title = title
    }
    if let contentDescription = dict["contentDescription"] as? String {
        buo.contentDescription = contentDescription
    }
    if let imageUrl = dict["imageUrl"] as? String {
        buo.imageUrl = imageUrl
    }
    if let keywords = dict["keywords"] as? [String] {
        buo.keywords = keywords
    }
    if let expirationDate = dict["expirationDate"] as? Int64 {
        buo.expirationDate = Date(milliseconds: expirationDate)
    }
    if let locallyIndex = dict["locallyIndex"] as? Bool {
        buo.locallyIndex = locallyIndex
    }
    if let publiclyIndex = dict["publiclyIndex"] as? Bool {
        buo.publiclyIndex = publiclyIndex
    }
    if let contentMetadata = dict["contentMetadata"] as? [String: Any] {
        if let content_schema = contentMetadata["content_schema"] as? String {
            buo.contentMetadata.contentSchema = BranchContentSchema(rawValue: content_schema)
        }
        if let quantity = contentMetadata["quantity"] as? Double {
            buo.contentMetadata.quantity = quantity
        }
        if let price = contentMetadata["price"] as? Double {
            buo.contentMetadata.price = NSDecimalNumber(floatLiteral: price)
        }
        if let currency = contentMetadata["currency"] as? String {
            buo.contentMetadata.currency = BNCCurrency(rawValue: currency)
        }
        if let sku = contentMetadata["sku"] as? String {
            buo.contentMetadata.sku = sku
        }
        if let product_name = contentMetadata["product_name"] as? String {
            buo.contentMetadata.productName = product_name
        }
        if let product_brand = contentMetadata["product_brand"] as? String {
            buo.contentMetadata.productBrand = product_brand
        }
        if let product_category = contentMetadata["product_category"] as? String {
            buo.contentMetadata.productCategory = BNCProductCategory(rawValue: product_category)
        }
        if let product_variant = contentMetadata["product_variant"] as? String {
            buo.contentMetadata.productVariant = product_variant
        }
        if let condition = contentMetadata["condition"] as? String {
            buo.contentMetadata.condition = BranchCondition(rawValue: condition)
        }
        if let rating_average = contentMetadata["rating_average"] as? Double {
            buo.contentMetadata.ratingAverage = rating_average
        }
        if let rating_count = contentMetadata["rating_count"] as? Int {
            buo.contentMetadata.ratingCount = rating_count
        }
        if let rating_max = contentMetadata["rating_max"] as? Double {
            buo.contentMetadata.ratingMax = rating_max
        }
        if let rating = contentMetadata["rating"] as? Double {
            buo.contentMetadata.rating = rating
        }
        if let address_street = contentMetadata["address_street"] as? String {
            buo.contentMetadata.addressStreet = address_street
        }
        if let address_city = contentMetadata["address_city"] as? String {
            buo.contentMetadata.addressCity = address_city
        }
        if let address_region = contentMetadata["address_region"] as? String {
            buo.contentMetadata.addressRegion = address_region
        }
        if let address_country = contentMetadata["address_country"] as? String {
            buo.contentMetadata.addressCountry = address_country
        }
        if let address_postal_code = contentMetadata["address_postal_code"] as? String {
            buo.contentMetadata.addressPostalCode = address_postal_code
        }
        if let latitude = contentMetadata["latitude"] as? Double {
            buo.contentMetadata.latitude = latitude
        }
        if let longitude = contentMetadata["longitude"] as? Double {
            buo.contentMetadata.longitude = longitude
        }
        if let image_captions = contentMetadata["image_captions"] as? [String] {
            buo.contentMetadata.imageCaptions.addObjects(from: image_captions)
        }
        if let customMetadata = contentMetadata["customMetadata"] as? [String: Any] {
            for (key, value) in customMetadata {
                buo.contentMetadata.customMetadata[key] = value
            }
        }
    }
    return buo
}

func convertToLp(dict: [String: Any?]) -> BranchLinkProperties? {
    let lp = BranchLinkProperties()
    if let lpChannel = dict["channel"] as? String {
        lp.channel = lpChannel
    }
    if let lpFeature = dict["feature"] as? String {
        lp.feature = lpFeature
    }
    if let lpCampaign = dict["campaign"] as? String {
        lp.campaign = lpCampaign
    }
    if let lpStage = dict["stage"] as? String {
        lp.stage = lpStage
    }
    if let lpAlias = dict["alias"] as? String {
        lp.alias = lpAlias
    }
    if let lpmatchDuration = dict["matchDuration"] as? UInt {
        lp.matchDuration = lpmatchDuration
    }
    if let lptags = dict["tags"] as? [String] {
        lp.tags = lptags
    }
    if let lpControlParams = dict["controlParams"] as? [String: Any] {
        for (key, value) in lpControlParams {
            lp.addControlParam(key, withValue: value as? String)
        }
    }
    return lp
}

func convertToEvent(dict: [String: Any?]) -> BranchEvent? {
    guard let eventName = dict["eventName"] as? String,
          let isStandardEvent = dict["isStandardEvent"] as? Bool else {
        return nil
    }
    
    let event: BranchEvent = isStandardEvent ?
        BranchEvent.standardEvent(BranchStandardEvent(rawValue: eventName)) :
        BranchEvent.customEvent(withName: eventName)
    
    if let transactionID = dict["transactionID"] as? String {
        event.transactionID = transactionID
    }
    if let currency = dict["currency"] as? String {
        event.currency = BNCCurrency(rawValue: currency)
    }
    if let revenue = dict["revenue"] as? Double {
        event.revenue = NSDecimalNumber(floatLiteral: revenue)
    }
    if let shipping = dict["shipping"] as? Double {
        event.shipping = NSDecimalNumber(floatLiteral: shipping)
    }
    if let tax = dict["tax"] as? Double {
        event.tax = NSDecimalNumber(floatLiteral: tax)
    }
    if let coupon = dict["coupon"] as? String {
        event.coupon = coupon
    }
    if let affiliation = dict["affiliation"] as? String {
        event.affiliation = affiliation
    }
    if let eventDescription = dict["eventDescription"] as? String {
        event.eventDescription = eventDescription
    }
    if let searchQuery = dict["searchQuery"] as? String {
        event.searchQuery = searchQuery
    }
    if let adType = dict["adType"] as? String {
        event.adType = convertToAdType(adType: adType)
    }
    if let dictCustomData = dict["customData"] as? [String: Any] {
        for (key, value) in dictCustomData {
            if let stringValue = value as? String {
                event.customData[key] = stringValue
            }
        }
    }
    if let alias = dict["alias"] as? String {
        event.alias = alias
    }
    return event
}

func convertToAdType(adType: String) -> BranchEventAdType {
    switch adType {
    case "BANNER": return .banner
    case "INTERSTITIAL": return .interstitial
    case "REWARDED_VIDEO": return .rewardedVideo
    case "NATIVE": return .native
    default: return .none
    }
}

func convertToQRCode(dict: [String: Any?]) -> BranchQRCode {
    let qrCode = BranchQRCode()
    
    if let width = dict["width"] as? Int {
        qrCode.width = width as NSNumber
    }
    if let margin = dict["margin"] as? Int {
        qrCode.margin = margin as NSNumber
    }
    if let codeColor = dict["codeColor"] as? String {
        qrCode.codeColor = UIColor(hexString: codeColor)
    }
    if let backgroundColor = dict["backgroundColor"] as? String {
        qrCode.backgroundColor = UIColor(hexString: backgroundColor)
    }
    if let imageFormat = dict["imageFormat"] as? String {
        qrCode.imageFormat = (imageFormat == "JPEG") ? .JPEG : .PNG
    }
    if let centerLogoUrl = dict["centerLogoUrl"] as? String {
        qrCode.centerLogo = centerLogoUrl
    }
    return qrCode
}

//---------------------------------------------------------------------------------------------
// Extensions
// --------------------------------------------------------------------------------------------

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension Bundle {
    static func infoPlistValue(forKey key: String) -> Any? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) else {
            return nil
        }
        return value
    }
    
    public var icon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}

extension UIImage {
    public static func loadFrom(url: URL, completion: @escaping (_ image: UIImage?) -> ()) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
        }
        task.resume()
    }
}
