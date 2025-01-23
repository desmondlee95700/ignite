import 'package:intl/intl.dart';

String convertDateFormat(String inputDate) {
  // Parse the input date string into a DateTime object
  DateTime dateTime = DateTime.parse(inputDate);
  
  // Format the DateTime object into the desired format
  return DateFormat('dd MMMM yyyy').format(dateTime);
}

String getDay(String date) {
  final parts = date.split('-');
  if (parts.length != 3) return '';
  return parts[2]; // Return the day part
}

String getMonthShort(String date) {
  const List<String> shortMonths = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  final parts = date.split('-');
  if (parts.length != 3) return '';
  
  final monthIndex = int.tryParse(parts[1]) ?? 0;
  if (monthIndex < 1 || monthIndex > 12) return '';
  
  return shortMonths[monthIndex - 1]; // Return the short month name
}
