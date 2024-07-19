import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:medipal/main.dart';

import 'alarm_screen.dart';

class NotificationService {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelKey: 'MedipalChannel',
            channelName: 'MedipalChannel',
            channelDescription: 'channelDescription',
            defaultColor: Colors.black,
            ledColor: Colors.white,
            importance: NotificationImportance.Max,
            onlyAlertOnce: true,
            playSound: true,
            criticalAlerts: true,
            locked: true,
            enableVibration: true,
          )
        ],
        debug: true);

    await AwesomeNotifications().isNotificationAllowed().then((value) async {
      if (!value) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    await AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onDismissActionReceivedMethod: onDismissActionReceived,
        onNotificationCreatedMethod: onNotificationCreated,
        onNotificationDisplayedMethod: onNotificationDisplayed);
  }

  static Future<void> onActionReceivedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('On Notification Received');
    final payload = receivedNotification.payload ?? {};
    var alarmId = payload['alarmId'];
    if (payload["open"] == "true") {
      if (alarmId != null) {
        navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => AlarmScreen(alarmId: alarmId)));
      }
    }
  }

  static Future<void> onDismissActionReceived(
      ReceivedNotification receivedNotification) async {
    debugPrint('On Notification dismissed');
  }

  static Future<void> onNotificationCreated(
      ReceivedNotification receivedNotification) async {
    debugPrint('On Notification created');
  }

  static Future<void> onNotificationDisplayed(
      ReceivedNotification receivedNotification) async {
    debugPrint('On Notification displayed');
  }

  static Future<void> showNotification({
    required final String title,
    required final String body,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final List<NotificationActionButton>? actionButtons,
  }) async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'MedipalChannel',
          title: title,
          body: body,
          fullScreenIntent: true,
          displayOnBackground: true,
          displayOnForeground: true,
          notificationLayout: notificationLayout,
          payload: payload,
        ),
        actionButtons: actionButtons);
  }
}
