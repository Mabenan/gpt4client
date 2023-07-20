import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:gpt4client/screen/login_screen.dart';

class LoginLocation extends BeamLocation<BeamState>{

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(child: const LoginScreen(), title:"Login", key : ValueKey('Login-${DateTime.now()}'))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/login'];
}