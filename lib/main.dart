import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:railway_food_delivery/delivery_form.dart';
import 'package:railway_food_delivery/firebase_options.dart';
import 'package:railway_food_delivery/splashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A notification was opened: ${message.messageId}');
    // Navigate to a specific screen if needed based on notification data
  });

  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  // Handle background message UI updates or actions here
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Set the fit size (Find your UI design, look at the dimensions of the device screen and fill it in,unit in dp)
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'First Method',
          // You can use the library anywhere in the app even in theme
          theme: ThemeData(
            timePickerTheme: TimePickerThemeData(
                dayPeriodColor: Colors.orange,
                backgroundColor: Colors.white, // Background color of the picker
                hourMinuteTextColor:
                    Colors.orange, // Color of the hour/minute text
                dialHandColor: Colors.orange, // Color of the hand that moves
                dialBackgroundColor:
                    Colors.orange.withOpacity(0.1), // Light orange background
                dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? Colors.white
                        : Colors.orange)!,
                helpTextStyle:
                    TextStyle(color: Colors.orange), // Style for the help text
                entryModeIconColor:
                    Colors.orange, // Color of the entry mode icon

                // OK and Cancel button styles
                cancelButtonStyle: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                ),
                confirmButtonStyle:
                    TextButton.styleFrom(foregroundColor: Colors.orange)),
            appBarTheme: AppBarTheme(
                backgroundColor: Colors.orange,
                centerTitle: true,
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 20.sp),
                iconTheme: IconThemeData(color: Colors.white)),
          ),
          home: child,
        );
      },
      child: Splashscreen(),
    );
  }
}
