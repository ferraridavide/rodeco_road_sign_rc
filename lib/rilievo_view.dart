import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rodeco_road_sign_rc/models.dart';
import 'package:photo_view/photo_view.dart';

class RilievoView extends StatelessWidget {
  const RilievoView(this.rilievo, {Key? key}) : super(key: key);
  final dynamic rilievo;

  static const valuesTextStyle =
      const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  @override
  Widget build(BuildContext context) {
    if (rilievo is Retroriflettometro) {
      final retroriflettometro = rilievo as Retroriflettometro;
      return Scaffold(
        appBar: AppBar(title: Text("Retroriflettometro")),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Colore:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: SIGN_COLORS.values.toList()[SIGN_COLORS.keys
                            .toList()
                            .indexOf(retroriflettometro.colore)]),
                  ),
                ),
                Text(retroriflettometro.colore)
              ],
            ),
            Text("Foto:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Center(
              child: (retroriflettometro.photoPath == null)
                  ? Text("Nessun dato disponibile")
                  : Stack(
                      children: <Widget>[
                        Image.file(File(retroriflettometro.photoPath!),
                            height: 256),
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => Container(
                                          color: Colors.black,
                                          child: PhotoView(
                                            imageProvider: FileImage(File(
                                                retroriflettometro.photoPath!)),
                                          ))));
                            }),
                          ),
                        ),
                      ],
                    ),
            ),
            Text("Valori:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0.2°:', style: valuesTextStyle),
                        Text(retroriflettometro.value02, style: valuesTextStyle)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0.33°:', style: valuesTextStyle),
                        Text(retroriflettometro.value033,
                            style: valuesTextStyle)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('2.0°:', style: valuesTextStyle),
                        Text(retroriflettometro.value20, style: valuesTextStyle)
                      ],
                    ),
                  ],
                ),
              ),
            )
          ]),
        )),
      );
    }

    if (rilievo is Colorimetro) {
      final colorimetro = rilievo as Colorimetro;
      return Scaffold(
        appBar: AppBar(title: Text("Colorimetro")),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Colore:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: SIGN_COLORS.values.toList()[SIGN_COLORS.keys
                            .toList()
                            .indexOf(colorimetro.colore)]),
                  ),
                ),
                Text(colorimetro.colore)
              ],
            ),
            Text("Foto:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Center(
              child: (colorimetro.photoPath == null)
                  ? Text("Nessun dato disponibile")
                  : Stack(
                      children: <Widget>[
                        Image.file(File(colorimetro.photoPath!), height: 256),
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => Container(
                                          color: Colors.black,
                                          child: PhotoView(
                                            imageProvider: FileImage(
                                                File(colorimetro.photoPath!)),
                                          ))));
                            }),
                          ),
                        ),
                      ],
                    ),
            ),
            Text("Valori:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("β:", style: valuesTextStyle),
                        Text(colorimetro.beta, style: valuesTextStyle)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("x:", style: valuesTextStyle),
                        Text(colorimetro.x, style: valuesTextStyle)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("y:", style: valuesTextStyle),
                        Text(colorimetro.y, style: valuesTextStyle)
                      ],
                    ),
                  ],
                ),
              ),
            )
          ]),
        )),
      );
    }

    return Container();
  }
}
