// main.dart
// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  print("Initialise firebase");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print("Firebase initialised");

  // Initialize notifications
  print("Initialise notification service");
  final notificationService = NotificationService();
  await notificationService.initialize();
  print("Notification service initialised");

  runApp(MyApp(notificationService: notificationService));
}
