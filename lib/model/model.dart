import 'package:weather/json/response.dart';

class WeatherModel {
  final String city;
  final double temperature;
  final String description;
  final double rain;
  final double lat;
  final double long;

  WeatherModel({
    this.city,
    this.temperature,
    this.description,
    this.rain,
    this.lat,
    this.long,
  });

  WeatherModel.fromResponse(City response)
      : city = response.name,
        temperature = response.main.temp,
        description = response.weather[0].description,
        rain = response.rain.threeHour,
        lat = response.coord.lat,
        long = response.coord.long;
}
