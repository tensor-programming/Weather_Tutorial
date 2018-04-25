import 'package:json_annotation/json_annotation.dart';

part 'response.g.dart';

@JsonSerializable()
class BaseResponse extends Object with _$BaseResponseSerializerMixin {
  final String message;
  final String cod;
  final int count;

  @JsonKey(name: "list")
  final List<City> cities;

  BaseResponse(
    this.message,
    this.cod,
    this.count,
    this.cities,
  );

  factory BaseResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseResponseFromJson(json);
}

@JsonSerializable()
class City extends Object with _$CitySerializerMixin {
  final int id;
  final String name;
  final Coord coord;
  final Main main;
  final int dt;

  @JsonKey(nullable: true)
  final Wind wind;
  @JsonKey(nullable: true)
  final Rain rain;
  final Clouds clouds;
  final List<Weather> weather;

  City(
    this.id,
    this.name,
    this.coord,
    this.main,
    this.dt,
    this.wind,
    this.rain,
    this.clouds,
    this.weather,
  );
  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
}

@JsonSerializable()
class Coord extends Object with _$CoordSerializerMixin {
  final double lat;
  final double lon;
  Coord(this.lat, this.lon);

  factory Coord.fromJson(Map<String, dynamic> json) => _$CoordFromJson(json);
}

@JsonSerializable()
class Main extends Object with _$MainSerializerMixin {
  final double temp;
  final double pressure;
  final int humidity;

  @JsonKey(name: "temp_max")
  final double tempMax;
  @JsonKey(name: "temp_min")
  final double tempMin;

  Main(
    this.temp,
    this.pressure,
    this.humidity,
    this.tempMax,
    this.tempMin,
  );

  factory Main.fromJson(Map<String, dynamic> json) => _$MainFromJson(json);
}

@JsonSerializable()
class Wind extends Object with _$WindSerializerMixin {
  final double speed;
  final double deg;

  @JsonKey(nullable: true)
  final double gust;

  Wind(
    this.speed,
    this.deg,
    this.gust,
  );
  factory Wind.fromJson(Map<String, dynamic> json) => _$WindFromJson(json);
}

@JsonSerializable()
class Rain extends Object with _$RainSerializerMixin {
  @JsonKey(name: "3h")
  final double threeHour;
  Rain(this.threeHour);

  factory Rain.fromJson(Map<String, dynamic> json) => _$RainFromJson(json);
}

@JsonSerializable()
class Clouds extends Object with _$CloudsSerializerMixin {
  Clouds({this.all});
  final int all;

  factory Clouds.fromJson(Map<String, dynamic> json) => _$CloudsFromJson(json);
}

@JsonSerializable()
class Weather extends Object with _$WeatherSerializerMixin {
  Weather({
    this.id,
    this.main,
    this.description,
    this.icon,
  });
  final int id;
  final String main;
  final String description;
  final String icon;

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);
}
