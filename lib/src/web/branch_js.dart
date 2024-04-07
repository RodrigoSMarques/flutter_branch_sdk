@JS()
library branchjs;

import 'dart:typed_data';

import 'package:js/js.dart';

@JS('JSON.stringify')
external String jsonStringify(Object obj);

@JS('JSON.parse')
external dynamic jsonParse(String str);

@JS('navigator.share')
external dynamic navigatorShare(Object data);

@JS('prompt')
external dynamic browserPrompt(String message, [String data]);

@JS()
@anonymous
class QrCodeData {
  external ByteBuffer rawBuffer;
  external Function base64();
}

@JS('branch')
class BranchJS {
  /// addListener(event, listener)
  /// Parameters
  ///
  /// event: String, optional - Specify which events you would like to listen for. If
  /// not defined, the observer will recieve all events.
  ///
  /// listener: function, required - Listening function that will recieves an
  /// event as a string and optional data as an object.
  ///
  /// The Branch Web SDK includes a simple event listener, that currently only publishes events for
  /// Journeys events.
  /// Future development will include the ability to subscribe to events related to all other Web
  /// SDK functionality.
  ///
  /// Example
  ///
  /// var listener = function(event, data) { console.log(event, data); }
  ///
  /// // Specify an event to listen for
  /// branch.addListener('willShowJourney', listener);
  ///
  /// // Listen for all events
  /// branch.addListener(listener);
  /// Available Journey Events:
  ///
  /// willShowJourney: Journey is about to be shown.
  /// didShowJourney: Journey's entrance animation has completed and it is being shown to the user.
  /// willNotShowJourney: Journey will not be shown and no other events will be emitted.
  /// didClickJourneyCTA: User clicked on Journey's CTA button.
  /// didClickJourneyClose: User clicked on Journey's close button.
  /// willCloseJourney: Journey close animation has started.
  /// didCloseJourney: Journey's close animation has completed and it is no longer visible to the user.
  /// didCallJourneyClose: Emitted when developer calls branch.closeJourney() to dismiss Journey.
  @JS('addListener')
  external static void addListener([String event, Function listener]);

  // No documentation in full reference
  // @JS('banner')
  // external static void banner();

  // No documentation in full reference
  // @JS('closeBanner')
  // external static void closeBanner();

  /// closeJourney(callback)
  /// Parameters
  ///
  /// callback: function, optional
  ///
  /// Journeys include a close button the user can click, but you may want to close the
  /// Journey with a timeout, or via some other user interaction with your web app. In this case,
  /// closing the Journey is very simple by calling Branch.closeJourney().
  ///
  /// Usage
  ///
  /// branch.closeJourney(function(err) { console.log(err); });
  @JS('closeJourney')
  external static void closeJourney([Function callback]);

  /// data(callback)
  /// Parameters
  ///
  /// callback: function, optional - callback to read the
  /// session data.
  ///
  /// Returns the same session information and any referring data, as
  /// Branch.init, but does not require the app_id. This is meant to be called
  /// after Branch.init has been called if you need the session information at a
  /// later point.
  /// If the Branch session has already been initialized, the callback will return
  /// immediately, otherwise, it will return once Branch has been initialized.
  @JS('data')
  external static void data([Function callback]);

  /// deepview(data, options, callback)
  /// Parameters
  ///
  /// data: Object, required - object of all link data, same as branch.link().
  ///
  /// options: Object, optional - { make_new_link: whether to create a new link even if
  /// one already exists. open_app, whether to try to open the app passively (as opposed to
  /// opening it upon user clicking); defaults to true
  /// }.
  ///
  /// callback: function, optional - returns an error if the API call is unsuccessful
  ///
  /// Turns the current page into a "deepview" – a preview of app content. This gives the page two
  /// special behaviors:
  ///
  /// When the page is viewed on a mobile browser, if the user has the app
  /// installed on their phone, we will try to open the app automaticaly and deeplink them to this content (this can be toggled off by turning open_app to false, but this is not recommended).
  /// Provides a callback to open the app directly, accessible as branch.deepviewCta();
  /// you'll want to have a button on your web page that says something like "View in app", which calls this function.
  /// See this tutorial for a full
  /// guide on how to use the deepview functionality of the Web SDK.
  ///
  /// Usage
  ///
  /// branch.deepview(
  ///     data,
  ///     options,
  ///     callback (err)
  /// );
  /// Example
  ///
  /// branch.deepview(
  ///     {
  ///         channel: 'facebook',
  ///         data: {
  ///             mydata: 'content of my data',
  ///             foo: 'bar',
  ///             '$deeplink_path': 'item_id=12345'
  ///         },
  ///         feature: 'dashboard',
  ///         stage: 'new user',
  ///         tags: [ 'tag1', 'tag2' ],
  ///     },
  ///     {
  ///         make_new_link: true,
  ///         open_app: true
  ///     },
  ///     function(err) {
  ///         console.log(err || 'no error');
  ///     }
  /// );
  /// Callback Format
  ///
  /// callback(
  ///     "Error message"
  /// );
  @JS('deepview')
  external static void deepview(Object data,
      [Object options, Function callback]);

