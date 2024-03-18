part of 'branch_universal_object.dart';

enum BranchImageFormat {
  JPEG,
  /* QR code is returned as a JPEG */
  PNG
  /*QR code is returned as a PNG */
}

class BranchQrCode {
  /* Primary color of the generated QR code itself. */
  Color? primaryColor;
  /* Secondary color used as the QR Code background. */
  Color? backgroundColor;
  /*  The number of pixels for the QR code's border.  Min 1px. Max 20px. */
  int? margin;
  /* Output size of QR Code image. Min 300px. Max 2000px. */
  int? width;
  /* A URL of an image that will be added to the center of the QR code. Must be a PNG or JPEG. */
  String centerLogoUrl;
  /* Image Format of the returned QR code. Can be a JPEG or PNG. */
  BranchImageFormat imageFormat;

  BranchQrCode(
      {this.primaryColor,
      this.backgroundColor,
      this.margin,
      this.width,
      this.imageFormat = BranchImageFormat.PNG,
      this.centerLogoUrl = ''}) {
    if (centerLogoUrl.isNotEmpty) {
      assert(Uri.parse(centerLogoUrl).isAbsolute == true, 'Invalid URL');
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = <String, dynamic>{};

    if (!kIsWeb) {
      if (primaryColor != null) {
        ret["codeColor"] = _colorToHex(primaryColor!);
      }
      if (backgroundColor != null) {
        ret["backgroundColor"] = _colorToHex(backgroundColor!);
      }
      if (margin != null) {
        ret["margin"] = margin;
      }
      if (width != null) {
        ret["width"] = width;
      }
      ret["imageFormat"] = imageFormat.name.toUpperCase();
      if (centerLogoUrl.isNotEmpty) {
        ret["centerLogoUrl"] = centerLogoUrl;
      }
    } else {
      if (primaryColor != null) {
        ret["code_color"] = _colorToHex(primaryColor!);
      }
      if (backgroundColor != null) {
        ret["background_color"] = _colorToHex(backgroundColor!);
      }
      if (margin != null) {
        ret["margin"] = margin;
      }
      if (width != null) {
        ret["width"] = width;
      }
      ret["image_format"] = imageFormat.name.toLowerCase();
      if (centerLogoUrl.isNotEmpty) {
        ret["center_logo_url"] = centerLogoUrl;
      }
    }
    return ret;
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2, 8)}';
  }
}
