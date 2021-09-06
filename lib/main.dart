import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel=AndroidNotificationChannel(
'high importance channel', //id
'High importance notifications', // title
 'this channel is used for description',
  importance: Importance.high,
  playSound: true// description
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin=FlutterLocalNotificationsPlugin();
Future<void> _fireBaseMessagingBackgroundHandler(RemoteMessage message)async{
  await Firebase.initializeApp();
  print('A big message just showed up:${message.messageId}');
}
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_fireBaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState(){
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification=message.notification;
      AndroidNotification? android = message.notification?.android;
      if(notification!=null && android!=null){
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            )
          )
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
print('A new onMessageOpenedApp event was publicshed');
RemoteNotification? notification=message.notification;
AndroidNotification? android=message.notification?.android;
if(notification !=null && android!=null){
  showDialog(context: context,
      builder: (_){
    return AlertDialog(
      title: Text(notification.title.toString()),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text(notification.body.toString()),
          ],
        ),
      ),
    );
      });
}
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Push notticifation example'),centerTitle: true,),
      body: Center(
        child: Text('Message will coming soon'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showNotification();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void showNotification() {
flutterLocalNotificationsPlugin.show(
  0,
  "Testing counter",
  "How you doing?",
  NotificationDetails(
    android: AndroidNotificationDetails(
      channel.id,
      channel.name,
      channel.description,
      importance: Importance.high,
      color: Colors.blue,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    )
  ),
);
  }
}

