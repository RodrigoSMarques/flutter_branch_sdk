part of 'branch_universal_object.dart';

class BranchResponse<T> {
  bool success = true;
  T? result;
  String errorCode = '';
  String errorMessage = '';

  BranchResponse.success({required this.result}) {
    success = true;
  }
  BranchResponse.error({required this.errorCode, required this.errorMessage}) {
    success = false;
  }

  @override
  String toString() {
    return ('success: $success, errorCode: $errorCode, errorMessage: $errorMessage}');
  }
}
