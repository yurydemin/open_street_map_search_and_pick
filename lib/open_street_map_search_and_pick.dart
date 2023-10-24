// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:open_street_map_search_and_pick/widgets/wide_button.dart';

class OpenStreetMapSearchAndPick extends StatefulWidget {
  final LatLong center;
  final void Function(PickedData pickedData) onPicked;
  final Future<LatLng> Function() onGetCurrentLocationPressed;
  final IconData zoomInIcon;
  final IconData zoomOutIcon;
  final IconData currentLocationIcon;
  final IconData locationPinIcon;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color locationPinIconColor;
  final String locationPinText;
  final TextStyle locationPinTextStyle;
  final String buttonText;
  final String hintText;
  final double buttonHeight;
  final double buttonWidth;
  final TextStyle buttonTextStyle;
  final String searchBaseUri;
  final String mapsTemplateUrl;
  final List<String> mapsTemplateSubdomains;
  // final String country;
  // final String city;
  final int responseResultsMaxCount;
  final String baseRegionCode;
  final String daDataToken;

  static Future<LatLng> nopFunction() {
    throw Exception("");
  }

  const OpenStreetMapSearchAndPick(
      {Key? key,
      this.center = const LatLong(0, 0),
      required this.onPicked,
      required this.daDataToken,
      this.zoomOutIcon = Icons.zoom_out_map,
      this.zoomInIcon = Icons.zoom_in_map,
      this.currentLocationIcon = Icons.my_location,
      this.onGetCurrentLocationPressed = nopFunction,
      this.buttonColor = Colors.blue,
      this.locationPinIconColor = Colors.blue,
      this.locationPinText = 'Location',
      this.locationPinTextStyle = const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
      this.hintText = 'Search Location',
      this.buttonTextStyle = const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      this.buttonTextColor = Colors.white,
      this.buttonText = 'Set Current Location',
      this.buttonHeight = 50,
      this.buttonWidth = 200,
      this.searchBaseUri = 'https://nominatim.openstreetmap.org',
      this.mapsTemplateUrl =
          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      this.mapsTemplateSubdomains = const ['a', 'b', 'c'],
      this.responseResultsMaxCount = 5,
      this.baseRegionCode = '66',
      // this.country = '',
      // this.city = '',
      this.locationPinIcon = Icons.location_on})
      : super(key: key);

  @override
  State<OpenStreetMapSearchAndPick> createState() =>
      _OpenStreetMapSearchAndPickState();
}

