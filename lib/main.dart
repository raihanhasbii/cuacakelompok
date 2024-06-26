import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import
import 'weather_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({Key? key}) : super(key: key);

  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _controller = TextEditingController();
  late Future<Map<String, dynamic>> _currentWeather;
  late Future<Map<String, dynamic>> _hourlyForecast;
  String _city = 'Buaran'; // Default city

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  void _fetchWeatherData() {
    _currentWeather = _weatherService.fetchCurrentWeather(_city);
    _hourlyForecast = _weatherService.fetchHourlyForecast(_city);
  }

  void _searchWeather() {
    setState(() {
      _city = _controller.text;
      _fetchWeatherData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('Weather App'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Enter city name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _searchWeather,
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ),
              FutureBuilder<Map<String, dynamic>>(
                future: _currentWeather,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Error loading weather data');
                  } else if (snapshot.hasData) {
                    final data = snapshot.data!;
                    final date =
                        DateFormat('yyyy-MM-dd').format(DateTime.now());
                    return Column(
                      children: [
                        Text(
                          _city,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Icon(
                          Icons.cloud,
                          size: 100,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '${data['main']['temp']}°C',
                          style: const TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${data['weather'][0]['description']} ${data['main']['temp_max']}°/${data['main']['temp_min']}°',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInfoCard(
                              'Wind',
                              '${data['wind']['speed']} m/s',
                              Icons.air,
                            ),
                            _buildInfoCard(
                              'Humidity',
                              '${data['main']['humidity']} %',
                              Icons.water_drop,
                            ),
                            _buildInfoCard(
                              'Visibility',
                              '${data['visibility'] / 1000} km',
                              Icons.visibility,
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return const Text('No data available');
                  }
                },
              ),
              const SizedBox(height: 40),
              FutureBuilder<Map<String, dynamic>>(
                future: _hourlyForecast,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Error loading weather data');
                  } else if (snapshot.hasData) {
                    final data = snapshot.data!;
                    final forecastList = (data['list'] as List)
                        .map(
                          (e) => HourlyWeatherCard(
                            time: e['dt_txt'].split(' ')[1].substring(0, 5),
                            temp: e['main']['temp'].round(),
                            icon: Icons.cloud,
                          ),
                        )
                        .toList();
                    return Container(
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Hourly Forecast',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 160,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: forecastList
                                  .map(
                                    (weather) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            weather.time,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 4),
                                          Icon(
                                            weather.icon,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${weather.temp}°C',
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Text('No data available');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HourlyWeatherCard {
  final String time;
  final int temp;
  final IconData icon;

  HourlyWeatherCard({
    required this.time,
    required this.temp,
    required this.icon,
  });
}

class WeatherService {
  // Placeholder for weather service implementation
  Future<Map<String, dynamic>> fetchCurrentWeather(String city) async {
    // Simulated delay for demonstration purposes
    await Future.delayed(const Duration(seconds: 2));
    return {
      'main': {'temp': 28, 'temp_max': 30, 'temp_min': 25, 'humidity': 70},
      'weather': [
        {'description': 'Cloudy'}
      ],
      'wind': {'speed': 5},
      'visibility': 10000, // Visibility in meters
    };
  }

  Future<Map<String, dynamic>> fetchHourlyForecast(String city) async {
    // Simulated delay for demonstration purposes
    await Future.delayed(const Duration(seconds: 2));
    return {
      'list': [
        {
          'dt_txt': '2024-06-26 12:00:00',
          'main': {'temp': 28}
        },
        {
          'dt_txt': '2024-06-26 15:00:00',
          'main': {'temp': 29}
        },
        {
          'dt_txt': '2024-06-26 18:00:00',
          'main': {'temp': 27}
        },
        {
          'dt_txt': '2024-06-26 21:00:00',
          'main': {'temp': 26}
        },
        {
          'dt_txt': '2024-06-27 00:00:00',
          'main': {'temp': 25}
        },
        {
          'dt_txt': '2024-06-27 03:00:00',
          'main': {'temp': 24}
        },
      ],
    };
  }
}
