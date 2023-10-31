import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

class LocationService {
  final String key = "AIzaSyBCaVSu8OIPyyC28ETDN9pvG9URoq_QROk";

  Future<String> getPlaceId(String input) async {
    try {
      final String url =
          "https://places.googleapis.com/v1/place/textsearch/json?query=${input}&key=$key";
      var response = await http.get(Uri.parse(url));
      var json = convert.jsonDecode(response.body);
      var placeId = json['candidates'][0]['place_id'] as String;
      print(placeId);
      return placeId;
    } catch (ex) {
      print(ex);
    }
    return "";
  }

  //Future<Map<String,dynamic>> getPlace(string input)async{}
}