  /// deepviewCta()
  /// Perform the branch deepview CTA (call to action) on mobile after branch.deepview() call is
  /// finished. If the branch.deepview() call is finished with no error, when branch.deepviewCta() is called,
  /// an attempt is made to open the app and deeplink the end user into it; if the end user does not
  /// have the app installed, they will be redirected to the platform-appropriate app stores. If on the
  /// other hand, branch.deepview() returns with an error, branch.deepviewCta() will fall back to
  /// redirect the user using
  /// Branch dynamic links.
  ///
  /// If branch.deepview() has not been called, an error will arise with a reminder to call
  /// branch.deepview() first.
  ///
  /// Usage
  ///
  /// $('a.deepview-cta').click(branch.deepviewCta); // If you are using jQuery
  ///
  /// document.getElementById('my-elem').onClick = branch.deepviewCta; // Or generally
  ///
  /// <a href='...' onclick='branch.deepviewCta()'> // In HTML
  ///
  /// // We recommend to assign deepviewCta in deepview callback:
  /// branch.deepview(data, option, function(err) {
  ///     if (err) {
  ///         throw err;
  ///     }
  ///     $('a.deepview-cta').click(branch.deepviewCta);
  /// });
  ///
  /// // You can call this function any time after branch.deepview() is finished by simply:
  /// branch.deepviewCta();
  ///
  /// When debugging, please call branch.deepviewCta() with an error callback like so:
  ///
  /// branch.deepviewCta(function(err) {
  ///     if (err) {
  ///         console.log(err);
  ///     }
  /// });
  /// Referral System Rewarding Functionality
  /// In a standard referral system, you have 2 parties: the original user and the invitee. Our system
  /// is flexible enough to handle rewards for all users for any actions. Here are a couple example
  /// scenarios:
  ///
  /// Reward the original user for taking action (eg. inviting, purchasing, etc)
  /// Reward the invitee for installing the app from the original user's referral link
  /// Reward the original user when the invitee takes action (eg. give the original user credit when
  /// their the invitee buys something)
  /// These reward definitions are created on the dashboard, under the 'Reward Rules' section in the
  /// 'Referrals' tab on the dashboard.
  ///
  /// Warning: For a referral program, you should not use unique awards for custom events and redeem
  /// pre-identify call. This can allow users to cheat the system.
  @JS('deepviewCta')
  external static void deepviewCta([Function errorCallback]);

  /// first(callback)
  /// Parameters
  ///
  /// callback: function, optional - callback to read the
  /// session data.
  ///
  /// Returns the same session information and any referring data, as
  /// Branch.init did when the app was first installed. This is meant to be called
  /// after Branch.init has been called if you need the first session information at a
  /// later point.
  /// If the Branch session has already been initialized, the callback will return
  /// immediately, otherwise, it will return once Branch has been initialized.
  @JS('first')
  external static void first([Function callback]);

  // No documentation on reference
  // @JS('getCode')
  // external static void getCode();

