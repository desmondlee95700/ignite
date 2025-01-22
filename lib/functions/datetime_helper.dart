import 'package:intl/intl.dart';

String convertDateFormat(String inputDate) {
  // Parse the input date string into a DateTime object
  DateTime dateTime = DateTime.parse(inputDate);
  
  // Format the DateTime object into the desired format
  return DateFormat('dd MMMM yyyy').format(dateTime);
}
