part of flutter_branch_sdk;
/*
* Class for representing any additional information that is specific to the link.
* Use this class to specify the properties of a deep link such as channel, feature etc and any control params associated with the link.
*
*/

class BranchLinkProperties {
  List<String> tags = List<String>();
  String feature = 'Share';
  String alias = '';
  String stage = '';
  int matchDuration = 0;
  Map<String, dynamic> _controlParams = {};
  String channel = '';
  String campaign = '';

  BranchLinkProperties(
      {this.channel, this.feature, this.alias, this.matchDuration, this.stage, this.tags});

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

    if (tags != null && tags.length > 0) ret['tags'] = tags;

    if (feature != null && feature.isNotEmpty) ret['feature'] = feature;

    if (alias != null && alias.isNotEmpty) ret['alias'] = alias;

    if (stage != null && stage.isNotEmpty) ret['stage'] = stage;

    if (matchDuration != null && matchDuration > 0)
      ret['matchDuration'] = matchDuration;

    if (_controlParams != null && _controlParams.isNotEmpty)
      ret['controlParams'] = _controlParams;

    if (channel != null && channel.isNotEmpty) ret['channel'] = channel;

    if (campaign != null && campaign.isNotEmpty) ret['campaign'] = campaign;

    if (ret.isEmpty) {
      throw ArgumentError('Link Properties is required');
    }

    return ret;
  }
}