  /// init(branch_key, options, callback)
  /// Parameters
  ///
  /// branch_key: string, required - Your Branch live key, or (deprecated) your app id.
  ///
  /// options: Object, optional - { }.
  ///
  /// callback: function, optional - callback to read the
  /// session data.
  ///
  /// Adding the Branch script to your page automatically creates a window.branch
  /// object with all the external methods described below. All calls made to
  /// Branch methods are stored in a queue, so even if the SDK is not fully
  /// instantiated, calls made to it will be queued in the order they were
  /// originally called.
  /// If the session was opened from a referring link, data() will also return the referring link
  /// click as referring_link, which gives you the ability to continue the click flow.
  ///
  /// The init function on the Branch object initiates the Branch session and
  /// creates a new user session, if it doesn't already exist, in
  /// sessionStorage.
  ///
  /// Useful Tip: The init function returns a data object where you can read
  /// the link the user was referred by.
  ///
  /// Properties available in the options object:
  ///
  /// Key	Value
  /// branch_match_id	optional - string. The current user's browser-fingerprint-id. The value of this parameter should be the same as the value of ?branch_match_id (automatically appended by Branch after a link click). _Only necessary if ?_branch_match_id is lost due to multiple redirects in your flow.
  /// branch_view_id	optional - string. If you would like to test how Journeys render on your page before activating them, you can set the value of this parameter to the id of the view you are testing. Only necessary when testing a view related to a Journey.
  /// no_journeys	optional - boolean. When true, prevents Journeys from appearing on current page.
  /// disable_entry_animation	optional - boolean. When true, prevents a Journeys entry animation.
  /// disable_exit_animation	optional - boolean. When true, prevents a Journeys exit animation.
  /// retries	optional - integer. Value specifying the number of times that a Branch API call can be re-attempted. Default 2.
  /// retry_delay	optional - integer . Amount of time in milliseconds to wait before re-attempting a timed-out request to the Branch API. Default 200 ms.
  /// timeout	optional - integer. Duration in milliseconds that the system should wait for a response before considering any Branch API call to have timed out. Default 5000 ms.
  /// metadata	optional - object. Key-value pairs used to target Journeys users via the "is viewing a page with metadata key" filter.
  /// nonce	optional - string. A nonce value that will be added to branch-journey-cta injected script. Used to allow that script from a Content Security Policy.
  /// tracking_disabled	optional - boolean. true disables tracking
  /// Usage
  ///
  /// branch.init(
  ///     branch_key,
  ///     options,
  ///     callback (err, data),
  /// );
  /// Callback Format
  ///
  /// callback(
  ///      "Error message",
  ///      {
  ///           data_parsed:        { },                          // If the user was referred from a link, and the link has associated data, the data is passed in here.
  ///           referring_identity: '12345',                      // If the user was referred from a link, and the link was created by a user with an identity, that identity is here.
  ///           has_app:            true,                         // Does the user have the app installed already?
  ///           identity:           'BranchUser',                 // Unique string that identifies the user
  ///           ~referring_link:     'https://bnc.lt/c/jgg75-Gjd3' // The referring link click, if available.
  ///      }
  /// );
  /// Note: Branch.init must be called prior to calling any other Branch functions.
  @JS('init')
  external static void init(String branchKey,
      [Object? options, Function? callback]);

