import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

import '../models/location.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<StatefulWidget> createState() {
    return LocationState();
  }
}

class LocationState extends State<Location> {
  late Future<dynamic>? _futureData;
  final _cepController = TextEditingController();
  bool _buttonDisabled = true;

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _futureData = _getCep();
    _cepController.addListener(() {
      setState(() {
        _buttonDisabled = _cepController.text.length < 8;
      });
      if (_cepController.text.length < 8) {
        setState(() {
          _futureData = null;
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    } catch (e) {
      print('Erro ao obter a localização: $e');
    }
  }

  Future<void> launchGoogleMaps(String query) async {
    await _getCurrentLocation();
    final Uri googleMapsUrl =
      Uri.parse("https://google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}");

    try {
      await launchUrl(googleMapsUrl, mode: LaunchMode.inAppWebView);
    } catch (e) {
      throw 'Não foi possível abrir o Google Maps $e';
    }
  }

  Future<dynamic> _getCep() async {
    final String cep = _cepController.text;

    if (cep.isNotEmpty) {
      final Uri url = Uri.parse("https://viacep.com.br/ws/$cep/json/");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return LocationModel.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load location');
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              TextField(
                controller: _cepController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Pesquise um CEP',
                ),
                keyboardType: TextInputType.number,
                maxLength: 8,
              ),
              ElevatedButton(
                onPressed: _buttonDisabled
                    ? null
                    : () async {
                        if (_cepController.text.isNotEmpty) {
                          setState(() {
                            _futureData = _getCep();
                          });
                        }
                      },
                child: const Text("Buscar"),
              ),
              if (!_buttonDisabled)
                FutureBuilder(
                    future: _futureData,
                    builder: ((context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                            padding: EdgeInsets.only(top: 30),
                            child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Padding(
                            padding: EdgeInsets.only(top: 30),
                            child: Text(
                              "Erro",
                            ));
                      }

                      if (snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: Column(
                                children: [
                                  ListView(
                                    itemExtent: 25,
                                    shrinkWrap: true,
                                    children: [
                                      ListTile(
                                        title: Text(
                                          "CEP: ${snapshot.data!.cep}",
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                            "Rua: ${snapshot.data!.logradouro}"),
                                      ),
                                      ListTile(
                                        title: Text(
                                            "Complemento: ${snapshot.data!.complemento}"),
                                      ),
                                      ListTile(
                                        title: Text(
                                            "Bairro: ${snapshot.data!.bairro}"),
                                      ),
                                      ListTile(
                                        title: Text(
                                            "Localidade: ${snapshot.data!.localidade}"),
                                      ),
                                      ListTile(
                                        title: Text(
                                            "Estado: ${snapshot.data!.uf}"),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: ElevatedButton(
                                        onPressed: () async {
                                          await launchGoogleMaps(
                                              snapshot.data!.logradouro);
                                        },
                                        child: const Text('Abrir no maps')),
                                  )
                                ],
                              )),
                        );
                      }

                      return Container();
                    }))
            ],
          )),
    ));
  }
}
