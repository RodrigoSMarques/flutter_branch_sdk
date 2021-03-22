library flutter_branch_sdk_objects;

part 'branch_event.dart';
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
  int _creationDateTimeStamp = DateTime.now().millisecondsSinceEpoch;

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
    this.keywords.addAll(keywords);
  }

  ///Add a keyword associated with the content referred
  void addKeyWord(String keyword) {
    this.keywords.add(keyword);
  }

  ///Remove a keyword associated with the content referred
  void removeKeyWord(String keyword) {
    this.keywords.remove(keyword);
  }

  ///Get the keywords associated with this BranchUniversalObject
  List<dynamic> getKeywords() {
    return this.keywords;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = <String, dynamic>{};
    if (this.canonicalIdentifier.isNotEmpty)
      ret["canonicalIdentifier"] = this.canonicalIdentifier;

    if (this.canonicalUrl.isNotEmpty) ret["canonicalUrl"] = this.canonicalUrl;

    if (this.title.isNotEmpty) ret["title"] = this.title;

    if (this.contentDescription.isNotEmpty)
      ret["contentDescription"] = this.contentDescription;

    if (this.imageUrl.isNotEmpty) ret["imageUrl"] = this.imageUrl;

    if (this.keywords.isNotEmpty) ret["keywords"] = this.keywords;

    ret["creationDate"] = this._creationDateTimeStamp;

    if (this.expirationDateInMilliSec > 0)
      ret["expirationDate"] = this.expirationDateInMilliSec;

    ret["locallyIndex"] = this.locallyIndex;
    ret["publiclyIndex"] = this.publiclyIndex;

    if (this.contentMetadata != null &&
        this.contentMetadata!.toMap().isNotEmpty)
      ret["contentMetadata"] = this.contentMetadata!.toMap();

    if (ret.isEmpty) {
      throw ArgumentError('Branch Universal Object is required');
    }
    return ret;
  }
}