  /// link(data, callback)
  /// Parameters
  ///
  /// data: Object, required - link data and metadata.
  ///
  /// callback: function, required - returns a string of the Branch deep
  /// linking URL.
  ///
  /// Formerly createLink()
  ///
  /// Creates and returns a deep linking URL. The data parameter can include an
  /// object with optional data you would like to store, including Facebook
  /// Open Graph data.
  ///
  /// data The dictionary to embed with the link. Accessed as session or install parameters from
  /// the SDK.
  ///
  /// Note
  /// You can customize the Facebook OG tags of each URL if you want to dynamically share content by
  /// using the following optional keys in the data dictionary. Please use this
  /// Facebook tool to debug your OG tags!
  ///
  /// Key	Value
  /// "$og_title"	The title you'd like to appear for the link in social media
  /// "$og_description"	The description you'd like to appear for the link in social media
  /// "$og_image_url"	The URL for the image you'd like to appear for the link in social media
  /// "$og_video"	The URL for the video
  /// "$og_url"	The URL you'd like to appear
  /// "$og_redirect"	If you want to bypass our OG tags and use your own, use this key with the URL that contains your site's metadata.
  /// Also, you can set custom redirection by inserting the following optional keys in the dictionary:
  ///
  /// Key	Value
  /// "$desktop_url"	Where to send the user on a desktop or laptop. By default it is the Branch-hosted text-me service
  /// "$android_url"	The replacement URL for the Play Store to send the user if they don't have the app. Only necessary if you want a mobile web splash
  /// "$ios_url"	The replacement URL for the App Store to send the user if they don't have the app. Only necessary if you want a mobile web splash
  /// "$ipad_url"	Same as above but for iPad Store
  /// "$fire_url"	Same as above but for Amazon Fire Store
  /// "$blackberry_url"	Same as above but for Blackberry Store
  /// "$windows_phone_url"	Same as above but for Windows Store
  /// "$after_click_url"	When a user returns to the browser after going to the app, take them to this URL. iOS only; Android coming soon
  /// You have the ability to control the direct deep linking of each link as well:
  ///
  /// Key	Value
  /// "$deeplink_path"	The value of the deep link path that you'd like us to append to your URI. For example, you could specify "$deeplink_path": "radio/station/456" and we'll open the app with the URI "yourapp://radio/station/456?link_click_id=branch-identifier". This is primarily for supporting legacy deep linking infrastructure.
  /// "$always_deeplink"	true or false. (default is not to deep link first) This key can be specified to have our linking service force try to open the app, even if we're not sure the user has the app installed. If the app is not installed, we fall back to the respective app store or $platform_url key. By default, we only open the app if we've seen a user initiate a session in your app from a Branch link (has been cookied and deep linked by Branch).
  /// Usage
  ///
  /// branch.link(
  ///     data,
  ///     callback (err, link)
  /// );
  /// Example
  ///
  /// branch.link({
  ///     tags: [ 'tag1', 'tag2' ],
  ///     channel: 'facebook',
  ///     feature: 'dashboard',
  ///     stage: 'new user',
  ///     data: {
  ///         mydata: 'something',
  ///         foo: 'bar',
  ///         '$desktop_url': 'http://myappwebsite.com',
  ///         '$ios_url': 'http://myappwebsite.com/ios',
  ///         '$ipad_url': 'http://myappwebsite.com/ipad',
  ///         '$android_url': 'http://myappwebsite.com/android',
  ///         '$og_app_id': '12345',
  ///         '$og_title': 'My App',
  ///         '$og_description': 'My app\'s description.',
  ///         '$og_image_url': 'http://myappwebsite.com/image.png'
  ///     }
  /// }, function(err, link) {
  ///     console.log(err, link);
  /// });
  /// Callback Format
  ///
  /// callback(
  ///     "Error message",
  ///     'https://bnc.lt/l/3HZMytU-BW' // Branch deep linking URL
  /// );
  @JS('link')
  external static void link(Object data, Function callback);

  /// logout(callback)
  /// Parameters
  ///
  /// callback: function, optional
  ///
  /// Logs out the current session, replaces session IDs and identity IDs.
  ///
  /// Usage
  ///
  /// branch.logout(
  ///     callback (err)
  /// );
  /// Callback Format
  ///
  /// callback(
  ///      "Error message"
  /// );
  @JS('logout')
  external static void logout([Function callback]);

  /// removeListener(listener)
  /// Parameters
  ///
  /// listener: function, required - Reference to the listening function you
  /// would like to remove. note: this must be the same reference that was passed to
  /// branch.addListener(), not an identical clone of the function.
  ///
  /// Remove the listener from observations, if it is present. Not that this function must be
  /// passed a referrence to the same function that was passed to branch.addListener(), not
  /// just an identical clone of the function.
  @JS('removeListener')
  external static void removeListener(Function listener);

  /// sendSMS(phone, linkData, options, callback)
  /// Parameters
  ///
  /// phone: string, required - phone number to send SMS to
  ///
  /// linkData: Object, required - object of link data
  ///
  /// options: Object, optional - options: make_new_link, which forces the creation of a
  /// new link even if one already exists
  ///
  /// callback: function, optional - Returns an error if unsuccessful
  ///
  /// Formerly SMSLink()
  ///
  /// A robust function to give your users the ability to share links via SMS. If
  /// the user navigated to this page via a Branch link, sendSMS will send that
  /// same link. Otherwise, it will create a new link with the data provided in
  /// the params argument. sendSMS also registers a click event with the
  /// channel pre-filled with 'sms' before sending an sms to the provided
  /// phone parameter. This way the entire link click event is recorded starting
  /// with the user sending an sms.
  ///
  /// Note: sendSMS will automatically send a previously generated link click,
  /// along with the data object in the original link. Therefore, it is unneccessary for the
  /// data() method to be called to check for an already existing link. If a link already
  /// exists, sendSMS will simply ignore the data object passed to it, and send the existing link.
  /// If this behavior is not desired, set make_new_link: true in the options object argument
  /// of sendSMS, and sendSMS will always make a new link.
  ///
  /// Supports international SMS.
  ///
  /// Please note that the destination phone number needs to be from the same country the SMS is being sent from.
  ///
  /// Usage
  ///
  /// branch.sendSMS(
  ///     phone,
  ///     linkData,
  ///     options,
  ///     callback (err, data)
  /// );
  /// Example
  ///
  /// var linkData = {
  ///     tags: ['tag1', 'tag2'],
  ///     channel: 'Website',
  ///     feature: 'TextMeTheApp',
  ///     data: {
  ///         // here's how to define the deeplink_path and the custom text on the front end
  ///         $deeplink_path: `custom_deeplink_path`,
  ///         //for the custom text, use {{link}} as a macro for link location
  ///         $custom_sms_text: `Here's my custom text, and here is the {{ link }}`,
  ///         mydata: 'something',
  ///         foo: 'bar',
  ///         '$desktop_url': 'http://myappwebsite.com',
  ///         '$ios_url': 'http://myappwebsite.com/ios',
  ///         '$ipad_url': 'http://myappwebsite.com/ipad',
  ///         '$android_url': 'http://myappwebsite.com/android',
  ///         '$og_app_id': '12345',
  ///         '$og_title': 'My App',
  ///         '$og_description': 'My app\'s description.',
  ///         '$og_image_url': 'http://myappwebsite.com/image.png'
  ///     }
  /// }
  /// branch.sendSMS(
  ///     '9999999999',
  ///     linkData,
  ///     { make_new_link: false }, // Default: false. If set to true, sendSMS will generate a new link even if one already exists.
  ///     function(err) { console.log(err); }
  /// );
  /// Callback Format
  ///
  /// callback("Error message");
  @JS('sendSMS')
  external static void sendSMS(String phone, Object linkData,
      [Object options, Function callback]);

