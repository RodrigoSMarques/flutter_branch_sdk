import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

import 'custom_button.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Flutter Branch SDK Example",
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
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

    listenDynamicLinks();

    initDeepLinkData();

    FlutterBranchSdk.setIdentity('branch_user_test');

    //requestATTTracking();
  }

  void requestATTTracking() async {
    AppTrackingStatus status;
    status = await FlutterBranchSdk.requestTrackingAuthorization();
    if (kDebugMode) {
      print(status);
    }

    status = await FlutterBranchSdk.getTrackingAuthorizationStatus();
    if (kDebugMode) {
      print(status);
    }

    final uuid = await FlutterBranchSdk.getAdvertisingIdentifier();
    if (kDebugMode) {
      print(uuid);
    }
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
      print('InitSesseion error: ${error.toString()}');
    });
  }

  void initDeepLinkData() {
    metadata = BranchContentMetaData()
      ..addCustomMetadata('custom_string', 'abc')
      ..addCustomMetadata('custom_number', 12345)
      ..addCustomMetadata('custom_bool', true)
      ..addCustomMetadata('custom_list_number', [1, 2, 3, 4, 5])
      ..addCustomMetadata('custom_list_string', ['a', 'b', 'c'])
      //--optional Custom Metadata
      ..contentSchema = BranchContentSchema.COMMERCE_PRODUCT
      ..price = 50.99
      ..currencyType = BranchCurrencyType.BRL
      ..quantity = 50
      ..sku = 'sku'
      ..productName = 'productName'
      ..productBrand = 'productBrand'
      ..productCategory = BranchProductCategory.ELECTRONICS
      ..productVariant = 'productVariant'
      ..condition = BranchCondition.NEW
      ..rating = 100
      ..ratingAverage = 50
      ..ratingMax = 100
      ..ratingCount = 2
      ..setAddress(
          street: 'street',
          city: 'city',
          region: 'ES',
          country: 'Brazil',
          postalCode: '99999-987')
      ..setLocation(31.4521685, -114.7352207);

    buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch',
        //parameter canonicalUrl
        //If your content lives both on the web and in the app, make sure you set its canonical URL
        // (i.e. the URL of this piece of content on the web) when building any BUO.
        // By doing so, we’ll attribute clicks on the links that you generate back to their original web page,
        // even if the user goes to the app instead of your website! This will help your SEO efforts.
        canonicalUrl: 'https://flutter.dev',
        title: 'Flutter Branch Plugin',
        imageUrl:
            'https://flutter.dev/assets/flutter-lockup-4cb0ee072ab312e59784d9fbf4fb7ad42688a7fdaea1270ccf6bbf4f34b7e03f.svg',
        contentDescription: 'Flutter Branch Description',
        /*
        contentMetadata: BranchContentMetaData()
          ..addCustomMetadata('custom_string', 'abc')
          ..addCustomMetadata('custom_number', 12345)
          ..addCustomMetadata('custom_bool', true)
          ..addCustomMetadata('custom_list_number', [1, 2, 3, 4, 5])
          ..addCustomMetadata('custom_list_string', ['a', 'b', 'c']),
         */
        //contentMetadata: metadata,
        keywords: ['Plugin', 'Branch', 'Flutter'],
        publiclyIndex: true,
        locallyIndex: true,
        expirationDateInMilliSec: DateTime.now()
            .add(const Duration(days: 365))
            .millisecondsSinceEpoch);

    lp = BranchLinkProperties(
        channel: 'facebook',
        feature: 'sharing',
        //parameter alias
        //Instead of our standard encoded short url, you can specify the vanity alias.
        // For example, instead of a random string of characters/integers, you can set the vanity alias as *.app.link/devonaustin.
        // Aliases are enforced to be unique** and immutable per domain, and per link - they cannot be reused unless deleted.
        //alias: 'https://branch.io' //define link url,
        stage: 'new share',
        campaign: 'xxxxx',
        tags: ['one', 'two', 'three'])
      ..addControlParam('\$uri_redirect_mode', '1')
      ..addControlParam('referring_user_id', 'asdf');

    eventStandart = BranchEvent.standardEvent(BranchStandardEvent.ADD_TO_CART)
      //--optional Event data
      ..transactionID = '12344555'
      ..currency = BranchCurrencyType.BRL
      ..revenue = 1.5
      ..shipping = 10.2
      ..tax = 12.3
      ..coupon = 'test_coupon'
      ..affiliation = 'test_affiliation'
      ..eventDescription = 'Event_description'
      ..searchQuery = 'item 123'
      ..adType = BranchEventAdType.BANNER
      ..addCustomData(
          'Custom_Event_Property_Key1', 'Custom_Event_Property_val1')
      ..addCustomData(
          'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');

    eventCustom = BranchEvent.customEvent('Custom_event')
      ..addCustomData(
          'Custom_Event_Property_Key1', 'Custom_Event_Property_val1')
      ..addCustomData(
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
          thumbVisibility: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
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
                            style: const TextStyle(
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
                  child: const Text('Validate SDK Integration'),
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
                        child: const Text('Enable tracking'),
                        onPressed: () {
                          FlutterBranchSdk.disableTracking(false);
                          showSnackBar(
                              context: context, message: 'Tracking enabled');
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomButton(
                        child: const Text('Disable tracking'),
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
                        child: const Text('Identify user'),
                        onPressed: () {
                          FlutterBranchSdk.setIdentity('branch_user_test');
                          showSnackBar(
                              context: context,
                              message: 'User branch_user_test identfied');
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomButton(
                        child: const Text('User logout'),
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
                        child: const Text('Register view'),
                        onPressed: () {
                          FlutterBranchSdk.registerView(buo: buo!);

                          showSnackBar(
                              context: context, message: 'Event Registered');
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomButton(
                        child: const Text('Track content'),
                        onPressed: () {
                          //FlutterBranchSdk.trackContent(
                          //    buo: [buo!], branchEvent: eventStandart!);

                          FlutterBranchSdk.trackContent(
                              buo: [buo!], branchEvent: eventCustom!);

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
                        child: const Text('Get First Parameters'),
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
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomButton(
                        child: const Text('Get Last Parameters'),
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
                CustomButton(
                  onPressed: getLastAttributed,
                  child: const Text('Get last Attributed'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        child: const Text('List on Search'),
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
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomButton(
                        child: const Text('Remove from Search'),
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
                CustomButton(
                  onPressed: generateLink,
                  child: const Text('Generate Link'),
                ),
                StreamBuilder<String>(
                  stream: controllerUrl.stream,
                  initialData: '',
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return Column(
                        children: <Widget>[
                          const Center(
                              child: Text(
                            'Link build',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          )),
                          Center(
                              child: GestureDetector(
                            onTap: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: snapshot.data!));
                              showSnackBar(
                                  context: context,
                                  message: 'Copied to Clipboard',
                                  duration: 2);
                            },
                            child: Text(snapshot.data!),
                          ))
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                CustomButton(
                  onPressed: shareLink,
                  child: const Text('Share Link'),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                const Center(
                  child: Text(
                    'Deep Link data',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
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

    BranchResponse responseQrCode = await FlutterBranchSdk.getQRCodeAsData(
        buo: buo!,
        linkProperties: lp,
        qrCode: BranchQrCode(
            primaryColor: Colors.black,
            //backgroundColor: const Color(0xff443a49),
            backgroundColor: Colors.white,
            imageFormat: BranchImageFormat.PNG));
    if (responseQrCode.success) {
      print(responseQrCode.result);
    } else {
      print(
          'Error : ${responseQrCode.errorCode} - ${responseQrCode.errorMessage}');
    }

    BranchResponse responseQrCode2 = await FlutterBranchSdk.getQRCodeAsImage(
        buo: buo!,
        linkProperties: lp,
        qrCode: BranchQrCode(
            primaryColor: Colors.black,
            //backgroundColor: const Color(0xff443a49),
            backgroundColor: Colors.white,
            imageFormat: BranchImageFormat.PNG));
    if (responseQrCode2.success) {
      print((responseQrCode2.result as Image).width);
      print((responseQrCode2.result as Image).height);
      print('done');
    } else {
      print(
          'Error : ${responseQrCode.errorCode} - ${responseQrCode.errorMessage}');
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
          context: context, message: 'showShareSheet Success', duration: 5);
    } else {
      showSnackBar(
          context: context,
          message:
              'showShareSheet Error: ${response.errorCode} - ${response.errorMessage}',
          duration: 5);
    }
  }

  void getLastAttributed() async {
    BranchResponse response =
        await FlutterBranchSdk.getLastAttributedTouchData();
    if (response.success) {
      showSnackBar(
          context: context, message: response.result.toString(), duration: 5);
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
