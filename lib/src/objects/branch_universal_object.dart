library flutter_branch_sdk_objects;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'branch_event.dart';
part 'branch_qrcode.dart';
part 'branch_response.dart';
part 'content_meta_data.dart';
part 'content_schema.dart';
part 'link_properties.dart';

/*
 * Class represents a single piece of content within your app, as well as any associated metadata.
 * It provides convenient methods for sharing, deep linking, and tracking how often that content is viewed. This information is then used to provide you with powerful content analytics
 * and deep linking.
 */
class BranchUniversalObject {
  /* Canonical identifier for the content referred. */
  final String canonicalIdentifier;

  /* Canonical url for the content referred. This would be the corresponding website URL */
  String canonicalUrl = '';

  /* Title for the content referred by BranchUniversalObject */
  String title = '';

  /* Description for the content referred */
  String contentDescription = '';

  /* An image url associated with the content referred */
  String imageUrl = '';

  /* Meta data provided for the content. {@link ContentMetadata} object holds the metadata for this content */
  BranchContentMetaData? contentMetadata;

  /* Content index mode */
  bool publiclyIndex = true;

  /* Any keyword associated with the content. Used for indexing */
  List<dynamic> keywords;

  /* Expiry date for the content and any associated links. Represented as epoch milli second */
  int expirationDateInMilliSec = 0;

  /* Index mode for  local content indexing */
  bool locallyIndex = true;
  final int _creationDateTimeStamp = DateTime.now().millisecondsSinceEpoch;

  ///Create a BranchUniversalObject with the given content.
  BranchUniversalObject(
      {required this.canonicalIdentifier,
      this.canonicalUrl = '',
      this.title = '',
      this.contentDescription = '',
      this.imageUrl = '',
      this.contentMetadata,
      this.keywords = const [],
      this.publiclyIndex = true,
      this.locallyIndex = true,
      this.expirationDateInMilliSec = 0});

  ///Adds any keywords associated with the content referred
  void addKeyWords(List<dynamic> keywords) {
    keywords.addAll(keywords);
  }

  ///Add a keyword associated with the content referred
  void addKeyWord(String keyword) {
    keywords.add(keyword);
  }

  ///Remove a keyword associated with the content referred
  void removeKeyWord(String keyword) {
    keywords.remove(keyword);
  }

  ///Get the keywords associated with this BranchUniversalObject
  List<dynamic> getKeywords() {
    return keywords;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = <String, dynamic>{};
    if (!kIsWeb) {
      if (canonicalIdentifier.isNotEmpty) {
        ret["canonicalIdentifier"] = canonicalIdentifier;
      }

      if (canonicalUrl.isNotEmpty) ret["canonicalUrl"] = canonicalUrl;

      if (title.isNotEmpty) ret["title"] = title;

      if (contentDescription.isNotEmpty) {
        ret["contentDescription"] = contentDescription;
      }

      if (imageUrl.isNotEmpty) ret["imageUrl"] = imageUrl;

      if (keywords.isNotEmpty) ret["keywords"] = keywords;

      ret["creationDate"] = _creationDateTimeStamp;

      if (expirationDateInMilliSec > 0) {
        ret["expirationDate"] = expirationDateInMilliSec;
      }

      ret["locallyIndex"] = locallyIndex;
      ret["publiclyIndex"] = publiclyIndex;

      if (contentMetadata != null && contentMetadata!.toMap().isNotEmpty) {
        ret["contentMetadata"] = contentMetadata!.toMap();
      }
    } else {
      if (canonicalIdentifier.isNotEmpty) {
        ret["\$canonical_identifier"] = canonicalIdentifier;
      }

      if (canonicalUrl.isNotEmpty) ret["\$canonicalUrl"] = canonicalUrl;

      if (title.isNotEmpty) ret["\$og_title"] = title;

      if (contentDescription.isNotEmpty) {
        ret["\$og_description"] = contentDescription;
      }

      if (imageUrl.isNotEmpty) ret["\$og_image_url"] = imageUrl;

      if (keywords.isNotEmpty) ret["\$keywords"] = keywords;

      ret["\$creation_timestamp"] = _creationDateTimeStamp;

      if (expirationDateInMilliSec > 0) {
        ret["\$exp_date"] = expirationDateInMilliSec;
      }

      ret["\$locally_indexable"] = locallyIndex;
      ret["\$publicly_indexable"] = publiclyIndex;

      Map<String, dynamic> contentMetadata = {
        if (this.contentMetadata != null) ...this.contentMetadata!.toMapWeb()
      };

      if (contentMetadata.containsKey('customMetadata')) {
        var customMetadata = contentMetadata['customMetadata'];
        contentMetadata.remove('customMetadata');
        contentMetadata.addAll(customMetadata);
        ret.addAll(contentMetadata);
      } else {
        ret.addAll(contentMetadata);
      }
    }

    if (ret.isEmpty) {
      throw ArgumentError('Branch Universal Object is required');
    }
    return ret;
  }
}