  /// setBranchViewData(data)
  /// Parameters
  ///
  /// data: Object, required - object of all link data, same as Branch.link()
  ///
  /// This function lets you set the deep link data dynamically for a given mobile web Journey. For
  /// example, if you desgin a full page interstitial, and want the deep link data to be custom for each
  /// page, you'd need to use this function to dynamically set the deep link params on page load. Then,
  /// any Journey loaded on that page will inherit these deep link params.
  ///
  /// Usage
  ///
  /// branch.setBranchViewData(
  ///   data // Data for link, same as Branch.link()
  /// );
  /// Example
  ///
  /// branch.setBranchViewData({
  ///   tags: ['tag1', 'tag2'],
  ///   data: {
  ///     mydata: 'something',
  ///     foo: 'bar',
  ///     '$deeplink_path': 'open/item/1234'
  ///   }
  /// });
  @JS('setBranchViewData')
  external static void setBranchViewData(Object data);

  /// setIdentity(identity, callback)
  /// Parameters
  ///
  /// identity: string, required - a string uniquely identifying the user - often a user ID
  /// or email address.
  ///
  /// callback: function, optional - callback that returns the user's
  /// Branch identity id and unique link.
  ///
  /// Formerly identify()
  ///
  /// Sets the identity of a user and returns the data. To use this function, pass
  /// a unique string that identifies the user - this could be an email address,
  /// UUID, Facebook ID, etc.
  ///
  /// Usage
  ///
  /// branch.setIdentity(
  ///     identity,
  ///     callback (err, data)
  /// );
  /// Callback Format
  ///
  /// callback(
  ///      "Error message",
  ///      {
  ///           identity_id:             '12345', // Server-generated ID of the user identity, stored in `sessionStorage`.
  ///           link:                    'url',   // New link to use (replaces old stored link), stored in `sessionStorage`.
  ///           referring_data_parsed:    { },      // Returns the initial referring data for this identity, if exists, as a parsed object.
  ///           referring_identity:      '12345'  // Returns the initial referring identity for this identity, if exists.
  ///      }
  /// );
  @JS('setIdentity')
  external static void setIdentity(String identity, [Function callback]);

  /// track(event, metadata, callback)
  /// Parameters
  ///
  /// event: string, required - name of the event to be tracked.
  ///
  /// metadata: Object, optional - object of event metadata.
  ///
  /// callback: function, optional
  ///
  /// This function allows you to track any event with supporting metadata.
  /// The metadata parameter is a formatted JSON object that can contain
  /// any data and has limitless hierarchy
  ///
  /// Usage
  ///
  /// branch.track(
  ///     event,
  ///     metadata,
  ///     callback (err)
  /// );
  /// Callback Format
  ///
  /// callback("Error message");
  @JS('track')
  external static void track(String event,
      [Object metadata, Function callback]);

