part of flutter_branch_sdk_objects;
/*
* Class for representing any additional information that is specific to the link.
* Use this class to specify the properties of a deep link such as channel, feature etc and any control params associated with the link.
*
*/

class BranchLinkProperties {
  List<String> tags = const [];
  final String feature;
  final String alias;
  final String stage;
  final int matchDuration;
  Map<String, dynamic> _controlParams = {};
  final String channel;
  final String campaign;

  BranchLinkProperties(
      {this.channel = '',
      this.feature = '',
      this.alias = '',
      this.matchDuration = 0,
      this.stage = '',
      this.tags = const [],
      this.campaign = ''});

  void addTags(String tag) {
    tags.add(tag);
  }

  List<String> getTags() {
    return this.tags;
  }

  Map<String, dynamic> getControlParams() {
    return this._controlParams;
  }

  BranchLinkProperties addControlParam(String key, dynamic value) {
    this._controlParams[key] = value;
    return this;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = <String, dynamic>{};

    if (tags.length > 0) ret['tags'] = tags;

    if (feature.isNotEmpty) ret['feature'] = feature;

    if (alias.isNotEmpty) ret['alias'] = alias;

    if (stage.isNotEmpty) ret['stage'] = stage;

    if (matchDuration > 0) ret['matchDuration'] = matchDuration;

    if (_controlParams.isNotEmpty) ret['controlParams'] = _controlParams;

    if (channel.isNotEmpty) ret['channel'] = channel;

    if (campaign.isNotEmpty) ret['campaign'] = campaign;

    if (ret.isEmpty) {
      throw ArgumentError('Link Properties is required');
    }

    return ret;
  }
}
