import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info.dart';
import 'package:weather_app/notneed.dart';
import 'package:weather_app/weather_forcast_item.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String city = 'chennai';
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$city&APPID=$apiky'),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'an unexpected error occurred';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  double kelvinToCelsius(double temperatureInKelvin) {
    return temperatureInKelvin - 273.15;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather Updates',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LinearProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final currentwdata = data['list'][0];
          final currenttempKelvin = currentwdata['main']['temp'];
          final currenttempCelsius = kelvinToCelsius(currenttempKelvin);
          final currentsky = currentwdata['weather'][0]['main'];
          final currentp = currentwdata['main']['pressure'];
          final currentwspeed = currentwdata['wind']['speed'];
          final currenthumi = currentwdata['main']['humidity'];

          return Padding(
            padding: const EdgeInsets.all(17.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //main
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 11,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: Colors.grey,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10,
                          sigmaY: 10,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '${currenttempCelsius.toStringAsFixed(2)} °C',
                                style: const TextStyle(
                                    fontSize: 33, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                currentsky == 'Clouds' || currentsky == 'Rain'
                                    ? (currentsky == 'Rain'
                                        ? Icons.thunderstorm
                                        : Icons.cloud)
                                    : Icons.sunny,
                                size: 70,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentsky,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                //weather
                const Text(
                  'Hourly Forcast',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    itemCount: 5,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final hourlyf = data['list'][index + 1];
                      final time = DateTime.parse(hourlyf['dt_txt']);
                      return HourlyForcast(
                        time: DateFormat.j().format(time),
                        temp: kelvinToCelsius(hourlyf['main']['temp'])
                            .toStringAsFixed(2),
                        icon: data['list'][index + 1]['weather'][0]['main'] ==
                                    'Clouds' ||
                                data['list'][index + 1]['weather'][0]['main'] ==
                                    'Rain'
                            ? (data['list'][index + 1]['weather'][0]['main'] ==
                                    'Rain'
                                ? Icons.thunderstorm
                                : Icons.cloud)
                            : Icons.sunny,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                //additional
                const Text(
                  'Additional Info',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Additionalinfo(
                      icon: Icons.water_drop_sharp,
                      lable: 'Humidity',
                      value: currenthumi.toString(),
                    ),
                    Additionalinfo(
                      icon: Icons.air_outlined,
                      lable: 'Wind Speed',
                      value: currentwspeed.toString(),
                    ),
                    Additionalinfo(
                      icon: Icons.speed_outlined,
                      lable: 'Preassur',
                      value: currentp.toString(),
                    )
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
