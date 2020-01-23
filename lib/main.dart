import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:html' as html;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String clientID = "xxxx";
  String clientSecret = "xxxx";

  Map<String, String> createHeaders(String clientId, String clientSecret) {
    Map<String, String> headers = Map();
    headers.putIfAbsent(
      "Authorization",
      () =>
          "Basic " +
          Base64Codec().encode(latin1.encode(
              clientId + ':' + (clientSecret == null ? '' : clientSecret))),
    );

    return headers;
  }

  Uri currentURLuri;
  String currentURLString;

  @override
  void initState() {
    // TODO: implement initState

    currentURLuri = Uri.parse(html.window.location.href.replaceAll("#/", ""));
    currentURLString = currentURLuri.origin;

    Uri uri = Uri.dataFromString(currentURLuri.toString());
    var code = uri.queryParameters["code"];

    String refresh_token, access_token;
    int expires_in;

    if (code != null) {
      print("sendind request");
      http
          .post("http://localhost:3000/getToken",
              body: {
                "Content-Type": "application/x-www-form-urlencoded",
                "grant_type": "authorization_code",
                "redirect_uri": currentURLString,
                "code": code,
                "client_id": clientID,
                "client_secret": clientSecret
              },
              headers: createHeaders(clientID, clientSecret))
          .then((response) {
        print("response : " + response.body);
        var json = jsonDecode(response.body);
        access_token = json["access_token"];
        refresh_token = json["refresh_token"];
        expires_in = json["expires_in"];
        print("access_token : " + json["access_token"]);
      });
      return;
    }

    super.initState();
  }

  _launchURL() async {
    var url = "https://app.hubspot.com/oauth/authorize?client_id=" +
        clientID +
        "&scope=contacts%20oauth&redirect_uri=" +
        currentURLString +
        "";
    html.window.location.href = url; // or any website your want
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: RaisedButton(
        onPressed: _launchURL,
        child: Text('Show Flutter homepage'),
      ),
    ));
  }
}
