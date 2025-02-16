import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Country Details App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A192F),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1C2C45)),
        cardColor: const Color(0xFF182B43),
        iconTheme: const IconThemeData(color: Colors.white),
        textTheme: TextTheme(
          bodyLarge: const TextStyle(color: Colors.white),
          bodyMedium: const TextStyle(color: Colors.grey),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF122235),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('es', ''), // Spanish
        Locale('fr', ''), // French
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate, // Generated delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: CountryListScreen(),
    );
  }
}

class CountryListScreen extends StatefulWidget {
  @override
  _CountryListScreenState createState() => _CountryListScreenState();
}

class _CountryListScreenState extends State<CountryListScreen> {
  List countries = [];
  List filteredCountries = [];
  TextEditingController searchController = TextEditingController();
  String selectedLanguage = 'EN'; // Default language
  Set<String> selectedContinents = {}; // Selected continents for filtering
  Set<String> selectedTimezones = {}; // Selected time zones for filtering

  @override
  void initState() {
    super.initState();
    fetchCountries();
    searchController.addListener(() {
      filterCountries();
    });
  }

  Future<void> fetchCountries() async {
    final response = await http.get(Uri.parse('https://restcountries.com/v3.1/all'));
    if (response.statusCode == 200) {
      setState(() {
        countries = json.decode(response.body);
        countries.sort((a, b) => a['name']['common'].toString().compareTo(b['name']['common'].toString()));
        filteredCountries = countries;
      });
    } else {
      throw Exception('Failed to load countries');
    }
  }

  void filterCountries() {
    setState(() {
      filteredCountries = countries.where((country) {
        bool matchesSearch = country['name']['common']
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
        bool matchesContinent = selectedContinents.isEmpty || selectedContinents.contains(country['region']);
        bool matchesTimezone = selectedTimezones.isEmpty ||
            (country['timezones']?.any((timezone) => selectedTimezones.contains(timezone)) ?? false);

        return matchesSearch && matchesContinent && matchesTimezone;
      }).toList();

      filteredCountries.sort((a, b) => a['name']['common'].toString().compareTo(b['name']['common'].toString()));
    });
  }

  Map<String, List<dynamic>> groupCountriesByLetter(List<dynamic> countries) {
    final groupedCountries = <String, List<dynamic>>{};
    for (var country in countries) {
      String firstLetter = country['name']['common'][0].toUpperCase();
      if (!groupedCountries.containsKey(firstLetter)) {
        groupedCountries[firstLetter] = [];
      }
      groupedCountries[firstLetter]?.add(country);
    }
    return groupedCountries;
  }

