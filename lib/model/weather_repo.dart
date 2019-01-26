import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:geolocator/geolocator.dart';
import 'package:weather/json/response.dart';

import 'package:weather/model/model.dart';
import 'package:weather/const.dart';

class WeatherRepo {
  final http.Client client;

  WeatherRepo({this.client});

  int cnt = 50;
  String lang = "en";

  void addCities(int count) {
    cnt = count;
  }

  void setLanguage(String code) {
    lang = code;
  }

  Future<List<WeatherModel>> updateWeather(Position result) async {
    String url;
    if (result != null) {
      url =
          'http://api.openweathermap.org/data/2.5/find?lat=${result.latitude}&lon=${result.longitude}&cnt=$cnt&appid=$API_KEY&lang=$lang';
    } else {
      url =
          'http://api.openweathermap.org/data/2.5/find?lat=43&lon=-79&cnt=10&appid=$API_KEY';
    }

    final response = await client.get(url);

    List<WeatherModel> req = BaseResponse.fromJson(
            json.decode(response.body) as Map<String, dynamic>)
        .cities
        .map((city) => WeatherModel.fromResponse(city))
        .toList();

    return req;
  }

  Future<Position> updateLocation(dynamic item) {
    Future<Position> location = Geolocator().getCurrentPosition();
    return location;
  }

  Future<bool> getGps() async {
    final GeolocationStatus result =
        await Geolocator().checkGeolocationPermissionStatus();
    if (result == GeolocationStatus.granted)
      return true;
    else
      return false;
  }
}
