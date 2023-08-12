import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  final FlutterLocalNotificationsPlugin flnp =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings ais =
      AndroidInitializationSettings('logo');

  void initializeNotifications() async {
    InitializationSettings iiss = InitializationSettings(android: ais);
    await flnp.initialize(iiss);
  }

  void sendNotification(String title, String body) async {
    AndroidNotificationDetails and = AndroidNotificationDetails(
      "channelId",
      "channelName",
      "channelDescription",
      priority: Priority.high,
      importance: Importance.max,
    );
    NotificationDetails notificationDetails = NotificationDetails(android: and);
    await flnp.show(1, title, body, notificationDetails);
  }

  void scheduleNotification(String title, String body) async {
    AndroidNotificationDetails and = AndroidNotificationDetails(
      "channelId",
      "channelName",
      "channelDescription",
      priority: Priority.high,
      importance: Importance.max,
    );
    NotificationDetails notificationDetails = NotificationDetails(android: and);
    await flnp.periodicallyShow(
      1,
      title,
      body,
      RepeatInterval.everyMinute,
      notificationDetails,
    );
  }
}
