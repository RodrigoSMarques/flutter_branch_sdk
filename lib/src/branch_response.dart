part of flutter_branch_sdk;

class BranchResponse {
  bool success;
  String result;
  String errorCode;
  String errorDescription;

  BranchResponse.success({@required this.result}) {
    this.success = true;
  }
  BranchResponse.error(
      {@required this.errorCode, @required this.errorDescription}) {
    this.success = false;
  }
}
