import 'dart:convert';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_test/pact/pact_provider.dart';
import 'package:test_test/services/to_do_service.dart';
import 'dart:convert';

PactProvider pactProvider = PactProvider();

void main() async {
  setUpAll(() async {
    await pactProvider.start();
  });

  tearDownAll(() async {
    await pactProvider.verifyInteractions();
    pactProvider.shutdown();
  });
  group('ToDo service', () {
    test('should return 200 when getting todo by ID', () async {
      var requestOptions = RequestOptions(method: 'GET', path: '/123');
      var responseOptions = ResponseOptions(
          body: json.encode(ToDo("Buy guinness").toJson()),
          headers: {},
          status: 200);
      var interaction = PactInteraction(
          requestOptions: requestOptions,
          responseOptions: responseOptions,
          uponReceiving: 'A GET request to get TODO by ID');

      pactProvider.addInteraction(interaction);

      ToDoService _toDoService =
          ToDoService(baseAddress: pactProvider.baseAddress);

      await _toDoService.getToDo('123');
    });

    test('should return 400 when getting todo by ID', () async {
      var requestOptions = RequestOptions(method: 'GET', path: '/');
      var responseOptions = ResponseOptions(headers: {}, status: 400);
      var interaction = PactInteraction(
          requestOptions: requestOptions,
          responseOptions: responseOptions,
          uponReceiving: 'A GET request to get TODO with no id');

      pactProvider.addInteraction(interaction);

      ToDoService _toDoService =
          ToDoService(baseAddress: pactProvider.baseAddress);

      try {
        await _toDoService.getToDo('');
      } catch (e) {
        expect(e.message, equals('Failed to retrieve todo'));
      }
    });
  });
}