class _OpenStreetMapSearchAndPickState
    extends State<OpenStreetMapSearchAndPick> {
  MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  //List<OSMdata> _options = <OSMdata>[];
  List<DadataSuggestion> _suggestions = <DadataSuggestion>[];
  DadataSuggestion? _selectedSuggestion;
  Timer? _debounce;
  var client = http.Client();
  // late String country;
  // late String city;

  // void updateCountryAndCityOnResponse(Map<dynamic, dynamic> decodedResponse) {
  //   country = decodedResponse['address']['country'] ?? widget.country;
  //   city = decodedResponse['address']['city'] ?? widget.city;

  //   if (kDebugMode) {
  //     print('OnInitUpdate: country: $country | city: $city');
  //   }
  // }

  // void setNameCurrentPos() async {
  //   double latitude = _mapController.center.latitude;
  //   double longitude = _mapController.center.longitude;
  //   if (kDebugMode) {
  //     print(latitude);
  //   }
  //   if (kDebugMode) {
  //     print(longitude);
  //   }
  //   String url =
  //       '${widget.searchBaseUri}/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1';

  //   var response = await client.get(Uri.parse(url));
  //   // var response = await client.post(Uri.parse(url));
  //   var decodedResponse =
  //       jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;

  //   updateCountryAndCityOnResponse(decodedResponse);

  //   _searchController.text =
  //       decodedResponse['display_name'] ?? "MOVE TO CURRENT POSITION";
  //   setState(() {});
  // }

  // void setNameCurrentPosAtInit() async {
  //   double latitude = widget.center.latitude;
  //   double longitude = widget.center.longitude;
  //   if (kDebugMode) {
  //     print(latitude);
  //   }
  //   if (kDebugMode) {
  //     print(longitude);
  //   }

  //   String url =
  //       '${widget.searchBaseUri}/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1';

  //   var response = await client.get(Uri.parse(url));
  //   // var response = await client.post(Uri.parse(url));
  //   var decodedResponse =
  //       jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;

  //   updateCountryAndCityOnResponse(decodedResponse);

  //   // _searchController.text =
  //   //     decodedResponse['display_name'] ?? "MOVE TO CURRENT POSITION";
  //   // setState(() {});
  // }

  @override
  void initState() {
    _mapController = MapController();

    // setNameCurrentPosAtInit();

    // _mapController.mapEventStream.listen((event) async {
    //   if (event is MapEventMoveEnd) {
    //     var client = http.Client();
    //     String url =
    //         '${widget.searchBaseUri}/reverse?format=json&lat=${event.center.latitude}&lon=${event.center.longitude}&zoom=18&addressdetails=1';

    //     var response = await client.get(Uri.parse(url));
    //     // var response = await client.post(Uri.parse(url));
    //     var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes))
    //         as Map<dynamic, dynamic>;

    //     updateCountryAndCityOnResponse(decodedResponse);

    //     _searchController.text = decodedResponse['display_name'];
    //     setState(() {});
    //   }
    // });

    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // String? _autocompleteSelection;
    OutlineInputBorder inputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: widget.buttonColor),
    );
    OutlineInputBorder inputFocusBorder = OutlineInputBorder(
      borderSide: BorderSide(color: widget.buttonColor, width: 3.0),
    );
    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
              child: FlutterMap(
            options: MapOptions(
              center: LatLng(widget.center.latitude, widget.center.longitude),
              zoom: 15.0,
              maxZoom: 18,
              minZoom: 10,
            ),
            mapController: _mapController,
            children: [
              TileLayer(
                urlTemplate: widget.mapsTemplateUrl,
                subdomains: widget.mapsTemplateSubdomains,
              ),
            ],
          )),
          Positioned.fill(
              child: IgnorePointer(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.locationPinText,
                      style: widget.locationPinTextStyle,
                      textAlign: TextAlign.center),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Icon(
                      widget.locationPinIcon,
                      size: 50,
                      color: widget.locationPinIconColor,
                    ),
                  ),
                ],
              ),
            ),
          )),
          Positioned(
              bottom: 180,
              right: 5,
              child: FloatingActionButton(
                heroTag: 'btn1',
                backgroundColor: widget.buttonColor,
                onPressed: () {
                  _mapController.move(
                      _mapController.center, _mapController.zoom + 1);
                },
                child: Icon(
                  widget.zoomInIcon,
                  color: widget.buttonTextColor,
                ),
              )),
          Positioned(
              bottom: 120,
              right: 5,
              child: FloatingActionButton(
                heroTag: 'btn2',
                backgroundColor: widget.buttonColor,
                onPressed: () {
                  _mapController.move(
                      _mapController.center, _mapController.zoom - 1);
                },
                child: Icon(
                  widget.zoomOutIcon,
                  color: widget.buttonTextColor,
                ),
              )),
          // Positioned(
          //     bottom: 60,
          //     right: 5,
          //     child: FloatingActionButton(
          //       heroTag: 'btn3',
          //       backgroundColor: widget.buttonColor,
          //       onPressed: () async {
          //         try {
          //           LatLng position =
          //               await widget.onGetCurrentLocationPressed.call();
          //           _mapController.move(
          //               LatLng(position.latitude, position.longitude),
          //               _mapController.zoom);
          //         } catch (e) {
          //           _mapController.move(
          //               LatLng(widget.center.latitude, widget.center.longitude),
          //               _mapController.zoom);
          //         } finally {
          //           setNameCurrentPos();
          //         }
          //       },
          //       child: Icon(
          //         widget.currentLocationIcon,
          //         color: widget.buttonTextColor,
          //       ),
          //     )),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              hintText: widget.hintText,
                              border: inputBorder,
                              focusedBorder: inputFocusBorder,
                            ),
                            onChanged: (String value) {
                              if (_debounce?.isActive ?? false) {
                                _debounce?.cancel();
                              }
                              if (value.isEmpty) {
                                //_focusNode.unfocus();
                                //_options.clear();
                                _selectedSuggestion = null;
                                _suggestions.clear();
                                setState(() {});
                                return;
                              }

                              _debounce = Timer(
                                  const Duration(milliseconds: 2000), () async {
                                if (kDebugMode) {
                                  print(value);
                                }
                                var client = http.Client();
                                try {
                                  const testUrl =
                                      'https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/address';
                                  final queryBody = jsonEncode(
                                    QueryData(value).toJson(
                                        widget.responseResultsMaxCount,
                                        widget.baseRegionCode),
                                  );
                                  var testResponse = await http.post(
                                    Uri.parse(testUrl),
                                    headers: <String, String>{
                                      "Content-Type": "application/json",
                                      "Accept": "application/json",
                                      "Authorization":
                                          "Token ${widget.daDataToken}",
                                    },
                                    body: queryBody,
                                  );
                                  var testDecodedResponse =
                                      jsonDecode(testResponse.body)
                                          as Map<String, dynamic>;
                                  if (kDebugMode) {
                                    print(testDecodedResponse);
                                  }
                                  var testDecodedArray =
                                      testDecodedResponse['suggestions']
                                          as List<dynamic>;
                                  _suggestions = testDecodedArray
                                      .map((e) => DadataSuggestion.fromJson(e))
                                      .toList();

                                  // // final searchValue =
                                  // //     '${widget.prefixSearchText}$value';
                                  // final searchValue = '$country $city $value';
                                  // String url =
                                  //     '${widget.searchBaseUri}/search?q=$searchValue&format=json&polygon_geojson=1&addressdetails=1';
                                  // if (kDebugMode) {
                                  //   print(url);
                                  // }
                                  // var response =
                                  //     await client.get(Uri.parse(url));
                                  // // var response = await client.post(Uri.parse(url));
                                  // var decodedResponse = jsonDecode(
                                  //         utf8.decode(response.bodyBytes))
                                  //     as List<dynamic>;
                                  // if (kDebugMode) {
                                  //   print(decodedResponse);
                                  // }
                                  // _options = decodedResponse
                                  //     .map((e) => OSMdata(
                                  //         displayname: e['display_name'],
                                  //         lat: double.parse(e['lat']),
                                  //         lon: double.parse(e['lon'])))
                                  //     .toList();
                                  setState(() {});
                                } finally {
                                  client.close();
                                }
                                setState(() {});
                              });
                            }),
                      ),
                      const SizedBox(width: 8.0),
                      IconButton(
                        onPressed: () {
                          if (_searchController.text.isNotEmpty) {
                            _focusNode.unfocus();
                            //_options.clear();
                            _selectedSuggestion = null;
                            _suggestions.clear();
                            _searchController.text = '';
                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ],
                  ),
                  StatefulBuilder(builder: ((context, setState) {
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            _suggestions.length > widget.responseResultsMaxCount
                                ? widget.responseResultsMaxCount
                                : _suggestions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_suggestions[index].displayName),
                            subtitle: Text(
                                '${_suggestions[index].lat},${_suggestions[index].lon}'),
                            onTap: () {
                              _mapController.move(
                                  LatLng(
                                    _suggestions[index].lat,
                                    _suggestions[index].lon,
                                  ),
                                  15.0);
                              _searchController.text =
                                  _suggestions[index].displayName;
                              _selectedSuggestion = _suggestions[index];
                              _focusNode.unfocus();
                              _suggestions.clear();
                              setState(() {});
                            },
                          );
                        });
                    // return ListView.builder(
                    //     shrinkWrap: true,
                    //     physics: const NeverScrollableScrollPhysics(),
                    //     itemCount: _options.length > 5 ? 5 : _options.length,
                    //     itemBuilder: (context, index) {
                    //       return ListTile(
                    //         title: Text(_options[index].displayname),
                    //         subtitle: Text(
                    //             '${_options[index].lat},${_options[index].lon}'),
                    //         onTap: () {
                    //           _mapController.move(
                    //               LatLng(
                    //                   _options[index].lat, _options[index].lon),
                    //               15.0);
                    //           _searchController.text =
                    //               _options[index].displayname;
                    //           _focusNode.unfocus();
                    //           _options.clear();
                    //           setState(() {});
                    //         },
                    //       );
                    //     });
                  })),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: WideButton(
                  widget.buttonText,
                  textStyle: widget.buttonTextStyle,
                  height: widget.buttonHeight,
                  width: widget.buttonWidth,
                  onPressed: () {
                    if (_selectedSuggestion == null) {
                      return;
                    }
                    widget.onPicked(
                      PickedData(
                        LatLong(
                          _selectedSuggestion!.lat,
                          _selectedSuggestion!.lon,
                        ),
                        _selectedSuggestion!.displayName,
                      ),
                    );
                  },
                  // onPressed: () async {
                  //   pickData().then((value) {
                  //     widget.onPicked(value);
                  //   });
                  // },
                  backgroundColor: widget.buttonColor,
                  foregroundColor: widget.buttonTextColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Future<PickedData> pickData() async {
  //   LatLong center = LatLong(
  //       _mapController.center.latitude, _mapController.center.longitude);
  //   var client = http.Client();
  //   String url =
  //       '${widget.searchBaseUri}/reverse?format=json&lat=${_mapController.center.latitude}&lon=${_mapController.center.longitude}&zoom=18&addressdetails=1';

  //   var response = await client.get(Uri.parse(url));
  //   // var response = await client.post(Uri.parse(url));
  //   var decodedResponse =
  //       jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;
  //   String displayName = decodedResponse['display_name'] ?? '';
  //   return PickedData(center, displayName, decodedResponse["address"] ?? '');
  // }
}

// class OSMdata {
//   final String displayname;
//   final double lat;
//   final double lon;
//   OSMdata({required this.displayname, required this.lat, required this.lon});
//   @override
//   String toString() {
//     return '$displayname, $lat, $lon';
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other.runtimeType != runtimeType) {
//       return false;
//     }
//     return other is OSMdata && other.displayname == displayname;
//   }

//   @override
//   int get hashCode => Object.hash(displayname, lat, lon);
// }

class LatLong {
  final double latitude;
  final double longitude;
  const LatLong(this.latitude, this.longitude);
}

class PickedData {
  final LatLong latLong;
  final String addressName;
  //final Map<String, dynamic> address;

  PickedData(this.latLong, this.addressName); //, this.address);
}

class DadataSuggestion {
  final String displayName;
  final String country;
  final String city;
  final double lat;
  final double lon;

  DadataSuggestion(
      this.displayName, this.country, this.city, this.lat, this.lon);

  Map<String, dynamic> toJson() {
    return {
      'value': displayName,
      'country': country,
      'city': city,
      'geo_lat': lat,
      'geo_lon': lon,
    };
  }

  static DadataSuggestion fromJson(Map<String, dynamic> json) {
    return DadataSuggestion(
      json['value'] as String,
      json['data']['country'] as String,
      json['data']['city'] as String,
      double.parse(json['data']['geo_lat'] as String),
      double.parse(json['data']['geo_lon'] as String),
    );
  }
}

class QueryData {
  final String query;

  QueryData(this.query);

  Map<String, dynamic> toJson(int count, String regionCode) {
    return {
      'query': query,
      'count': count,
      'locations_boost': [
        {'kladr_id': regionCode}
      ]
    };
  }
}
