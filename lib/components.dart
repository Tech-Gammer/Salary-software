
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextStyles {
  static TextStyle customTextStyle = TextStyle(
      fontFamily: 'Times New Roman',
      fontSize: 30,
      color: Colors.blue,
    fontWeight: FontWeight.bold
  );
}
class CnicFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Remove all non-numeric characters from the input
    final numericValue = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit the input to 13 digits
    final limitedValue = numericValue.substring(0, numericValue.length > 13 ? 13 : numericValue.length);

    // Insert dashes in the correct positions
    String formattedValue = '';
    if (limitedValue.length > 5) {
      formattedValue = '${limitedValue.substring(0, 5)}-${limitedValue.substring(5)}';
    } else {
      formattedValue = limitedValue;
    }
    if (formattedValue.length > 13) {
      formattedValue = '${formattedValue.substring(0, 13)}-${formattedValue.substring(13)}';
    }

    // Return the formatted value
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
