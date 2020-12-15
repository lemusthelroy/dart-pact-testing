import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_web_server/mock_web_server.dart';

class RequestOptions {
  final Object body;
  final String method;
  final String query;
  final Map<String, String> headers;
  final String path;

  RequestOptions(
      {this.body,
      @required this.method,
      this.query,
      this.headers,
      @required this.path});
}

class ResponseOptions {
  final int status;
  final Map<String, String> headers;
  final Object body;

  ResponseOptions({@required this.status, @required this.headers, this.body});
}

class PactInteraction {
  final String state;
  final String uponReceiving;
  final RequestOptions requestOptions;
  final ResponseOptions responseOptions;

  PactInteraction(
      {this.state,
      @required this.uponReceiving,
      @required this.requestOptions,
      @required this.responseOptions});
}

class PactProvider {
  MockWebServer _server;
  List<PactInteraction> interactions = new List<PactInteraction>();

  Future<void> start() async {
    _server = MockWebServer();
    await _server.start();
    print(interactions.length.toString() + " interaction(s) registered");
  }

  void shutdown() {
    _server.shutdown();
  }

  String get baseAddress => _server.url.substring(0, _server.url.length - 1);

  Future<void> addInteraction(PactInteraction interaction) async {
    interactions.add(interaction);
    await enqueueMockResponse(
        headers: interaction.responseOptions.headers,
        httpCode: interaction.responseOptions.status,
        body: interaction.responseOptions.body);
  }

  Future<void> verifyInteractions() async {
    interactions.forEach((interaction) async {
      final StoredRequest storedRequest = _server.takeRequest();
      expectRequestSentTo(interaction.requestOptions.path, storedRequest);
      if (interaction.requestOptions.headers != null) {
        interaction.requestOptions.headers.forEach((key, value) {
          expectRequestContainsHeader(
              key: key, expectedValue: value, storedRequest: storedRequest);
        });
      }
      if (interaction.requestOptions.body != null) {
        await expectRequestContainsBody(
            interaction.requestOptions.body, storedRequest);
      }

      print("TODO - Append interaction to be written to contract");
    });

    print(
        "TODO - Write all interactions to contract and create .json file based on consumer and provider name");
  }

  Future<void> enqueueMockResponse(
      {int httpCode = 200,
      @required Map<String, String> headers,
      Object body}) async {
    _server.enqueue(httpCode: httpCode, body: body);
  }

  void expectRequestSentTo(String endpoint, StoredRequest storedRequest) {
    expect(storedRequest.uri.path, endpoint);
  }

  void expectRequestContainsHeader(
      {@required String key,
      @required String expectedValue,
      @required StoredRequest storedRequest,
      int requestIndex = 0}) {
    final value = storedRequest.headers[key];
    expect(value, contains(expectedValue));
  }

  Future<void> expectRequestContainsBody(
      String expectedRequestBody, StoredRequest storedRequest) async {
    expect(storedRequest.body, expectedRequestBody);
  }
}
