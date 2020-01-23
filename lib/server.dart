import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future main() async {
  var server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    3000,
  );
  print('Listening on localhost:${server.port}');

  await listenForRequests(server);
}

Future listenForRequests(HttpServer requests) async {
  await for (HttpRequest request in requests) {
    print("receiving request : method " + request.method);

    print("request length: " + request.contentLength.toString());

    String content = (await utf8.decodeStream(request)).toString();
    print("request body: ");
    print(content);
    var uri = Uri(query: content);
    uri.queryParameters.forEach((k, v) {
      print('key: $k - value: $v');
    });

    String client_id = uri.queryParameters['client_id'].toString();
    String client_secret = uri.queryParameters['client_secret'].toString();
    String code = uri.queryParameters['code'].toString();
    String redirect_uri = uri.queryParameters['redirect_uri'].toString();

    http
        .post("https://api.hubapi.com/oauth/v1/token",
            body: {
              "Content-Type": "application/x-www-form-urlencoded",
              "grant_type": "authorization_code",
              "code": code,
              "client_id": client_id,
              "redirect_uri": redirect_uri,
              "client_secret": client_secret
            },
            headers: createHeaders(client_id, client_secret))
        .then((response) {
          print("response : " + response.body);
          request.response.headers.add("Access-Control-Allow-Origin", "*");
          request.response.headers.add("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
          request.response.headers.add("Access-Control-Allow-Headers", "*");
          request.response
            ..statusCode = 200
            ..write(response.body)
            ..close();
    });
  }
}


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
