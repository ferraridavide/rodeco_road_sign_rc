import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rodeco_road_sign_rc/models.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget {
  const MapView(this.eventoLocation, {Key? key}) : super(key: key);
  final GpsPosition eventoLocation;

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GpsPosition? newLocation;
  MapController mapCtrl = new MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            FlutterMap(
              options: MapOptions(
                controller: mapCtrl,
                onLongPress: (newPos) {
                  setState(() {
                    newLocation =
                        GpsPosition(newPos.latitude, newPos.longitude);
                  });
                },
                center: LatLng(widget.eventoLocation.latitude,
                    widget.eventoLocation.longitude),
                zoom: 18.0,
                maxZoom: 18.0,
              ),
              layers: [
                TileLayerOptions(
                    urlTemplate:
                        "http://{s}.google.com/vt/lyrs=s,h&x={x}&y={y}&z={z}",
                    subdomains: ['mt0', 'mt1', 'mt2', 'mt3']),
                MarkerLayerOptions(markers: [
                  (newLocation == null)
                      ? Marker(
                          point: LatLng(widget.eventoLocation.latitude,
                              widget.eventoLocation.longitude),
                          builder: (ctx) =>
                              Icon(Icons.gps_fixed, color: Colors.yellow))
                      : Marker(
                          point: LatLng(
                              newLocation!.latitude, newLocation!.longitude),
                          builder: (ctx) =>
                              Icon(Icons.gps_fixed, color: Colors.yellow))
                ]),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: (newLocation == null)
                  ? null
                  : ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(newLocation),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.location_on),
                          ),
                          Text("Aggiorna coordinate")
                        ],
                        mainAxisSize: MainAxisSize.min,
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
