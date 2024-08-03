import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:water_intake/model/water_model.dart';
import 'package:http/http.dart' as http;

class WaterData extends ChangeNotifier {
  List<WaterModel> waterDataList = [];

  void addWater(WaterModel water) async {
    final url = Uri.https(
        'water-intaker-3633a-default-rtdb.europe-west1.firebasedatabase.app',
        'water.json');

    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': double.parse(water.amount.toString()),
          'unit': 'ml',
          'dateTime': DateTime.now().toString()
        }));

    if (response.statusCode == 200) {
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      waterDataList.add(WaterModel(
          id: extractedData['name'],
          amount: water.amount,
          dateTime: water.dateTime,
          unit: 'ml'));
    } else {
      print('Error: ${response.statusCode}');
    }

    notifyListeners();
  }

  Future<List<WaterModel>> getWater() async {
    final url = Uri.https(
        'water-intaker-3633a-default-rtdb.europe-west1.firebasedatabase.app',
        'water.json');

    final response = await http.get(url);

    if (response.statusCode == 200 && response.body != 'null') {
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      for (var element in extractedData.entries) {
        waterDataList.add(WaterModel(
            id: element.key,
            amount: element.value['amount'],
            dateTime: DateTime.parse(element.value['dateTime']),
            unit: element.value['unit']));
      }
    }

    notifyListeners();
    return waterDataList;
  }
}
