import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as client;
import 'dart:convert' as convert;

class ToDo {
  final String task;

  ToDo(this.task);

  ToDo.fromJson(Map<String, dynamic> json) : task = json['task'];

  Map<String, dynamic> toJson() {
    return {
      'task': task,
    };
  }
}

class ToDoService {
  final String baseAddress;

  ToDoService({@required this.baseAddress});

  Future<ToDo> getToDo(String id) async {
    var response =
        await client.get('$baseAddress/$id', headers: Map.from({}));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      return ToDo.fromJson(jsonResponse);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw new Exception("Failed to retrieve todo");
    }
  }
}
