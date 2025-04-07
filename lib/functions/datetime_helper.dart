import 'package:cloud_firestore/cloud_firestore.dart';
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

int getYearFromDateString(String dateString) {
  try {
    DateTime date = DateTime.parse(dateString);
    return date.year;
  } catch (e) {
    throw FormatException("Invalid date format: $dateString");
  }
}

String getTimeFromTimestamp(Timestamp timestamp) {
  final dateTime = timestamp.toDate().toLocal(); // Convert to local time (MYT)

  // Check if the time is exactly 12:00 AM
  if (dateTime.hour == 0 && dateTime.minute == 0) {
    return 'To be announced';
  }

  return DateFormat('h:mm a').format(dateTime);  // Example: "7:30 PM"
}

String getTimeFromDateTime(DateTime dateTime) {
  // Ensure the time is in local time (MYT)
  final localDateTime = dateTime.toLocal();

  // Check if the time is exactly 12:00 AM
  if (localDateTime.hour == 0 && localDateTime.minute == 0) {
    return 'To be announced';
  }

  // Format the time to "h:mm a" (e.g., "7:30 PM")
  return DateFormat('h:mm a').format(localDateTime);
}