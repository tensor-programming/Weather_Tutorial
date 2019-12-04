import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:weather/model/weather_repo.dart';
import 'package:weather/model/model_command.dart';
import 'package:weather/model/model.dart';
import 'package:weather/model/model_provider.dart';

import 'package:weather/localization/localizations.dart';

import 'package:rx_widgets/rx_widgets.dart';

import 'package:http/http.dart' as http;

void main() {
  final repo = WeatherRepo(client: http.Client());
  final modelCommand = ModelCommand(repo);
  runApp(
    ModelProvider(
      child: MyApp(),
      modelCommand: modelCommand,
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ""),
        Locale("es", ""),
        Locale('ja', ''),
      ],
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).title,
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Locale myLocale = Localizations.localeOf(context);
    ModelCommand command = ModelProvider.of(context);

    //call to getGpsCommand handler on build.  If GPS is active comes back with true, else false.
    command.changeLocaleCommand.call(myLocale.languageCode.toString());
    command.getGpsCommand.call();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).title.toString(),
          style: TextStyle(
            fontSize: myLocale.languageCode.contains("es") ||
                    myLocale.languageCode.contains("ja")
                ? 15.0
                : 20.0,
          ),
        ),
        actions: <Widget>[
          Container(
            child: Center(
              child: RxLoader<bool>(
                radius: 20.0,
                commandResults: command.getGpsCommand.results,
                dataBuilder: (context, data) => Row(
                  children: <Widget>[
                    Text(data ? "GPS is Active" : "GPS is Inactive"),
                    // Added logic to change the Icon when GPS is inactive.
                    IconButton(
                      icon: Icon(data ? Icons.gps_fixed : Icons.gps_not_fixed),
                      onPressed: command.getGpsCommand,
                    ),
                  ],
                ),
                placeHolderBuilder: (context) => Text("Push the Button"),
                errorBuilder: (context, exception) => Text("$exception"),
              ),
            ),
          ),
          PopupMenuButton<int>(
            padding: EdgeInsets.all(1.0),
            tooltip: "Select how many cities you want",
            onSelected: (int item) {
              ModelProvider.of(context).addCitiesCommand(item);
            },
            itemBuilder: (context) {
              return menuNumbers
                  .map((number) => PopupMenuItem(
                        value: number,
                        child: Center(
                          child: Text("$number Cities"),
                        ),
                      ))
                  .toList();
            },
          )
        ],
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Expanded(
            child: RxLoader<List<WeatherModel>>(
              radius: 30.0,
              commandResults: command.updateWeatherCommand.results,
              dataBuilder: (context, data) => WeatherList(data),
              placeHolderBuilder: (context) => Center(child: Text("No Data")),
              errorBuilder: (context, exception) =>
                  Center(child: Text("$exception")),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                //changed to expanded for more consistency.
                Expanded(
                  child: WidgetSelector(
                    buildEvents: command.updateWeatherCommand.canExecute,
                    onTrue: MaterialButton(
                      elevation: 5.0,
                      color: Colors.blueGrey,
                      child: Text(AppLocalizations.of(context).button),
                      onPressed: command.updateLocationCommand.call,
                    ),
                    onFalse: MaterialButton(
                      elevation: 0.0,
                      color: Colors.blueGrey,
                      onPressed: null,
                      child: Text("Loading Data....."),
                    ),
                  ),
                ),
                //changed to expanded for more consistency.
                Expanded(
                  child: Column(
                    children: <Widget>[
                      SliderItem(
                        sliderState: true,
                        command: command.radioCheckedCommand,
                      ),
                      Container(
                        padding: EdgeInsets.all(10.0),
                        child: Text("Turn off Data"),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class WeatherList extends StatelessWidget {
  final List<WeatherModel> list;
  WeatherList(this.list);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) => ListTile(
        leading: Image.network("http://openweathermap.org/img/w/" +
            list[index].icon.toString() +
            '.png'),
        title: Container(
          padding: EdgeInsets.all(10.0),
          child: Text(list[index].city.toString()),
        ),
        subtitle: Container(
          padding: EdgeInsets.all(10.0),
          child: Text(list[index].temperature.toStringAsFixed(2)),
        ),
        trailing: Container(
          child: Column(
            children: <Widget>[
              Text(list[index].description),
              Container(
                padding: EdgeInsets.only(top: 5.0),
                child: Text(
                  'Latitude: ${list[index].lat}',
                  style: TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic),
                ),
              ),
              Container(
                  child: Text(
                'Longitude: ${list[index].long}',
                style: TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic),
              ))
            ],
          ),
        ),
      ),
    );
  }
}

class SliderItem extends StatefulWidget {
  final bool sliderState;
  final ValueChanged<bool> command;

  SliderItem({this.sliderState, this.command});

  @override
  SliderState createState() => SliderState(sliderState, command);
}

class SliderState extends State<SliderItem> {
  bool sliderState;
  ValueChanged<bool> command;

  SliderState(this.sliderState, this.command);

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: sliderState,
      onChanged: (item) {
        setState(() => sliderState = item);
        command(item);
      },
    );
  }
}

final List<int> menuNumbers = <int>[5, 10, 15, 20, 25, 30, 35, 40, 45, 50];
