import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:gpt4client/api/client_api.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    Box loginBox = Hive.box('login');

    serverUrlController.text = loginBox.get("url", defaultValue: "");
  }

  final TextEditingController serverUrlController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _loginRunning = false;

  void login(BuildContext context) async {
    final String serverUrl = serverUrlController.text;
    final String username = usernameController.text;
    final String password = passwordController.text;

    ClientAPI().init(serverUrl);
    try {
      setState(() {
        _loginRunning = true;
      });
      await Future.microtask(() async {
        var token = (await ClientAPI().loginUser(username, password))["token"];
        // Save the server URL and access token in Hive
        Box loginBox = Hive.box('login');
        loginBox.put('url', serverUrl);
        loginBox.put('authToken', token);
        // Navigate to the next screen or perform any other desired action
      }).then((value) {
        setState(() {
          _loginRunning = false;
          Beamer.of(context).beamToNamed("/main");
        });
      }).onError((error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString()),
        ));
        setState(() {
          _loginRunning = false;
        });
      });
    } catch (ex) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: serverUrlController,
              decoration: const InputDecoration(
                labelText: 'Server URL',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: usernameController,
              autofillHints: const [AutofillHints.username],
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              autofillHints: const [AutofillHints.password],
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _loginRunning ? null : () => login(context),
              child:
                  _loginRunning ? const CircularProgressIndicator() : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
