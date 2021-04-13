import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      body: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return DetailScreen();
            }));
          },
          child: Hero(
              tag: 'imageHero',
              child: Icon(
                Icons.add,
                size: 50,
              ))),
    );
  }
}

class DetailScreen extends StatefulWidget {
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  BranchContentMetaData metadata = BranchContentMetaData();
  BranchUniversalObject? buo;
  BranchLinkProperties lp = BranchLinkProperties();
  BranchEvent? eventStandart;
  BranchEvent? eventCustom;

  void initDeepLinkData() {
    metadata = BranchContentMetaData()
        .addCustomMetadata('custom_string', 'abc')
        .addCustomMetadata('custom_number', 12345)
        .addCustomMetadata('custom_bool', true)
        .addCustomMetadata('custom_list_number', [
      1,
      2,
      3,
      4,
      5
    ]).addCustomMetadata('custom_list_string', ['a', 'b', 'c']);
    //--optional Custom Metadata
    /*
    metadata.contentSchema = BranchContentSchema.COMMERCE_PRODUCT;
    metadata.price = 50.99;
    metadata.currencyType = BranchCurrencyType.BRL;
    metadata.quantity = 50;
    metadata.sku = 'sku';
    metadata.productName = 'productName';
    metadata.productBrand = 'productBrand';
    metadata.productCategory = BranchProductCategory.ELECTRONICS;
    metadata.productVariant = 'productVariant';
    metadata.condition = BranchCondition.NEW;
    metadata.rating = 100;
    metadata.ratingAverage = 50;
    metadata.ratingMax = 100;
    metadata.ratingCount = 2;
    metadata.setAddress(
        street: 'street',
        city: 'city',
        region: 'ES',
        country: 'Brazil',
        postalCode: '99999-987');
    metadata.setLocation(31.4521685, -114.7352207);
*/

    buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch',
        //canonicalUrl: '',
        title: 'Flutter Branch Plugin',
        imageUrl:
            'https://flutter.dev/assets/flutter-lockup-4cb0ee072ab312e59784d9fbf4fb7ad42688a7fdaea1270ccf6bbf4f34b7e03f.svg',
        contentDescription: 'Flutter Branch Description',
        contentMetadata: BranchContentMetaData()
          ..addCustomMetadata('custom_string', 'abc')
          ..addCustomMetadata('custom_number', 12345)
          ..addCustomMetadata('custom_bool', true)
          ..addCustomMetadata('custom_list_number', [1, 2, 3, 4, 5])
          ..addCustomMetadata('custom_list_string', ['a', 'b', 'c']),
        keywords: ['Plugin', 'Branch', 'Flutter'],
        publiclyIndex: true,
        locallyIndex: true,
        expirationDateInMilliSec:
            DateTime.now().add(Duration(days: 365)).millisecondsSinceEpoch);

    //parameter canonicalUrl
    //If your content lives both on the web and in the app, make sure you set its canonical URL
    // (i.e. the URL of this piece of content on the web) when building any BUO.
    // By doing so, we’ll attribute clicks on the links that you generate back to their original web page,
    // even if the user goes to the app instead of your website! This will help your SEO efforts.

    FlutterBranchSdk.registerView(buo: buo!);

    lp = BranchLinkProperties(
        channel: 'facebook',
        feature: 'sharing',
        //alias: 'flutterplugin' //define link url,
        stage: 'new share',
        campaign: 'xxxxx',
        tags: ['one', 'two', 'three']);
    lp.addControlParam('\$uri_redirect_mode', '1');

    //parameter alias
    //Instead of our standard encoded short url, you can specify the vanity alias.
    // For example, instead of a random string of characters/integers, you can set the vanity alias as *.app.link/devonaustin.
    // Aliases are enforced to be unique** and immutable per domain, and per link - they cannot be reused unless deleted.

    eventStandart = BranchEvent.standardEvent(BranchStandardEvent.ADD_TO_CART);
    //--optional Event data
    /*
    eventStandart!.transactionID = '12344555';
    eventStandart!.currency = BranchCurrencyType.BRL;
    eventStandart!.revenue = 1.5;
    eventStandart!.shipping = 10.2;
    eventStandart!.tax = 12.3;
    eventStandart!.coupon = 'test_coupon';
    eventStandart!.affiliation = 'test_affiliation';
    eventStandart!.eventDescription = 'Event_description';
    eventStandart!.searchQuery = 'item 123';
    eventStandart!.adType = BranchEventAdType.BANNER;
    eventStandart!.addCustomData(
        'Custom_Event_Property_Key1', 'Custom_Event_Property_val1');
    eventStandart!.addCustomData(
        'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');
     */
    eventCustom = BranchEvent.customEvent('Custom_event');
    eventCustom!.addCustomData(
        'Custom_Event_Property_Key1', 'Custom_Event_Property_val1');
    eventCustom!.addCustomData(
        'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initDeepLinkData();
    events();
  }

  void events() async {
    FlutterBranchSdk.trackContent(buo: buo!, branchEvent: eventStandart!);
    FlutterBranchSdk.trackContent(buo: buo!, branchEvent: eventCustom!);

    FlutterBranchSdk.trackContentWithoutBuo(branchEvent: eventStandart!);
    FlutterBranchSdk.trackContentWithoutBuo(branchEvent: eventCustom!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
            child: Hero(
                tag: 'imageHero',
                child: Icon(
                  Icons.add,
                  size: 200,
                ))),
      ),
    );
  }
}
