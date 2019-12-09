import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BranchContentMetaData metadata;
  BranchUniversalObject buo;
  BranchLinkProperties lp;
  BranchEvent eventStandart;
  BranchEvent eventCustom;

  var scaffoldKey = new GlobalKey<ScaffoldState>();
  StreamSubscription<Map> streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerUrl = StreamController<String>();

  @override
  void initState() {
    super.initState();

    listenDynamicLinks();
    initDeepLinkData();
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
            message: 'Link clicked: Custom string - ${data['custom_string']}',
            duration: 10);
      }
    }, onError: (error) {
      print(error);
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
    /* --optional Custom Metadata
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
      title: 'Flutter Branch Plugin',
      imageUrl: 'https://flutter.dev/assets/flutter-lockup-4cb0ee072ab312e59784d9fbf4fb7ad42688a7fdaea1270ccf6bbf4f34b7e03f.svg',
      contentDescription: 'Flutter Branch Description',
      contentMetadata: BranchContentMetaData()..addCustomMetadata('custom_string', 'abc')
          ..addCustomMetadata('custom_number', 12345)
          ..addCustomMetadata('custom_bool', true)
          ..addCustomMetadata('custom_list_number', [1,2,3,4,5 ])
          ..addCustomMetadata('custom_list_string', ['a', 'b', 'c']),
      keywords: ['Plugin', 'Branch', 'Flutter'],
      publiclyIndex: true,
      locallyIndex: true,
    );
    FlutterBranchSdk.registerView(buo: buo);

    lp = BranchLinkProperties(
        channel: 'facebook',
        feature: 'sharing',
        //alias: 'flutterplugin' //define link url,
        stage: 'new share',
      tags: ['one', 'two', 'three']
    );
    lp.addControlParam('url', 'http://www.google.com');
    lp.addControlParam('url2', 'http://flutter.dev');

    eventStandart = BranchEvent.standardEvent(BranchStandardEvent.ADD_TO_CART);
    /* --optional Event data
    eventStandart.transactionID = '12344555';
    eventStandart.currency = BranchCurrencyType.BRL;
    eventStandart.revenue = 1.5;
    eventStandart.shipping = 10.2;
    eventStandart.tax = 12.3;
    eventStandart.coupon = 'test_coupon';
    eventStandart.affiliation = 'test_affiliation';
    eventStandart.eventDescription = 'Event_description';
    eventStandart.searchQuery = 'item 123';
    eventStandart.adType = BranchEventAdType.BANNER;
    eventStandart.addCustomData(
        'Custom_Event_Property_Key1', 'Custom_Event_Property_val1');
    eventStandart.addCustomData(
        'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');
  */
    eventCustom = BranchEvent.customEvent('Custom_event');
    eventCustom.addCustomData(
        'Custom_Event_Property_Key1', 'Custom_Event_Property_val1');
    eventCustom.addCustomData(
        'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');
  }

  void showSnackBar({@required String message, int duration = 3}) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: duration),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: const Text('Branch.io Plugin Example App'),
        ),
        body: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            RaisedButton(
              child: Text('Validate SDK Integration'),
              onPressed: () {
                FlutterBranchSdk.validateSDKIntegration();
                if (Platform.isAndroid) {
                  showSnackBar(message: 'Check messages in run log or logcat');
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text('Enable tracking'),
                    onPressed: () {
                      FlutterBranchSdk.disableTracking(false);
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: RaisedButton(
                    child: Text('Disable tracking'),
                    onPressed: () {
                      FlutterBranchSdk.disableTracking(true);
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text('Identify user'),
                    onPressed: () {
                      FlutterBranchSdk.setIdentity('user1234567890');
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: RaisedButton(
                    child: Text('User logout'),
                    onPressed: () {
                      FlutterBranchSdk.logout();
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text('Register view'),
                    onPressed: () {
                      FlutterBranchSdk.registerView(buo: buo);
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: RaisedButton(
                    child: Text('Track content'),
                    onPressed: () {
                      FlutterBranchSdk.trackContent(
                          buo: buo, branchEvent: eventStandart);
                      FlutterBranchSdk.trackContent(
                          buo: buo, branchEvent: eventCustom);
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text('Get First Parameters'),
                    onPressed: () async {
                      Map<dynamic, dynamic> params =
                          await FlutterBranchSdk.getFirstReferringParams();
                      controllerData.sink.add(params.toString());
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: RaisedButton(
                    child: Text('Get Last Parameters'),
                    onPressed: () async {
                      Map<dynamic, dynamic> params =
                          await FlutterBranchSdk.getLatestReferringParams();
                      controllerData.sink.add(params.toString());
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text('List on Search'),
                    onPressed: () async {
                      bool success =
                          await FlutterBranchSdk.listOnSearch(buo: buo);
                      print(success);
                      success = await FlutterBranchSdk.listOnSearch(
                          buo: buo, linkProperties: lp);
                      print(success);
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: RaisedButton(
                    child: Text('Remove from Search'),
                    onPressed: () async {
                      bool success =
                          await FlutterBranchSdk.removeFromSearch(buo: buo);
                      print('Remove sucess: $success');
                      success = await FlutterBranchSdk.removeFromSearch(
                          buo: buo, linkProperties: lp);
                      print('Remove sucess: $success');
                    },
                  ),
                ),
              ],
            ),
            RaisedButton(
              child: Text('Generate Link'),
              onPressed: generateLink,
            ),
            StreamBuilder<String>(
              stream: controllerUrl.stream,
              initialData: '',
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data.isNotEmpty) {
                  return Column(
                    children: <Widget>[
                      Center(
                          child: Text(
                        'Link build',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      )),
                      Center(child: Text(snapshot.data))
                    ],
                  );
                } else {
                  return Container();
                }
              },
            ),
            RaisedButton(
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
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(),
            StreamBuilder<String>(
              stream: controllerData.stream,
              initialData: '',
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data.isNotEmpty) {
                  return Column(
                    children: <Widget>[Center(child: Text(snapshot.data))],
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void generateLink() async {
    BranchResponse response =
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    if (response.success) {
      controllerUrl.sink.add('${response.result}');
    } else {
      controllerUrl.sink
          .add('Error : ${response.errorCode} - ${response.errorDescription}');
    }
  }

  void shareLink() async {
    BranchResponse response = await FlutterBranchSdk.showShareSheet(
        buo: buo,
        linkProperties: lp,
        messageText: 'My Share text',
        androidMessageTitle: 'My Message Title',
        androidSharingTitle: 'My Share with');

    if (response.success) {
      showSnackBar(message: 'showShareSheet Sucess', duration: 5);
    } else {
      showSnackBar(
          message:
              'showShareSheet Error: ${response.errorCode} - ${response.errorDescription}',
          duration: 5);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controllerData.close();
    controllerUrl.close();
    streamSubscription.cancel();
  }
}