  /// trackCommerceEvent(event, commerce_data, metadata, callback)
  /// Parameters
  ///
  /// event: String, required - Name of the commerce event to be tracked. We currently support 'purchase' events
  ///
  /// commerce_data: Object, required - Data that describes the commerce event
  ///
  /// metadata: Object, optional - metadata you may want add to the event
  ///
  /// callback: function, optional - Returns an error if unsuccessful
  ///
  /// Sends a user commerce event to the server
  ///
  /// Use commerce events to track when a user purchases an item in your online store,
  /// makes an in-app purchase, or buys a subscription. The commerce events are tracked in
  /// the Branch dashboard along with your other events so you can judge the effectiveness of
  /// campaigns and other analytics.
  ///
  /// Usage
  ///
  /// branch.trackCommerceEvent(
  ///     event,
  ///     commerce_data,
  ///     metadata,
  ///     callback (err)
  /// );
  /// Example
  ///
  /// var commerce_data = {
  ///     "revenue": 50.0,
  ///     "currency": "USD",
  ///     "transaction_id": "foo-transaction-id",
  ///     "shipping": 0.0,
  ///     "tax": 5.0,
  ///     "affiliation": "foo-affiliation",
  ///     "products": [
  ///          { "sku": "foo-sku-1", "name": "foo-item-1", "price": 45.00, "quantity": 1, "brand": "foo-brand",
  ///            "category": "Electronics", "variant": "foo-variant-1"},
  ///          { "sku": "foo-sku-2", "price": 2.50, "quantity": 2}
  ///      ],
  /// };
  ///
  /// var metadata =  { "foo": "bar" };
  ///
  /// branch.trackCommerceEvent('purchase', commerce_data, metadata, function(err) {
  ///     if(err) {
  ///          throw err;
  ///     }
  /// });
  @JS('trackCommerceEvent')
  external static void trackCommerceEvent(String name, Object commerceData,
      [Object metadata, Function callback]);

  /// logEvent(event, event_data_and_custom_data, content_items, customer_event_alias, callback)
  /// Parameters
  ///
  /// event: String, required
  ///
  /// event_data_and_custom_data: Object, optional
  ///
  /// content_items: Array, optional
  ///
  /// customer_event_alias: String, optional
  ///
  /// callback: function, optional
  ///
  /// Register commerce events, content events, user lifecycle events and custom events via logEvent()
  ///
  /// NOTE: If this is the first time you are integrating our new event tracking feature via logEvent(), please use the latest Branch WebSDK snippet from the Installation section. This has been updated in v2.30.0 of our SDK.
  ///
  /// The guides below provide information about what keys can be sent when triggering these event types:
  ///
  /// Logging Commerce Events
  /// Logging Content Events
  /// Logging User Lifecycle
  /// Logging Custom Events
  /// Usage for Commerce, Content & User Lifecycle "Standard Events"
  ///
  /// branch.logEvent(
  ///     event,
  ///     event_data_and_custom_data,
  ///     content_items,
  ///     customer_event_alias,
  ///     callback (err)
  /// );
  /// Usage for "Custom Events"
  ///
  /// JavaScript
  /// JavaScript
  /// branch.logEvent(
  ///     event,
  ///     custom_data,
  ///     callback (err)
  /// );
  /// ``
  /// **Notes**:
  /// - logEvent() sends user_data automatically
  /// - When firing Standard Events, send custom and event data as part of the same object
  /// - Custom Events do not contain content items and event data
  ///
  /// ### Example -- How to log a Commerce Event
  /// var event_and_custom_data = {
  ///    "transaction_id": "tras_Id_1232343434",
  ///    "currency": "USD",
  ///    "revenue": 180.2,
  ///    "shipping": 10.5,
  ///    "tax": 13.5,
  ///    "coupon": "promo-1234",
  ///    "affiliation": "high_fi",
  ///    "description": "Preferred purchase",
  ///    "purchase_loc": "Palo Alto",
  ///    "store_pickup": "unavailable"
  /// };
  /// var content_items = [
  /// {
  ///    "$content_schema": "COMMERCE_PRODUCT",
  ///    "$og_title": "Nike Shoe",
  ///    "$og_description": "Start loving your steps",
  ///    "$og_image_url": "http:///example.com/img1.jpg",
  ///    "$canonical_identifier": "nike/1234",
  ///    "$publicly_indexable": false,
  ///    "$price": 101.2,
  ///    "$locally_indexable": true,
  ///    "$quantity": 1,
  ///    "$sku": "1101123445",
  ///    "$product_name": "Runner",
  ///    "$product_brand": "Nike",
  ///    "$product_category": "Sporting Goods",
  ///    "$product_variant": "XL",
  ///    "$rating_average": 4.2,
  ///    "$rating_count": 5,
  ///    "$rating_max": 2.2,
  ///    "$creation_timestamp": 1499892854966,
  ///    "$exp_date": 1499892854966,
  ///    "$keywords": [ "sneakers", "shoes" ],
  ///    "$address_street": "230 South LaSalle Street",
  ///    "$address_city": "Chicago",
  ///    "$address_region": "IL",
  ///    "$address_country": "US",
  ///    "$address_postal_code": "60604",
  ///    "$latitude": 12.07,
  ///    "$longitude": -97.5,
  ///    "$image_captions": [ "my_img_caption1", "my_img_caption_2" ],
  ///    "$condition": "NEW",
  ///    "$custom_fields": {"foo1":"bar1","foo2":"bar2"}
  /// },
  /// {
  ///    "$og_title": "Nike Woolen Sox",
  ///    "$canonical_identifier": "nike/5324",
  ///    "$og_description": "Fine combed woolen sox for those who love your foot",
  ///    "$publicly_indexable": false,
  ///    "$price": 80.2,
  ///    "$locally_indexable": true,
  ///    "$quantity": 5,
  ///    "$sku": "110112467",
  ///    "$product_name": "Woolen Sox",
  ///    "$product_brand": "Nike",
  ///    "$product_category": "Apparel & Accessories",
  ///    "$product_variant": "Xl",
  ///    "$rating_average": 3.3,
  ///    "$rating_count": 5,
  ///    "$rating_max": 2.8,
  ///    "$creation_timestamp": 1499892854966
  /// }];
  /// var customer_event_alias = "event alias";
  /// branch.logEvent(
  ///    "PURCHASE",
  ///    event_and_custom_data,
  ///    content_items,
  ///    customer_event_alias,
  ///    function(err) { console.log(err); }
  /// );

