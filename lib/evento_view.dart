import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rodeco_road_sign_rc/add_rilievo_view.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import 'package:path/path.dart' as p;

import 'geoService.dart';
import 'map_view.dart';
import 'models.dart';

class EventoView extends StatefulWidget {
  EventoView({Key? key}) : super(key: key);

  @override
  _EventoViewState createState() => _EventoViewState();
}

class _EventoViewState extends State<EventoView> {
  Widget generateRowButton(String text, void Function() onPressed) {
    return Expanded(
      child: OutlinedButton(
          onPressed: onPressed,
          child: Text(
            text,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          )),
    );
  }

  late final MapController mapController;
  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  bool gpsLoading = false;

  @override
  Widget build(BuildContext context) {
    final evento = Provider.of<Evento>(context);

    final fotoList = evento.getFoto();
    final retroriflettometroList = evento.getRetroriflettometro();
    final colorimetroList = evento.getColorimetro();

    return Scaffold(
      appBar: AppBar(title: Text(evento.idEvento)),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text("Foto",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                    onPressed: () => onAddFoto(evento), icon: Icon(Icons.add))
              ],
            ),
            (fotoList.length == 0)
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Nessun dato disponibile"),
                  ))
                : SizedBox(
                    height: 128,
                    child: ListView.separated(
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            width: 10,
                          );
                        },
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: fotoList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(
                            children: <Widget>[
                              Image.file(File(fotoList[index].photoPath),
                                  cacheHeight: 256),
                              Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (context) => Container(
                                                  color: Colors.black,
                                                  child: PhotoView(
                                                    imageProvider: FileImage(
                                                        File(fotoList[index]
                                                            .photoPath)),
                                                  ))));
                                    },
                                    onLongPress: () => showRilievoDeleteDialog(
                                        evento, fotoList[index]),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text("Retroriflettometro",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                    onPressed: () => onAddRetroriflettometro(evento),
                    icon: Icon(Icons.add))
              ],
            ),
            (retroriflettometroList.length == 0)
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Nessun dato disponibile"),
                  ))
                : Column(
                    children: retroriflettometroList.map((x) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          child: ListTile(
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 32,
                                    width: 32,
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black,
                                              blurRadius: 2)
                                        ],
                                        shape: BoxShape.circle,
                                        color: SIGN_COLORS.values.toList()[
                                            SIGN_COLORS.keys
                                                .toList()
                                                .indexOf(x.colore)]),
                                  )
                                ],
                              ),
                              title: Text("#" +
                                  (retroriflettometroList.indexOf(x) + 1)
                                      .toString()),
                              subtitle:
                                  (x.note.isNotEmpty) ? Text(x.note) : null,
                              trailing: Icon(Icons.navigate_next),
                              onTap: () => onOpenRilievo(evento, x),
                              onLongPress: () =>
                                  showRilievoDeleteDialog(evento, x)),
                        ),
                      );
                    }).toList(),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text("Colorimetro",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                    onPressed: () => onAddColorimetro(evento),
                    icon: Icon(Icons.add))
              ],
            ),
            (colorimetroList.length == 0)
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Nessun dato disponibile"),
                  ))
                : Column(
                    children: colorimetroList.map((x) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          child: ListTile(
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 32,
                                    width: 32,
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black,
                                              blurRadius: 2)
                                        ],
                                        shape: BoxShape.circle,
                                        color: SIGN_COLORS.values.toList()[
                                            SIGN_COLORS.keys
                                                .toList()
                                                .indexOf(x.colore)]),
                                  )
                                ],
                              ),
                              title: Text("#" +
                                  (colorimetroList.indexOf(x) + 1).toString()),
                              trailing: Icon(Icons.navigate_next),
                              subtitle:
                                  (x.note.isNotEmpty) ? Text(x.note) : null,
                              onTap: () => onOpenRilievo(evento, x),
                              onLongPress: () =>
                                  showRilievoDeleteDialog(evento, x)),
                        ),
                      );
                    }).toList(),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Coordinate GPS",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            if (gpsLoading)
              Center(child: CircularProgressIndicator())
            else if (evento.gpsPosition != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Column(
                        children: [
                          Row(children: [
                            Text("Latitude:"),
                            Text(evento.gpsPosition!.latitude.toString())
                          ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                          Row(children: [
                            Text("Longitude:"),
                            Text(evento.gpsPosition!.longitude.toString())
                          ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                          AspectRatio(
                              aspectRatio: 2,
                              child: FlutterMap(
                                  mapController: mapController,
                                  options: MapOptions(
                                    onTap: (x) async {
                                      final result =
                                          await Navigator.push<GpsPosition?>(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (context) => MapView(
                                                      evento.gpsPosition!)));
                                      if (result != null) {
                                        evento.gpsPosition = result;
                                        mapController.move(
                                            LatLng(result.latitude,
                                                result.longitude),
                                            18.0);
                                      }
                                    },
                                    center: LatLng(evento.gpsPosition!.latitude,
                                        evento.gpsPosition!.longitude),
                                    zoom: 18.0,
                                    maxZoom: 18.0,
                                  ),
                                  layers: [
                                    TileLayerOptions(
                                        urlTemplate:
                                            "http://{s}.google.com/vt/lyrs=s,h&x={x}&y={y}&z={z}",
                                        subdomains: [
                                          'mt0',
                                          'mt1',
                                          'mt2',
                                          'mt3'
                                        ]),
                                    MarkerLayerOptions(markers: [
                                      Marker(
                                          point: LatLng(
                                              evento.gpsPosition!.latitude,
                                              evento.gpsPosition!.longitude),
                                          builder: (ctx) => Icon(
                                              Icons.gps_fixed,
                                              color: Colors.yellow))
                                    ])
                                  ])),
                          OutlinedButton(
                              onPressed: () => evento.gpsPosition = null,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.delete),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text("Elimina coordinate GPS"),
                                  )
                                ],
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                    child: OutlinedButton(
                        onPressed: () async {
                          setState(() {
                            gpsLoading = true;
                          });
                          Position gps = await determinePosition();
                          evento.gpsPosition = GpsPosition.fromPosition(gps);
                          setState(() {
                            gpsLoading = false;
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_location),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text("Aggiungi coordinate GPS"),
                            )
                          ],
                        ))),
              ),
          ],
        ),
      ),
    );
  }

  onAddFoto(Evento evento) async {
    final picker = ImagePicker();
    final PickedFile? imageFile =
        await picker.getImage(source: ImageSource.camera);
    if (imageFile != null) {
      final lavoro = Provider.of<Lavoro>(context, listen: false);
      final finalPath = p.join(
          await lavoro.getPath(),
          Helpers.getFolderSafeName(evento.idEvento) +
              "_Foto" +
              evento.getFoto().length.toString() +
              "_" +
              (DateTime.now().toUtc().millisecondsSinceEpoch / 1000)
                  .truncate()
                  .toString() +
              p.extension(imageFile.path));
      await File(imageFile.path).copy(finalPath);
      await File(imageFile.path).delete();
      evento.addFoto(Foto()..photoPath = finalPath);
    }
  }

  onAddRetroriflettometro(Evento evento) async {
    final lavoro = Provider.of<Lavoro>(context, listen: false);
    final result = await Navigator.push<Retroriflettometro>(
        context,
        CupertinoPageRoute(
            builder: (context) => MultiProvider(providers: [
                  ChangeNotifierProvider<Evento>.value(value: evento),
                  ChangeNotifierProvider<Lavoro>.value(value: lavoro),
                ], child: AddRilievoView(TipoRilievo.retroriflettometro))));
    if (result != null) {
      evento.addRetroriflettometro(result);
    }
  }

  onAddColorimetro(Evento evento) async {
    final lavoro = Provider.of<Lavoro>(context, listen: false);
    final result = await Navigator.push<Colorimetro>(
        context,
        CupertinoPageRoute(
            builder: (context) => MultiProvider(providers: [
                  ChangeNotifierProvider<Evento>.value(value: evento),
                  ChangeNotifierProvider<Lavoro>.value(value: lavoro),
                ], child: AddRilievoView(TipoRilievo.colorimetro))));
    if (result != null) {
      evento.addColorimetro(result);
    }
  }

  showRilievoDeleteDialog(Evento evento, dynamic rilievo) async {
    var result = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            content: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('Sei sicuro di voler eliminare?'),
                )
              ],
            ),
            actions: <Widget>[
              new TextButton(
                  child: const Text('NO'),
                  onPressed: () {
                    Navigator.pop(context, false);
                  }),
              new TextButton(
                  child: const Text('SI'),
                  onPressed: () {
                    Navigator.pop(context, true);
                  })
            ],
          );
        });

    if (result == true) {
      if (rilievo is Foto) {
        await evento.removeFoto(rilievo);
      } else if (rilievo is Retroriflettometro) {
        await evento.removeRetroriflettometro(rilievo);
      } else if (rilievo is Colorimetro) {
        await evento.removeColorimetro(rilievo);
      }
    }
  }

  onOpenRilievo(Evento evento, dynamic x) async {
    if (x is Retroriflettometro) {
      final lavoro = Provider.of<Lavoro>(context, listen: false);
      final result = await Navigator.push<Retroriflettometro>(
          context,
          CupertinoPageRoute(
              builder: (context) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider<Evento>.value(value: evento),
                        ChangeNotifierProvider<Lavoro>.value(value: lavoro),
                      ],
                      child: AddRilievoView(TipoRilievo.retroriflettometro,
                          existingRilievo: x))));
      if (result != null) {
        evento.replaceRetroriflettometro(x, result);
      }
      return;
    }

    if (x is Colorimetro) {
      final lavoro = Provider.of<Lavoro>(context, listen: false);
      final result = await Navigator.push<Colorimetro>(
          context,
          CupertinoPageRoute(
              builder: (context) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider<Evento>.value(value: evento),
                        ChangeNotifierProvider<Lavoro>.value(value: lavoro),
                      ],
                      child: AddRilievoView(TipoRilievo.colorimetro,
                          existingRilievo: x))));
      if (result != null) {
        evento.replaceColorimetro(x, result);
      }
      return;
    }
  }
}
