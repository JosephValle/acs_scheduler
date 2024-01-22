import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  final DateFormat formatter = DateFormat('hh:mm a'); // 'a' for AM/PM
  return formatter.format(dateTime);
}