  @JS('logEvent')
  external static void logEvent(String event,
      [Object eventDataAndCustomData,
      Object contentItems,
      String customerEventAlias,
      Function callback]);

  /// disableTracking(disableTracking)
  /// Parameters
  ///
  /// disableTracking: Boolean, optional - true disables tracking and false re-enables tracking.
  ///
  /// Notes:
  ///
  /// disableTracking() without a parameter is a shorthand for disableTracking(true).
  /// If a call to disableTracking(false) is made, the WebSDK will re-initialize. Additionally, if tracking_disabled: true is passed
  /// as an option to init(), it will be removed during the reinitialization process.
  /// Allows User to Remain Private
  ///
  /// This will prevent any Branch requests from being sent across the network, except for the case of deep linking.
  /// If someone clicks a Branch link, but has expressed not to be tracked, we will return deep linking data back to the
  /// client but without tracking information.
  ///
  /// In do-not-track mode, you will still be able to create links and display Journeys however, they will not have identifiable
  /// information associated to them. You can change this behavior at any time, by calling the aforementioned function.
  /// The do-not-track mode state is persistent: it is saved for the user across browser sessions for the web site.
  @JS('disableTracking')
  external static void disableTracking([bool disableTracking]);

  /// lastAttributedTouchData (number, callback)
  ///
  /// number -attribution_window - the number of days to look up attribution data
  /// callback: function, optional - returns last attributed touch data
  ///
  /// Returns last attributed touch data for current user. Last attributed touch
  /// data has the information associated with that user's last viewed impression
  /// or clicked link.
  /// Usage
  ///
  /// branch.lastAttributedTouchData(
  ///     attribution_window,
  ///     callback (err, data)
  /// );
  /// Example
  ///
  /// branch.lastAttributedTouchData(
  ///     10,
  ///     function(err, data) {
  ///     console.log(err, data);
  /// });
  /// Callback Format
  ///
  /// callback(
  ///     "Error message",
  ///     '{}'
  /// );
  @JS('lastAttributedTouchData')
  external static void lastAttributedTouchData(attributionWindow,
      [Function callback]);

