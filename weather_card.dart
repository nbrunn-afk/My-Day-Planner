import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  late Future<Map<String, dynamic>> _futureWeather;

  @override
  void initState() {
    super.initState();
    _futureWeather = _fetchWeather();
  }

  Future<Map<String, dynamic>> _fetchWeather() async {
    try {
      // Simple free weather API (Open-Meteo) with hard-coded coordinates.
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=46.78&longitude=-92.10&current_weather=true',
      );
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Weather request failed: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final current = data['current_weather'] as Map<String, dynamic>?;

      if (current == null) {
        throw Exception('No current weather data found');
      }

      return {
        'temperature': current['temperature'],
        'windspeed': current['windspeed'],
      };
    } catch (e) {
      // Bubble up a readable error message
      throw Exception('Could not load weather data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.wb_sunny_outlined, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _futureWeather,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading weather...');
                  } else if (snapshot.hasError) {
                    return Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    );
                  } else if (!snapshot.hasData) {
                    return const Text('No weather data.');
                  }

                  final weather = snapshot.data!;
                  final temp = weather['temperature'];
                  final wind = weather['windspeed'];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Weather (Duluth, MN)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Temperature: $temp°C'),
                      Text('Wind speed: $wind km/h'),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
