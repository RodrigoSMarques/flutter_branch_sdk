import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

import 'custom_button.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Branch SDK Example",
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  BranchContentMetaData metadata = BranchContentMetaData();
  BranchUniversalObject? buo;
  BranchLinkProperties lp = BranchLinkProperties();
  BranchEvent? eventStandart;
  BranchEvent? eventCustom;

  StreamSubscription<Map>? streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerInitSession = StreamController<String>();
  StreamController<String> controllerUrl = StreamController<String>();

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      FlutterBranchSdk.initWeb(
          branchKey: 'key_test_ipQTteg11ENANDeCzSXgqdgfuycWoXYH');
    } else {
      FlutterBranchSdk.setIOSSKAdNetworkMaxTime(72);
    }

    listenDynamicLinks();

    initDeepLinkData();

    FlutterBranchSdk.setIdentity('branch_user_test');

    //requestATTTracking();
  }

  void requestATTTracking() async {
    AppTrackingStatus status;
    status = await FlutterBranchSdk.requestTrackingAuthorization();
    print(status);

    status = await FlutterBranchSdk.getTrackingAuthorizationStatus();
    print(status);

    final uuid = await FlutterBranchSdk.getAdvertisingIdentifier();
    print(uuid);
  }

  void listenDynamicLinks() async {
    streamSubscription = FlutterBranchSdk.initSession().listen((data) {
      print('listenDynamicLinks - DeepLink Data: $data');
      controllerData.sink.add((data.toString()));
      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        print(
            '------------------------------------Link clicked----------------------------------------------');
        print('Custom string: ${data['custom_string']}');
        print('Custom number: ${data['custom_number']}');
        print('Custom bool: ${data['custom_bool']}');
        print('Custom list number: ${data['custom_list_number']}');
        print(
            '------------------------------------------------------------------------------------------------');
        showSnackBar(
            context: context,
            message: 'Link clicked: Custom string - ${data['custom_string']}',
            duration: 10);
      }
    }, onError: (error) {
      PlatformException platformException = error as PlatformException;
      print(
          'InitSession error: ${platformException.code} - ${platformException.message}');
      controllerInitSession.add(
          'InitSession error: ${platformException.code} - ${platformException.message}');
    });
  }

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

  void showSnackBar(
      {required BuildContext context,
      required String message,
      int duration = 1}) {
    scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: duration),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Branch.io Plugin Example App'),
        ),
        body: Scrollbar(
          isAlwaysShown: true,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                StreamBuilder<String>(
                  stream: controllerInitSession.stream,
                  initialData: '',
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return Column(
                        children: <Widget>[
                          Center(
                              child: Text(
                            snapshot.data!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ))
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                CustomButton(
                  child: Text('Validate SDK Integration'),
                  onPressed: () {
                    if (kIsWeb) {
                      showSnackBar(
                          context: context,
                          message:
                              'validateSDKIntegration() not available in Flutter Web');
                      return;
                    }

                    FlutterBranchSdk.validateSDKIntegration();
                    if (Platform.isAndroid) {
                      showSnackBar(
                          context: context,
                          message: 'Check messages in run log or logcat');
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        child: Text('Enable tracking'),
                        onPressed: () {
                          FlutterBranchSdk.disableTracking(false);
                          showSnackBar(
                              context: context, message: 'Tracking enabled');
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomButton(
                        child: Text('Disable tracking'),
                        onPressed: () {
                          FlutterBranchSdk.disableTracking(true);
                          showSnackBar(
                              context: context, message: 'Tracking disabled');
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        child: Text('Identify user'),
                        onPressed: () {
                          FlutterBranchSdk.setIdentity('branch_user_test');
                          showSnackBar(
                              context: context,
                              message: 'User branch_user_test identfied');
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomButton(
                        child: Text('User logout'),
                        onPressed: () {
                          FlutterBranchSdk.logout();
                          showSnackBar(
                              context: context,
                              message: 'User branch_user_test logout');
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        child: Text('Register view'),
                        onPressed: () {
                          FlutterBranchSdk.registerView(buo: buo!);

                          showSnackBar(
                              context: context, message: 'Event Registered');
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomButton(
                        child: Text('Track content'),
                        onPressed: () {
                          FlutterBranchSdk.trackContent(
                              buo: buo!, branchEvent: eventStandart!);
                          FlutterBranchSdk.trackContent(
                              buo: buo!, branchEvent: eventCustom!);

                          FlutterBranchSdk.trackContentWithoutBuo(
                              branchEvent: eventStandart!);
                          FlutterBranchSdk.trackContentWithoutBuo(
                              branchEvent: eventCustom!);

                          showSnackBar(
                              context: context, message: 'Tracked content');
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        child: Text('Get First Parameters'),
                        onPressed: () async {
                          Map<dynamic, dynamic> params =
                              await FlutterBranchSdk.getFirstReferringParams();
                          controllerData.sink.add(params.toString());
                          showSnackBar(
                              context: context,
                              message: 'First Parameters recovered');
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomButton(
                        child: Text('Get Last Parameters'),
                        onPressed: () async {
                          Map<dynamic, dynamic> params =
                              await FlutterBranchSdk.getLatestReferringParams();
                          controllerData.sink.add(params.toString());
                          showSnackBar(
                              context: context,
                              message: 'Last Parameters recovered');
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        child: Text('List on Search'),
                        onPressed: () async {
                          if (kIsWeb) {
                            showSnackBar(
                                context: context,
                                message:
                                    'listOnSearch() not available in Flutter Web');
                            return;
                          }
                          bool success =
                              await FlutterBranchSdk.listOnSearch(buo: buo!);

                          success = await FlutterBranchSdk.listOnSearch(
                              buo: buo!, linkProperties: lp);

                          if (success) {
                            showSnackBar(
                                context: context, message: 'Listed on Search');
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomButton(
                        child: Text('Remove from Search'),
                        onPressed: () async {
                          if (kIsWeb) {
                            showSnackBar(
                                context: context,
                                message:
                                    'removeFromSearch() not available in Flutter Web');
                            return;
                          }
                          bool success =
                              await FlutterBranchSdk.removeFromSearch(
                                  buo: buo!);
                          success = await FlutterBranchSdk.removeFromSearch(
                              buo: buo!, linkProperties: lp);
                          if (success) {
                            showSnackBar(
                                context: context,
                                message: 'Removed from Search');
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        child: Text('Viewing Credits'),
                        onPressed: () async {
                          bool isUserIdentified =
                              await FlutterBranchSdk.isUserIdentified();

                          if (!isUserIdentified) {
                            showSnackBar(
                                context: context,
                                message:
                                    'User not identified. Call setIdentity() before.');
                            return;
                          }

                          int credits = 0;
                          BranchResponse response =
                              await FlutterBranchSdk.loadRewards();
                          if (response.success) {
                            credits = response.result;
                            print('Crédits');
                            showSnackBar(
                                context: context, message: 'Credits: $credits');
                          } else {
                            showSnackBar(
                                context: context,
                                message:
                                    'Credits error: ${response.errorMessage}');
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomButton(
                        child: Text('Redeeming Credits'),
                        onPressed: () async {
                          bool isUserIdentified =
                              await FlutterBranchSdk.isUserIdentified();

                          if (!isUserIdentified) {
                            showSnackBar(
                                context: context,
                                message:
                                    'User not identified. Call setIdentity() before.');
                            return;
                          }

                          bool success = false;
                          BranchResponse response =
                              await FlutterBranchSdk.redeemRewards(count: 5);
                          if (response.success) {
                            success = response.result;
                            print('Redeeming Credits: $success');
                            showSnackBar(
                                context: context,
                                message: 'Redeeming Credits: $success');
                          } else {
                            print(
                                'Redeeming Credits error: ${response.errorMessage}');
                            showSnackBar(
                                context: context,
                                message:
                                    'Redeeming Credits error: ${response.errorMessage}');
                          }
                          //success = await
                        },
                      ),
                    ),
                  ],
                ),
                CustomButton(
                    child: Text('Get Credits History'),
                    onPressed: () async {
                      bool isUserIdentified =
                          await FlutterBranchSdk.isUserIdentified();

                      if (!isUserIdentified) {
                        showSnackBar(
                            context: context,
                            message:
                                'User not identified. Call setIdentity() before.');
                        return;
                      }

                      BranchResponse response =
                          await FlutterBranchSdk.getCreditHistory();
                      if (response.success) {
                        print('Credits Hystory: ${response.result}');
                        showSnackBar(
                            context: context,
                            message:
                                'Check log for view Credit History. Records: ${(response.result as List).length}');
                      } else {
                        print(
                            'Get Credits History error: ${response.errorMessage}');
                        showSnackBar(
                            context: context,
                            message:
                                'Get Credits History error: ${response.errorMessage}');
                      }
                    }),
                CustomButton(
                  child: Text('Generate Link'),
                  onPressed: generateLink,
                ),
                StreamBuilder<String>(
                  stream: controllerUrl.stream,
                  initialData: '',
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return Column(
                        children: <Widget>[
                          Center(
                              child: Text(
                            'Link build',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          )),
                          Center(child: Text(snapshot.data!))
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                CustomButton(
                  child: Text('Share Link'),
                  onPressed: shareLink,
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(),
                Center(
                  child: Text(
                    'Deep Link data',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(),
                StreamBuilder<String>(
                  stream: controllerData.stream,
                  initialData: '',
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return Column(
                        children: [
                          Center(child: Text(snapshot.data!)),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void generateLink() async {
    BranchResponse response =
        await FlutterBranchSdk.getShortUrl(buo: buo!, linkProperties: lp);
    if (response.success) {
      controllerUrl.sink.add('${response.result}');
    } else {
      controllerUrl.sink
          .add('Error : ${response.errorCode} - ${response.errorMessage}');
    }
  }

  void shareLink() async {
    BranchResponse response = await FlutterBranchSdk.showShareSheet(
        buo: buo!,
        linkProperties: lp,
        messageText: 'My Share text',
        androidMessageTitle: 'My Message Title',
        androidSharingTitle: 'My Share with');

    if (response.success) {
      showSnackBar(
          context: context, message: 'showShareSheet Sucess', duration: 5);
    } else {
      showSnackBar(
          context: context,
          message:
              'showShareSheet Error: ${response.errorCode} - ${response.errorMessage}',
          duration: 5);
    }
  }

  @override
  void dispose() {
    super.dispose();
    controllerData.close();
    controllerUrl.close();
    controllerInitSession.close();
    streamSubscription?.cancel();
  }
}