  /// qrcode(data, callback)
  /// Parameters
  ///
  /// data: Object, required - link data and metadata.
  ///qrCodeSettings: Object required -QR code Settings
  ///
  /// callback: function, required - returns a string of the Branch deep
  /// linking URL.
  ///
  /// Formerly createLink()
  ///
  /// Creates and returns a deep linking URL. The data parameter can include an
  /// object with optional data you would like to store, including Facebook
  /// Open Graph data.
  ///
  /// data The dictionary to embed with the link. Accessed as session or install parameters from
  /// the SDK.
  ///
  /// Note
  /// You can customize the Facebook OG tags of each URL if you want to dynamically share content by
  /// using the following optional keys in the data dictionary. Please use this
  /// Facebook tool to debug your OG tags!
  ///
  /// Key	Value
  /// "$og_title"	The title you'd like to appear for the link in social media
  /// "$og_description"	The description you'd like to appear for the link in social media
  /// "$og_image_url"	The URL for the image you'd like to appear for the link in social media
  /// "$og_video"	The URL for the video
  /// "$og_url"	The URL you'd like to appear
  /// "$og_redirect"	If you want to bypass our OG tags and use your own, use this key with the URL that contains your site's metadata.
  /// Also, you can set custom redirection by inserting the following optional keys in the dictionary:
  ///
  /// Key	Value
  /// "$desktop_url"	Where to send the user on a desktop or laptop. By default it is the Branch-hosted text-me service
  /// "$android_url"	The replacement URL for the Play Store to send the user if they don't have the app. Only necessary if you want a mobile web splash
  /// "$ios_url"	The replacement URL for the App Store to send the user if they don't have the app. Only necessary if you want a mobile web splash
  /// "$ipad_url"	Same as above but for iPad Store
  /// "$fire_url"	Same as above but for Amazon Fire Store
  /// "$blackberry_url"	Same as above but for Blackberry Store
  /// "$windows_phone_url"	Same as above but for Windows Store
  /// "$after_click_url"	When a user returns to the browser after going to the app, take them to this URL. iOS only; Android coming soon
  /// You have the ability to control the direct deep linking of each link as well:
  ///
  /// Key	Value
  /// "$deeplink_path"	The value of the deep link path that you'd like us to append to your URI. For example, you could specify "$deeplink_path": "radio/station/456" and we'll open the app with the URI "yourapp://radio/station/456?link_click_id=branch-identifier". This is primarily for supporting legacy deep linking infrastructure.
  /// "$always_deeplink"	true or false. (default is not to deep link first) This key can be specified to have our linking service force try to open the app, even if we're not sure the user has the app installed. If the app is not installed, we fall back to the respective app store or $platform_url key. By default, we only open the app if we've seen a user initiate a session in your app from a Branch link (has been cookied and deep linked by Branch).
  /// Usage
  ///
  /// branch.link(
  ///     data,
  ///     callback (err, link)
  /// );
  /// Example
  ///
  /// branch.link({
  ///     tags: [ 'tag1', 'tag2' ],
  ///     channel: 'facebook',
  ///     feature: 'dashboard',
  ///     stage: 'new user',
  ///     data: {
  ///         mydata: 'something',
  ///         foo: 'bar',
  ///         '$desktop_url': 'http://myappwebsite.com',
  ///         '$ios_url': 'http://myappwebsite.com/ios',
  ///         '$ipad_url': 'http://myappwebsite.com/ipad',
  ///         '$android_url': 'http://myappwebsite.com/android',
  ///         '$og_app_id': '12345',
  ///         '$og_title': 'My App',
  ///         '$og_description': 'My app\'s description.',
  ///         '$og_image_url': 'http://myappwebsite.com/image.png'
  ///     }
  /// }, function(err, link) {
  ///     console.log(err, link);
  /// });
  /// Callback Format
  ///
  /// callback(
  ///     "Error message",
  ///     'https://bnc.lt/l/3HZMytU-BW' // Branch deep linking URL
  /// );

  @JS('qrCode')
  external static void qrCode(Object qrCodeLinkData, Object qrCodeSettings,
      Function(String? err, QrCodeData? qrCode) callback);

  /// Sets the value of parameters required by Google Conversion APIs for DMA Compliance in EEA region.
  /// [eeaRegion] `true` If European regulations, including the DMA, apply to this user and conversion.
  /// [adPersonalizationConsent] `true` If End user has granted/denied ads personalization consent.
  /// [adUserDataUsageConsent] `true If User has granted/denied consent for 3P transmission of user level data for ads.
  @JS('setDMAParamsForEEA')
  external static void setDMAParamsForEEA(bool eeaRegion,
      bool adPersonalizationConsent, bool adUserDataUsageConsent);

  @JS('setRequestMetadata')
  external static void setRequestMetadata(String key, String value);
}
