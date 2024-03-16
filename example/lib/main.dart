import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:uuid/uuid.dart';

import 'custom_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //FlutterBranchSdk.setPreinstallCampaign('My Campaign Name');
  //FlutterBranchSdk.setPreinstallPartner('Branch \$3p Parameter Value');
  //FlutterBranchSdk.clearPartnerParameters();
  /*
  FlutterBranchSdk.addFacebookPartnerParameter(
      key: 'em',
      value:
          '11234e56af071e9c79927651156bd7a10bca8ac34672aba121056e2698ee7088');
  FlutterBranchSdk.addSnapPartnerParameter(
      key: 'hashed_email_address',
      value:
          '11234e56af071e9c79927651156bd7a10bca8ac34672aba121056e2698ee7088');
  FlutterBranchSdk.setRequestMetadata('key1', 'value1');
  FlutterBranchSdk.setRequestMetadata('key2', 'value2');
  */
  //await FlutterBranchSdk.requestTrackingAuthorization();
  await FlutterBranchSdk.init(
      useTestKey: true, enableLogging: true, disableTracking: false);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Branch SDK Example",
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: false,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  BranchContentMetaData metadata = BranchContentMetaData();
  BranchLinkProperties lp = BranchLinkProperties();
  late BranchUniversalObject buo;
  late BranchEvent eventStandard;
  late BranchEvent eventCustom;

  StreamSubscription<Map>? streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerInitSession = StreamController<String>();

  static const imageURL =
      'https://raw.githubusercontent.com/RodrigoSMarques/flutter_branch_sdk/master/assets/branch_logo_qrcode.jpeg';

  @override
  void initState() {
    super.initState();

    listenDynamicLinks();

    initDeepLinkData();

    //requestATTTracking();
    /*
    FlutterBranchSdk.setDMAParamsForEEA(
        eeaRegion: true,
        adPersonalizationConsent: false,
        adUserDataUsageConsent: false);
     */
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
    streamSubscription = FlutterBranchSdk.listSession().listen((data) async {
      print('listenDynamicLinks - DeepLink Data: $data');
      controllerData.sink.add((data.toString()));

      /*
      if (data.containsKey('+is_first_session') &&
          data['+is_first_session'] == true) {
        // wait 3 seconds to obtain installation data
        await Future.delayed(const Duration(seconds: 3));
        Map<dynamic, dynamic> params =
            await FlutterBranchSdk.getFirstReferringParams();
        controllerData.sink.add(params.toString());
        return;
      }
       */

      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        print(
            '------------------------------------Link clicked----------------------------------------------');
        print('Title: ${data['\$og_title']}');
        print('Custom string: ${data['custom_string']}');
        print('Custom number: ${data['custom_number']}');
        print('Custom bool: ${data['custom_bool']}');
        print('Custom date: ${data['custom_date_created']}');
        print('Custom list number: ${data['custom_list_number']}');
        print(
            '------------------------------------------------------------------------------------------------');
        showSnackBar(
            message:
                'Link clicked: Custom string - ${data['custom_string']} - Date: ${data['custom_date_created'] ?? ''}',
            duration: 10);
      }
    }, onError: (error) {
      print('listSession error: ${error.toString()}');
    });
  }

  void initDeepLinkData() {
    final DateTime today = DateTime.now();
    String dateString =
        '${today.year}-${today.month}-${today.day} ${today.hour}:${today.minute}:${today.second}';

    metadata = BranchContentMetaData()
      ..addCustomMetadata('custom_string', 'abcd')
      ..addCustomMetadata('custom_number', 12345)
      ..addCustomMetadata('custom_bool', true)
      ..addCustomMetadata('custom_list_number', [1, 2, 3, 4, 5])
      ..addCustomMetadata('custom_list_string', ['a', 'b', 'c'])
      ..addCustomMetadata('custom_date_created', dateString);
    //--optional Custom Metadata
    /*
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
      */

    final canonicalIdentifier = const Uuid().v4();
    buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch_$canonicalIdentifier',
        //parameter canonicalUrl
        //If your content lives both on the web and in the app, make sure you set its canonical URL
        // (i.e. the URL of this piece of content on the web) when building any BUO.
        // By doing so, we’ll attribute clicks on the links that you generate back to their original web page,
        // even if the user goes to the app instead of your website! This will help your SEO efforts.
        //canonicalUrl: 'https://flutter.dev',
        title: 'Flutter Branch Plugin - $dateString',
        imageUrl: imageURL,
        contentDescription: 'Flutter Branch Description - $dateString',
        contentMetadata: metadata,
        keywords: ['Plugin', 'Branch', 'Flutter'],
        publiclyIndex: true,
        locallyIndex: true,
        expirationDateInMilliSec: DateTime.now()
            .add(const Duration(days: 365))
            .millisecondsSinceEpoch);
    lp = BranchLinkProperties(
        channel: 'share',
        feature: 'sharing',
        //parameter alias
        //Instead of our standard encoded short url, you can specify the vanity alias.
        // For example, instead of a random string of characters/integers, you can set the vanity alias as *.app.link/devonaustin.
        // Aliases are enforced to be unique** and immutable per domain, and per link - they cannot be reused unless deleted.
        //alias: 'https://branch.io' //define link url,
        //alias: 'p/$id', //define link url,
        stage: 'new share',
        campaign: 'campaign',
        tags: ['one', 'two', 'three'])
      ..addControlParam('\$uri_redirect_mode', '1')
      ..addControlParam('\$ios_nativelink', true)
      ..addControlParam('\$match_duration', 7200)
      ..addControlParam('\$always_deeplink', true)
      ..addControlParam('\$android_redirect_timeout', 750)
      ..addControlParam('referring_user_id', 'user_id');
    //..addControlParam(
    //    '\$fallback_url', 'https://flutter-branch-sdk.netlify.app/');
    //..addControlParam('\$ios_url', 'https://flutter-branch-sdk.netlify.app/')
    //..addControlParam(
    //    '\$android_url', 'https://flutter-branch-sdk.netlify.app/');

    eventStandard = BranchEvent.standardEvent(BranchStandardEvent.ADD_TO_CART)
      //--optional Event data
      ..transactionID = '12344555'
      ..alias = 'StandardEventAlias'
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
      ..alias = 'CustomEventAlias'
      ..addCustomData(
          'Custom_Event_Property_Key1', 'Custom_Event_Property_val1')
      ..addCustomData(
          'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');
  }

  void showSnackBar({required String message, int duration = 2}) {
    scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: duration),
      ),
    );
  }

  void validSdkIntegration() {
    if (kIsWeb) {
      showSnackBar(
          message: 'validateSDKIntegration() not available in Flutter Web');
      return;
    }

    FlutterBranchSdk.validateSDKIntegration();
    if (Platform.isAndroid) {
      showSnackBar(message: 'Check messages in run log or logcat');
    }
  }

  void enableTracking() {
    FlutterBranchSdk.disableTracking(false);
    showSnackBar(message: 'Tracking enabled');
  }

  void disableTracking() {
    FlutterBranchSdk.disableTracking(true);
    showSnackBar(message: 'Tracking disabled');
  }

  void identifyUser() async {
    final isUserIdentified = await FlutterBranchSdk.isUserIdentified();
    if (isUserIdentified) {
      showSnackBar(message: 'User logged in');
      return;
    }
    final userId = const Uuid().v4();
    FlutterBranchSdk.setIdentity(userId);
    showSnackBar(message: 'User identified: $userId');
  }

  void userLogout() async {
    final isUserIdentified = await FlutterBranchSdk.isUserIdentified();
    if (!isUserIdentified) {
      showSnackBar(message: 'No users logged in');
      return;
    }
    FlutterBranchSdk.logout();
    showSnackBar(message: 'User logout');
  }

  void registerView() {
    FlutterBranchSdk.registerView(buo: buo);
    showSnackBar(message: 'Event Registered');
  }

  void trackContent() {
    FlutterBranchSdk.trackContent(buo: [buo], branchEvent: eventStandard);

    FlutterBranchSdk.trackContent(buo: [buo], branchEvent: eventCustom);

    FlutterBranchSdk.trackContentWithoutBuo(branchEvent: eventStandard);

    FlutterBranchSdk.trackContentWithoutBuo(branchEvent: eventCustom);

    showSnackBar(message: 'Tracked content');
  }

  void getFirstParameters() async {
    Map<dynamic, dynamic> params =
        await FlutterBranchSdk.getFirstReferringParams();
    controllerData.sink.add(params.toString());
    showSnackBar(message: 'First Parameters recovered');
  }

  void getLastParameters() async {
    Map<dynamic, dynamic> params =
        await FlutterBranchSdk.getLatestReferringParams();
    controllerData.sink.add(params.toString());
    showSnackBar(message: 'Last Parameters recovered');
  }

  void getLastAttributed() async {
    BranchResponse response =
        await FlutterBranchSdk.getLastAttributedTouchData();
    if (response.success) {
      controllerData.sink.add(response.result.toString());
      showSnackBar(message: 'Last Attributed TouchData recovered');
    } else {
      showSnackBar(
          message:
              'getLastAttributed Error: ${response.errorCode} - ${response.errorMessage}',
          duration: 5);
    }
  }

  void listOnSearch() async {
    if (kIsWeb) {
      showSnackBar(message: 'listOnSearch() not available in Flutter Web');
      return;
    }
    //Buo without Link Properties
    bool success = await FlutterBranchSdk.listOnSearch(buo: buo);

    //Buo with Link Properties
    success = await FlutterBranchSdk.listOnSearch(buo: buo, linkProperties: lp);

    if (success) {
      showSnackBar(message: 'Listed on Search');
    }
  }

  void removeFromSearch() async {
    if (kIsWeb) {
      showSnackBar(message: 'removeFromSearch() not available in Flutter Web');
      return;
    }
    bool success = await FlutterBranchSdk.removeFromSearch(buo: buo);
    success =
        await FlutterBranchSdk.removeFromSearch(buo: buo, linkProperties: lp);
    if (success) {
      showSnackBar(message: 'Removed from Search');
    }
  }

  void generateLink(BuildContext context) async {
    initDeepLinkData();
    BranchResponse response =
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    if (response.success) {
      if (context.mounted) {
        showGeneratedLink(context, response.result);
      }
    } else {
      showSnackBar(
          message: 'Error : ${response.errorCode} - ${response.errorMessage}');
    }
  }

  void generateQrCode(
    BuildContext context,
  ) async {
    /*
    BranchResponse responseQrCodeData = await FlutterBranchSdk.getQRCodeAsData(
        buo: buo!,
        linkProperties: lp,
        qrCode: BranchQrCode(
            primaryColor: Colors.black,
            //backgroundColor: const Color(0xff443a49), //Hex Color
            centerLogoUrl: imageURL,
            backgroundColor: Colors.white,
            imageFormat: BranchImageFormat.PNG));
    if (responseQrCodeData.success) {
      print(responseQrCodeData.result);
    } else {
      print(
          'Error : ${responseQrCodeData.errorCode} - ${responseQrCodeData.errorMessage}');
    }
     */
    initDeepLinkData();
    BranchResponse responseQrCodeImage =
        await FlutterBranchSdk.getQRCodeAsImage(
            buo: buo,
            linkProperties: lp,
            qrCode: BranchQrCode(
                primaryColor: Colors.black,
                //primaryColor: const Color(0xff443a49), //Hex colors
                centerLogoUrl: imageURL,
                backgroundColor: Colors.white,
                imageFormat: BranchImageFormat.PNG));
    if (responseQrCodeImage.success) {
      if (context.mounted) {
        showQrCode(context, responseQrCodeImage.result);
      }
    } else {
      showSnackBar(
          message:
              'Error : ${responseQrCodeImage.errorCode} - ${responseQrCodeImage.errorMessage}');
    }
  }

  void showGeneratedLink(BuildContext context, String url) async {
    initDeepLinkData();
    showModalBottomSheet(
        isDismissible: true,
        isScrollControlled: true,
        context: context,
        builder: (_) {
          return Container(
            padding: const EdgeInsets.all(12),
            height: 200,
            child: Column(
              children: <Widget>[
                const Center(
                    child: Text(
                  'Link created',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                )),
                const SizedBox(
                  height: 10,
                ),
                Text(url,
                    maxLines: 1,
                    style: const TextStyle(overflow: TextOverflow.ellipsis)),
                const SizedBox(
                  height: 10,
                ),
                IntrinsicWidth(
                  stepWidth: 300,
                  child: CustomButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: url));
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Center(child: Text('Copy link'))),
                ),
                const SizedBox(
                  height: 10,
                ),
                IntrinsicWidth(
                  stepWidth: 300,
                  child: CustomButton(
                      onPressed: () {
                        FlutterBranchSdk.handleDeepLink(url);
                        Navigator.pop(this.context);
                      },
                      child: const Center(child: Text('Handle deep link'))),
                ),
              ],
            ),
          );
        });
  }

  void showQrCode(BuildContext context, Image image) async {
    showModalBottomSheet(
        isDismissible: true,
        isScrollControlled: true,
        context: context,
        builder: (_) {
          return Container(
            padding: const EdgeInsets.all(12),
            height: 370,
            child: Column(
              children: <Widget>[
                const Center(
                    child: Text(
                  'Qr Code',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                )),
                const SizedBox(
                  height: 10,
                ),
                Image(
                  image: image.image,
                  height: 250,
                  width: 250,
                ),
                IntrinsicWidth(
                  stepWidth: 300,
                  child: CustomButton(
                      onPressed: () => Navigator.pop(this.context),
                      child: const Center(child: Text('Close'))),
                ),
              ],
            ),
          );
        });
  }

  void shareLink() async {
    initDeepLinkData();
    BranchResponse response = await FlutterBranchSdk.showShareSheet(
        buo: buo,
        linkProperties: lp,
        messageText: 'My Share text',
        androidMessageTitle: 'My Message Title',
        androidSharingTitle: 'My Share with');

    if (response.success) {
      showSnackBar(message: 'showShareSheet Success', duration: 5);
    } else {
      showSnackBar(
          message:
              'showShareSheet Error: ${response.errorCode} - ${response.errorMessage}',
          duration: 5);
    }
  }

  void shareWithLPLinkMetadata() async {
    /// Create a BranchShareLink instance with a BranchUniversalObject and LinkProperties.
    /// Set the BranchShareLink's LPLinkMetadata by using the addLPLinkMetadata() function.
    ///Present the BranchShareLink's Share Sheet.

    ///Load icon from Assets
    final iconData = (await rootBundle.load('assets/images/branch_logo.jpeg'))
        .buffer
        .asUint8List();

    /*
    ///Load icon from Web
    final iconData =
        (await NetworkAssetBundle(Uri.parse(imageURL)).load(imageURL))
            .buffer
            .asUint8List();
    */
    initDeepLinkData();
    FlutterBranchSdk.shareWithLPLinkMetadata(
        buo: buo,
        linkProperties: lp,
        title: "Share With LPLinkMetadata",
        icon: iconData);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: SafeArea(
        bottom: true,
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Flutter Branch SDK Example'),
          ),
          body: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              primary: true,
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
                    onPressed: validSdkIntegration,
                    child: const Text('Validate SDK Integration'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: CustomButton(
                          onPressed: enableTracking,
                          child: const Text('Enable tracking'),
                        ),
                      ),
                      Expanded(
                        child: CustomButton(
                          onPressed: disableTracking,
                          child: const Text('Disable tracking'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: CustomButton(
                          onPressed: identifyUser,
                          child: const Text('Identify user'),
                        ),
                      ),
                      Expanded(
                        child: CustomButton(
                          onPressed: userLogout,
                          child: const Text('User logout'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: CustomButton(
                          onPressed: registerView,
                          child: const Text('Register view'),
                        ),
                      ),
                      Expanded(
                        child: CustomButton(
                          onPressed: trackContent,
                          child: const Text('Track content'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: CustomButton(
                          onPressed: getFirstParameters,
                          child: const Text('Get First Parameters',
                              textAlign: TextAlign.center),
                        ),
                      ),
                      Expanded(
                        child: CustomButton(
                          onPressed: getLastParameters,
                          child: const Text('Get Last Parameters',
                              textAlign: TextAlign.center),
                        ),
                      ),
                      Expanded(
                        child: CustomButton(
                          onPressed: getLastAttributed,
                          child: const Text('Get Last Attributed',
                              textAlign: TextAlign.center),
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: CustomButton(
                          onPressed: listOnSearch,
                          child: const Text('List on Search',
                              textAlign: TextAlign.center),
                        ),
                      ),
                      Expanded(
                        child: CustomButton(
                          onPressed: removeFromSearch,
                          child: const Text('Remove from Search',
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CustomButton(
                          onPressed: () => generateLink(context),
                          child: const Text('Generate Link',
                              textAlign: TextAlign.center),
                        ),
                      ),
                      Expanded(
                        child: CustomButton(
                          onPressed: () => generateQrCode(context),
                          child: const Text('Generate QrCode',
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: (CustomButton(
                        onPressed: shareLink,
                        child: const Text('Share Link',
                            textAlign: TextAlign.center),
                      ))),
                      Expanded(
                          child: CustomButton(
                        onPressed: shareWithLPLinkMetadata,
                        child: const Text('Share Link with LPLinkMetadata',
                            textAlign: TextAlign.center),
                      ))
                    ],
                  ),
                  const Divider(),
                  const Center(
                    child: Text(
                      'Data',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(),
                  StreamBuilder<String>(
                    stream: controllerData.stream,
                    initialData: null,
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controllerData.close();
    controllerInitSession.close();
    streamSubscription?.cancel();
  }
}