  // Show Language Selection Modal
  void _showLanguageSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                AppLocalizations.of(context)?.translate('selectLanguage') ?? '',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._getLanguages().map((language) => ListTile(
                title: Text(language),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    selectedLanguage = language.substring(0, 2).toUpperCase();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)?.translate('selectedLanguage', {'language': language}) ?? '')),
                  );
                },
              )),
            ],
          ),
        );
      },
    );
  }

  // Show Filter Options Modal
  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                AppLocalizations.of(context)?.translate('filterOptions') ?? '',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)?.translate('filterByContinent') ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ..._getContinents().map((continent) => CheckboxListTile(
                title: Text(continent),
                value: selectedContinents.contains(continent),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      selectedContinents.add(continent);
                    } else {
                      selectedContinents.remove(continent);
                    }
                  });
                  filterCountries(); // Reapply filters
                },
              )),
              const Divider(),
              ExpansionTile(
                title: Text(AppLocalizations.of(context)?.translate('filterByTimezone') ?? ''),
                trailing: const Icon(Icons.arrow_drop_down), // Dropdown arrow
                children: [
                  ..._getTimeZones().map((timezone) => CheckboxListTile(
                    title: Text(timezone),
                    value: selectedTimezones.contains(timezone),
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          selectedTimezones.add(timezone);
                        } else {
                          selectedTimezones.remove(timezone);
                        }
                      });
                      filterCountries(); // Reapply filters
                    },
                  ))
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Apply Filters Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the modal
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Orange button
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)?.translate('applyFilters') ?? ''),
                  ),
                  // Reset Filters Button
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedContinents.clear(); // Clear all selected continents
                        selectedTimezones.clear(); // Clear all selected time zones
                      });
                      filterCountries(); // Reset filters
                      Navigator.pop(context); // Close the modal
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.red), // Red border
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.translate('resetFilters') ?? '',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Sample Continents List
  List<String> _getContinents() {
    return ['Africa', 'Americas', 'Asia', 'Europe', 'Oceania', 'Polar'];
  }

  // Sample Time Zones List
  List<String> _getTimeZones() {
    return [
      'UTC+00:00',
      'UTC+01:00',
      'UTC+02:00',
      'UTC+03:00',
      'UTC+04:00',
      'UTC+05:00',
      'UTC+06:00',
      'UTC+07:00',
      'UTC+08:00',
      'UTC+09:00',
      'UTC+10:00',
      'UTC+11:00',
      'UTC+12:00',
      'UTC-01:00',
      'UTC-02:00',
      'UTC-03:00',
      'UTC-04:00',
      'UTC-05:00',
      'UTC-06:00',
      'UTC-07:00',
      'UTC-08:00',
      'UTC-09:00',
      'UTC-10:00',
      'UTC-11:00',
    ];
  }

  // Sample Languages List
  List<String> _getLanguages() {
    return [
      'English',
      'Spanish',
      'French',
      'German',
      'Italian',
      'Japanese',
      'Korean',
      'Chinese',
      'Russian',
      'Arabic',
      'Portuguese',
      'Hindi',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('countries') ?? ''),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.nightlight_round
                  : Icons.wb_sunny,
            ),
            onPressed: () {
              setState(() {
                final currentTheme = Theme.of(context).brightness;
                if (currentTheme == Brightness.light) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Switched to Dark Mode')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Switched to Light Mode')),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)?.translate('searchHint') ?? '',
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                prefixIcon: const Icon(Icons.search),
                prefixIconColor: Theme.of(context).iconTheme.color,
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade200
                    : const Color(0xFF122235),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
          // Row for Language and Filter Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Language Button (Left Side)
                TextButton.icon(
                  onPressed: () => _showLanguageSelection(context),
                  icon: const Icon(Icons.language, color: Colors.blue),
                  label: Text(
                    selectedLanguage,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                // Filter Button (Right Side)
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.blue),
                  onPressed: () => _showFilterOptions(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredCountries.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: groupCountriesByLetter(filteredCountries).length,
              itemBuilder: (context, index) {
                final groupedCountries = groupCountriesByLetter(filteredCountries);
                final letter = groupedCountries.keys.elementAt(index);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    ...groupedCountries[letter]!.map((country) => ListTile(
                      title: Text(country['name']['common']),
                      subtitle: Text(country['region'] ?? 'Unknown region'),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          country['flags']['png'],
                          width: 50,
                          height: 30,
                          fit: BoxFit.cover,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CountryDetailScreen(country: country),
                          ),
                        );
                      },
                    )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension on AppLocalizations? {
  translate(String s, [Map<String, String>? map]) {}
}

class CountryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> country;

  const CountryDetailScreen({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    String? mapUrl = country['maps']?['openStreetMaps'];

    return Scaffold(
      appBar: AppBar(title: Text(country['name']['common'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mapUrl != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapViewScreen(mapUrl: mapUrl),
                    ),
                  );
                },
                child: const Text('View Map'),
              ),
            const SizedBox(height: 20),
            Text('Capital: ${country['capital']?[0] ?? 'N/A'}'),
            Text('Region: ${country['region']}'),
            Text('Subregion: ${country['subregion'] ?? 'N/A'}'),
            Text('Population: ${country['population']}'),
            Text(''),
            Text('Languages: ${country['languages']?.values.join(', ') ?? 'N/A'}'),
            Text('Currency: ${country['currencies']?.keys.join(', ') ?? 'N/A'}'),
            Text('Timezone: ${country['timezones']?.join(', ') ?? 'N/A'}'),
            Text('Driving Side: ${country['car']?['side'] ?? 'N/A'}'),
            Text(''),
            Text('Country Code: ${country['cca2']}'),
            Text('Independence: ${country['independent'] == true ? 'Yes' : 'No'}'),
            Text('Dialing Code: ${country['idd']?['root'] ?? ''}${country['idd']?['suffixes']?.join(', ') ?? ''}'),
            Text('Area: ${country['area']} sq km'),
            Text(''),
            Text('Motto: ${country['motto'] ?? 'N/A'}'),
            Text('GDP: ${country['gdp'] ?? 'N/A'}'),
            Text('Date Format: ${country['date_format'] ?? 'N/A'}'),
            Text('Religion: ${country['religion'] ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}

class MapViewScreen extends StatefulWidget {
  final String mapUrl;

  const MapViewScreen({super.key, required this.mapUrl});

  @override
  _MapViewScreenState createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.mapUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: WebViewWidget(controller: _controller),
    );
  }
}