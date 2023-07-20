import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:gpt4client/api/client_api.dart';
import 'package:gpt4client/locations/login_location.dart';
import 'package:gpt4client/locations/main_location.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter("de.mabenan.gpt4client");
  var box = await Hive.openBox("login");
  var token = box.get("authToken", defaultValue: "");
  var url = box.get("url", defaultValue: "");
  if(token != "" && url != ""){
    ClientAPI().init(url);
    ClientAPI().authToken = token;
    try {
      var me = await ClientAPI().getMe();
      if(me["name"] == ""){
        ClientAPI().authToken = "";
        box.put("authToken", "");
      }
    }on Exception{
      ClientAPI().authToken = "";
      box.put("authToken", "");
    }
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final routerDelegate = BeamerDelegate(
    initialPath: '/main',
    locationBuilder: BeamerLocationBuilder(
      beamLocations: [
        MainLocation(),
        LoginLocation(),
      ],
    ),
  );
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GPT 4 All Remote Client',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
        brightness: Brightness.dark
      ),
      routerDelegate: routerDelegate,
      routeInformationParser: BeamerParser(),
    );
  }
}