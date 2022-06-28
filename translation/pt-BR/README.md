Language: [English](https://github.com/RodrigoSMarques/flutter_branch_sdk/blob/master/README.md) | [Português](https://github.com/RodrigoSMarques/flutter_branch_sdk/blob/master/translation/pt-BR/README.md)

# flutter_branch_sdk

Flutter plugin que implementa Branch SDK  (https://branch.io).

Branch.io ajuda os aplicativos móveis a crescer com deep links que aumentam os sistemas de referência, compartilhando links e convites com atribuição e análise completa.

Suporta Android e iOS.
* Android - Branch SDK Version >= 5.0.1 [Histório da versão Android](https://help.branch.io/developers-hub/docs/android-version-history)
* iOS - Branch SDK Version >= 0.33.0 [Histórico da versão iOS](https://help.branch.io/developers-hub/docs/ios-version-history)

Funções implementadas neste plugin:

* Teste da Integração Branch
* Rastreamento de usuário
* Habilitar / Desativar rastreamento de usuários
* Obter o primeiro e o último parâmetros
* Gerar Deep Link para Branch Universal Object (BUO)
* Exibir página de compartilhamento para Branch Universal Object (BUO)
* Listar / Remover BUO na pesquisa do Android e iOS
* Registrar visualizações
* Rastrear ações e eventos do usuário
* Recompensas por indicação

## Começando
### Configurar o Painel da Branch
* Registrar seu aplicativo
* Completar a integração básica no [Branch Dashboard](https://dashboard.branch.io/login)

Para detalhes visutar:
* [iOS - somente a seção: **Configure Branch**](https://help.branch.io/developers-hub/docs/ios-basic-integration#configure-branch)
* [Android - somente a seção: **Configure Branch Dashboard**](https://help.branch.io/developers-hub/docs/android-basic-integration#configure-branch-dashboard)

## Configurar os projetos em cada Plataforam
### Integração Android

Siga as etapas na página [https://help.branch.io/developers-hub/docs/android-basic-integration#configure-app](https://help.branch.io/developers-hub/docs/android-basic-integration#configure-app), session _**Configure app**_:
* Add Branch to your `AndroidManifest.xml`

### Integração iOS
Siga as etapas na página [https://help.branch.io/developers-hub/docs/ios-basic-integration#configure-bundle-identifier](https://help.branch.io/developers-hub/docs/ios-basic-integration#configure-bundle-identifier), from session ```Configure bundle identifier```:
* Configure bundle identifier
* Configure associated domains
* Configure entitlements
* Configure Info.plist
* Confirm app prefix

Nota 1: Branch SDK 0.32.0 requer `iOS 9.0`. <br/>
        Atualize a versão mínima no projeto, na seção **"Deployment Info" -> "Target"**.

Nota 2:  No `Info.plist` não adicionar `branch_key` `live` e `test` ao mesmo tempo.<br />
Use somente `branch_key` e atualize se necessário.


## Instalação
Para usar este plugin, adicione `flutter_branch_sdk` na seção [dependency do seu arquivo pubspec.yaml](https://flutter.io/platform-plugins/).

## Como usuar

### Testar a integração Branch
Teste se a configuração do Branch foi realizada no código nativo chamando:
```dart
FlutterBranchSdk.validateSDKIntegration();
```
Verifique os logs para garantir que todos os testes de integração do SDK foram aprovados.

Exemplo da log:
```java
------------------- Initiating Branch integration verification --------------------------- ... 
1. Verifying Branch instance creation ... 
Passed
2. Checking Branch keys ... 
Passed
3. Verifying application package name ... 
Passed
4. Checking Android Manifest for URI based deep link config ... 
Passed
5. Verifying URI based deep link config with Branch dash board. ... 
Passed
6. Verifying intent for receiving URI scheme. ... 
Passed
7. Checking AndroidManifest for AppLink config. ... 
Passed
8. Verifying any supported custom link domains. ... 
Passed
9. Verifying default link domains integrations. ... 
Passed
10. Verifying alternate link domains integrations. ... 
Passed
Passed
--------------------------------------------
Successfully completed Branch integration validation. Everything looks good!
 
Great! Comment out the 'validateSDKIntegration' line in your app. Next check your deep link routing.
Append '?bnc_validate=true' to any of your app's Branch links and click it on your mobile device (not the Simulator!) to start the test.
For instance, to validate a link like:
https://<yourapp>.app.link/NdJ6nFzRbK
click on:
https://<yourapp>.app.link/NdJ6nFzRbK?bnc_validate=true
```
Certifique-se de comentar ou remover `validateSDKIntegration` na versão de release para produção.

### Inicializar Branch ler o deep link
```dart
    StreamSubscription<Map> streamSubscription = FlutterBranchSdk.initSession().listen((data) {
      if (data.containsKey("+clicked_branch_link") &&
          data["+clicked_branch_link"] == true) {
         //Link clicked. Add logic to get link data
         print('Custom string: ${data["custom_string"]}');
      }
    }, onError: (error) {
      PlatformException platformException = error as PlatformException;
      print(
          'InitSession error: ${platformException.code} - ${platformException.message}');
    });
```
### Recuperar parâmetros de instalação (somente instalação)
These session parameters will be available at any point later on with this command. If no parameters are available then Branch will return an empty dictionary. This refreshes with every new session (app installs AND app opens).
Esses parâmetros da sessão estarão disponíveis a qualquer momento posteriormente com este comando. Se nenhum parâmetro estiver disponível, o Branch retornará um dicionário vazio. Isso é atualizado a cada nova sessão (na instalação do aplicativo e o aplicativo é aberto).
```dart
    Map<dynamic, dynamic> params = await FlutterBranchSdk.getFirstReferringParams();
```
### Retrieve session (install or open) parameters
If you ever want to access the original session params (the parameters passed in for the first install event only), you can use this line. This is useful if you only want to reward users who newly installed the app from a referral link
```dart
    Map<dynamic, dynamic> params = await FlutterBranchSdk.getLatestReferringParams();
```
### Create content reference
The Branch Universal Object encapsulates the thing you want to share.
```dart
    BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: 'flutter/branch',
      title: 'Flutter Branch Plugin',
      imageUrl: 'https://flutter.dev/assets/flutter-lockup-4cb0ee072ab312e59784d9fbf4fb7ad42688a7fdaea1270ccf6bbf4f34b7e03f.svg',
      contentDescription: 'Flutter Branch Description',
      keywords: ['Plugin', 'Branch', 'Flutter'],
      publiclyIndex: true,
      locallyIndex: true,
      contentMetadata: BranchContentMetaData()..addCustomMetadata('custom_string', 'abc')
          ..addCustomMetadata('custom_number', 12345)
          ..addCustomMetadata('custom_bool', true)
          ..addCustomMetadata('custom_list_number', [1,2,3,4,5 ])
          ..addCustomMetadata('custom_list_string', ['a', 'b', 'c']),
    );
```
### Create link reference
* Generates the analytical properties for the deep link
* Used for Create deep link and Share deep link
```dart
    BranchLinkProperties lp = BranchLinkProperties(
        channel: 'facebook',
        feature: 'sharing',
        stage: 'new share',
      tags: ['one', 'two', 'three']
    );
    lp.addControlParam('url', 'http://www.google.com');
    lp.addControlParam('url2', 'http://flutter.dev');
```
### Create deep link
Generates a deep link within your app
```dart
    BranchResponse response =
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    if (response.success) {
      print('Link generated: ${response.result}');
    } else {
        print('Error : ${response.errorCode} - ${response.errorMessage}');
    }
```
### Show Share Sheet deep link
Will generate a Branch deep link and tag it with the channel the user selects.
Note: _For Android additional customization is possible_
```dart
    BranchResponse response = await FlutterBranchSdk.showShareSheet(
        buo: buo,
        linkProperties: lp,
        messageText: 'My Share text',
        androidMessageTitle: 'My Message Title',
        androidSharingTitle: 'My Share with');

    if (response.success) {
      print('showShareSheet Sucess');
    } else {
      print('Error : ${response.errorCode} - ${response.errorMessage}');
    }
```
### List content on Search
* For Android list BUO links in Google Search with App Indexing
* For iOs list BUO links in Spotlight

Enable automatic sitemap generation on the Organic Search page of the [Branch Dashboard](https://dashboard.branch.io/search).
Check the Automatic sitemap generation checkbox.

```dart
    bool success = await FlutterBranchSdk.listOnSearch(buo: buo);
    print(success);
```
### Remove content from Search
Privately indexed Branch Universal Object can be removed
```dart
    bool success = await FlutterBranchSdk.removeFromSearch(buo: buo);
    print('Remove sucess: $success');
```
### Register Event VIEW_ITEM
Mark the content referred by this object as viewed. This increment the view count of the contents referred by this object.
```dart
FlutterBranchSdk.registerView(buo: buo);
```

### Tracking User Actions and Events
Use the `BranchEvent` interface to track special user actions or application specific events beyond app installs, opens, and sharing. You can track events such as when a user adds an item to an on-line shopping cart, or searches for a keyword, among others.
The `BranchEvent` interface provides an interface to add contents represented by `BranchUniversalObject` in order to associate app contents with events.
Analytics about your app's BranchEvents can be found on the Branch dashboard, and BranchEvents also provide tight integration with many third party analytics providers.
```dart
BranchEvent eventStandart = BranchEvent.standardEvent(BranchStandardEvent.ADD_TO_CART);
FlutterBranchSdk.trackContent(buo: buo, branchEvent: eventStandart);
```
You can use your own custom event names too:
```dart
BranchEvent eventCustom = BranchEvent.customEvent('Custom_event');
FlutterBranchSdk.trackContent(buo: buo, branchEvent: eventCustom);
```
Extra event specific data can be tracked with the event as well:
```dart
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
    FlutterBranchSdk.trackContent(buo: buo, branchEvent: eventStandart);
```

You can register logs in BranchEvent without Branch Universal Object (BUO) for tracking and analytics:
```dart
BranchEvent eventStandart = BranchEvent.standardEvent(BranchStandardEvent.ADD_TO_CART);
FlutterBranchSdk.trackContentWithoutBuo(branchEvent: eventStandart);
```
You can use your own custom event names too:
```dart
BranchEvent eventCustom = BranchEvent.customEvent('Custom_event');
FlutterBranchSdk.trackContentWithoutBuo(branchEvent: eventCustom);
```

### Track users
Sets the identity of a user (email, ID, UUID, etc) for events, deep links, and referrals
```dart
//login
FlutterBranchSdk.setIdentity('user1234567890');
```
```dart
//logout
FlutterBranchSdk.logout();
```
```dart
//check if user is identify
 bool isUserIdentified = await FlutterBranchSdk.isUserIdentified();
```


### Enable or Disable User Tracking
If you need to comply with a user's request to not be tracked for GDPR purposes, or otherwise determine that a user should not be tracked, utilize this field to prevent Branch from sending network requests. This setting can also be enabled across all users for a particular link, or across your Branch links.
```dart
FlutterBranchSdk.disableTracking(false);
```
```dart
FlutterBranchSdk.disableTracking(true);
```
You can choose to call this throughout the lifecycle of the app. Once called, network requests will not be sent from the SDKs. Link generation will continue to work, but will not contain identifying information about the user. In addition, deep linking will continue to work, but will not track analytics for the user.

### Referral System Rewarding Functionality
Reward balances change randomly on the backend when certain actions are taken (defined by your rules), so you'll need to make an asynchronous call to retrieve the balance.
Read more here: https://docs.branch.io/viral/referrals/#search


#### Get Reward Balance
Reward balances change randomly on the backend when certain actions are taken (defined by your rules), so you'll need to make call to retrieve the balance. Here is the syntax:

***optional parameter***: bucket - value containing the name of the referral bucket to attempt to redeem credits from

```dart
BranchResponse response =
    await FlutterBranchSdk.loadRewards();
if (response.success) {
    credits = response.result;
    print('Crédits');
} else {
    print('Credits error: ${response.errorMessage}');
}
```


#### Redeem All or Some of the Reward Balance (Store State)
Redeeming credits allows users to cash in the credits they've earned. Upon successful redemption, the user's balance will be updated reflecting the deduction.

***optional parameter***: bucket - value containing the name of the referral bucket to attempt to redeem credits from

```dart
BranchResponse response =
    await FlutterBranchSdk.redeemRewards(count: 5);
if (response.success) {
    print('Redeeming Credits with success');
} else {
    print('Redeeming Credits with error: ${response.errorMessage}');
}
```
#### Get Credit History
This call will retrieve the entire history of credits and redemptions from the individual user. To use this call, implement like so:

***optional parameter***: bucket - value containing the name of the referral bucket to attempt to redeem credits from

```dart
BranchResponse response =
    await FlutterBranchSdk.getCreditHistory();
if (response.success) {
    print('getCreditHistory with success. Records: ${(response.result as List).length}');
} else {
    print('getCreditHistory with error: ${response.errorMessage}');
}
```
The response will return an list of map:
```json
[
    {
        "transaction": {
                           "date": "2014-10-14T01:54:40.425Z",
                           "id": "50388077461373184",
                           "bucket": "default",
                           "type": 0,
                           "amount": 5
                       },
        "event" : {
            "name": "event name",
            "metadata": { your event metadata if present }
        },
        "referrer": "12345678",
        "referree": null
    },
    {
        "transaction": {
                           "date": "2014-10-14T01:55:09.474Z",
                           "id": "50388199301710081",
                           "bucket": "default",
                           "type": 2,
                           "amount": -3
                       },
        "event" : {
            "name": "event name",
            "metadata": { your event metadata if present }
        },
        "referrer": null,
        "referree": "12345678"
    }
]
```
**referrer** : The id of the referring user for this credit transaction. Returns null if no referrer is involved. Note this id is the user id in a developer's own system that's previously passed to Branch's identify user API call.

**referree** : The id of the user who was referred for this credit transaction. Returns null if no referree is involved. Note this id is the user id in a developer's own system that's previously passed to Branch's identify user API call.

**type** : This is the type of credit transaction.

* 0 - A reward that was added automatically by the user completing an action or promo.
* 1 - A reward that was added manually.
* 2 - A redemption of credits that occurred through our API or SDKs.
* 3 - This is a very unique case where we will subtract credits automatically when we detect fraud.


# Getting Started
See the `example` directory for a complete sample app using Branch SDK.

![Example app](https://user-images.githubusercontent.com/17687286/74096674-725c4200-4ae0-11ea-8ef6-94bc02e1913b.png)

# Branch Universal Object best practices

Here are a set of best practices to ensure that your analytics are correct, and your content is ranking on Spotlight effectively.

1. Set the canonicalIdentifier to a unique, de-duped value across instances of the app
2. Ensure that the title, contentDescription and imageUrl properly represent the object
3. Initialize the Branch Universal Object and call `FlutterBranchSdk.registerView(buo: buo);` on `initState()`
4. Call `showShareSheet` and `getShortUrl` later in the life cycle, when the user takes an action that needs a link
5. Call the additional object events (purchase, share completed, etc) when the corresponding user action is taken

Practices to avoid:

1. Don't set the same title, contentDescription and imageUrl across all objects.
2. Don't wait to initialize the object and register views until the user goes to share.
3. Don't wait to initialize the object until you conveniently need a link.
4. Don't create many objects at once and register views in a for loop.

# Branch Documentation
Read the iOS or Android documentation for all Branch object parameters
* Android - [https://help.branch.io/developers-hub/docs/android-advanced-features](https://help.branch.io/developers-hub/docs/android-advanced-features)
* iOS - [https://help.branch.io/developers-hub/docs/ios-advanced-features](https://help.branch.io/developers-hub/docs/ios-advanced-features)

# Author
This project was authored by Rodrigo S. Marques. You can contact me at rodrigosmarques@gmail.com

