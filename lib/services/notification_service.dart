import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hami/main.dart';
import 'package:flutter_hami/screens/user/notification_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'hami_notification_channel', //id
    'High Importance Notification', // name
    description: 'This channel is used for important notifications', //description
    importance: Importance.max,
    playSound: true,
  );

  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize() async {

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    const IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    // initializationSettings  for Android
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: initializationSettingsIOS
    );

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? id) async {
        debugPrint("✅ onSelectNotification");
        navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => const NotificationPage()));
      },
    );
  }

  static void display(RemoteMessage message) async {
    try {
      RemoteNotification? remoteNotification = message.notification;
      AndroidNotification? androidNotification = message.notification?.android;
      if(remoteNotification != null && androidNotification != null) {
        _flutterLocalNotificationsPlugin.show(
          remoteNotification.hashCode,
          remoteNotification.title,
          remoteNotification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          // payload: message.data['_customKeyData']
        );
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

}