import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rodeco_road_sign_rc/models.dart';
import 'package:rodeco_road_sign_rc/rilevamento_view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import 'package:path/path.dart' as p;

class AddRilievoView extends StatefulWidget {
  const AddRilievoView(this.tipo, {Key? key, this.existingRilievo})
      : super(key: key);
  final TipoRilievo tipo;
  final dynamic existingRilievo;

  @override
  _AddRilievoViewState createState() => _AddRilievoViewState();
}

class _AddRilievoViewState extends State<AddRilievoView> {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> textControllers =
      new List<TextEditingController>.generate(
          3, (i) => TextEditingController());

  TextEditingController noteController = TextEditingController();
  int selectedColor = 0;
  String? photoPath;

  @override
  void initState() {
    super.initState();
    if (widget.existingRilievo is Retroriflettometro) {
      final retro = widget.existingRilievo as Retroriflettometro;
      setState(() {
        selectedColor = SIGN_COLORS.keys.toList().indexOf(retro.colore);
        photoPath = retro.photoPath;
        textControllers[0].text = retro.value02;
        textControllers[1].text = retro.value033;
        textControllers[2].text = retro.value20;

        noteController.text = retro.note;
      });
    }
    if (widget.existingRilievo is Colorimetro) {
      final color = widget.existingRilievo as Colorimetro;
      setState(() {
        selectedColor = SIGN_COLORS.keys.toList().indexOf(color.colore);
        photoPath = color.photoPath;
        textControllers[0].text = color.beta;
        textControllers[1].text = color.x;
        textControllers[2].text = color.y;

        noteController.text = color.note;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (TipoRilievo tipo) {
          switch (tipo) {
            case TipoRilievo.retroriflettometro:
              return Text("Retroriflettometro");
            case TipoRilievo.colorimetro:
              return Text("Colorimetro");
          }
        }(this.widget.tipo),
        actions: [
          IconButton(
              onPressed: () {
                onAddRilievo();
              },
              icon: Icon(Icons.save_alt))
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Colore:",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              DropdownButton<int>(
                  isExpanded: true,
                  value: selectedColor,
                  icon: const Icon(Icons.expand_more),
                  iconSize: 24,
                  elevation: 16,
                  itemHeight: 64,
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedColor = newValue!;
                    });
                  },
                  items:
                      SIGN_COLORS.entries.map<DropdownMenuItem<int>>((value) {
                    return DropdownMenuItem<int>(
                        value: SIGN_COLORS.keys.toList().indexOf(value.key),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 32,
                                width: 32,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: value.value),
                              ),
                            ),
                            Text(value.key)
                          ],
                        ));
                  }).toList()),
              Text("Foto:",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Center(
                child: (photoPath == null)
                    ? OutlinedButton(
                        onPressed: () => onRilevaSchermo(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.qr_code_scanner),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: (TipoRilievo tipo) {
                                switch (tipo) {
                                  case TipoRilievo.retroriflettometro:
                                    return Text(
                                        "Rileva schermo retroriflettometro");
                                  case TipoRilievo.colorimetro:
                                    return Text("Rileva schermo colorimetro");
                                }
                              }(this.widget.tipo),
                            )
                          ],
                        ))
                    : Stack(
                        children: <Widget>[
                          Image.file(File(this.photoPath!), height: 256),
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
                                                  File(this.photoPath!)),
                                            ))));
                              }, onLongPress: () async {
                                setState(() {
                                  this.photoPath = null;
                                });
                              }),
                            ),
                          ),
                        ],
                      ),
              ),
              Text("Valori:",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Form(
                  key: _formKey,
                  child: Column(
                    children: () {
                      switch (widget.tipo) {
                        case TipoRilievo.retroriflettometro:
                          return [
                            generateTextFormField('0.2°', textControllers[0]),
                            generateTextFormField('0.33°', textControllers[1]),
                            generateTextFormField('2.0°', textControllers[2]),
                          ];
                        case TipoRilievo.colorimetro:
                          return [
                            generateTextFormField('β', textControllers[0]),
                            generateTextFormField('x', textControllers[1]),
                            generateTextFormField('y', textControllers[2]),
                          ];
                        default:
                          return [] as List<Widget>;
                      }
                    }(),
                  )),
              Text("Note:",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "..."),
                  keyboardType: TextInputType.text,
                  maxLines: 3,
                  controller: noteController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget generateTextFormField(
      String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration:
            InputDecoration(border: OutlineInputBorder(), labelText: labelText),
        // The validator receives the text that the user has entered.
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Inserisci un valore';
          }
          return null;
        },
      ),
    );
  }

  onAddRilievo() async {
    final lavoro = Provider.of<Lavoro>(context, listen: false);
    final evento = Provider.of<Evento>(context, listen: false);
    String? finalPath;
    Function(String) salvare = (String nome) async {
      finalPath = p.join(
          await lavoro.getPath(),
          Helpers.getFolderSafeName(evento.idEvento) +
              "_${nome}_" +
              SIGN_COLORS.keys.toList()[selectedColor] +
              "_" +
              evento.getRetroriflettometro().length.toString() +
              "_" +
              (DateTime.now().toUtc().millisecondsSinceEpoch / 1000)
                  .truncate()
                  .toString() +
              p.extension(this.photoPath!));

      await File(this.photoPath!).copy(finalPath!);
      await File(this.photoPath!).delete();
    };

    switch (widget.tipo) {
      case TipoRilievo.retroriflettometro:
        if (widget.existingRilievo == null) {
          if (this.photoPath != null) {
            await salvare("Retro");
          }
        } else {
          // AGGIORNO
          final oldRetro = (widget.existingRilievo as Retroriflettometro);
          if (this.photoPath != null) {
            if (oldRetro.photoPath != this.photoPath) {
              if (oldRetro.photoPath != null &&
                  await File(oldRetro.photoPath!).exists()) {
                await File(oldRetro.photoPath!).delete();
              }
              await salvare("Retro");
            } else {
              finalPath = this.photoPath;
            }
          } else {
            if (oldRetro.photoPath != null &&
                await File(oldRetro.photoPath!).exists()) {
              await File(oldRetro.photoPath!).delete();
            }
          }
        }

        Navigator.pop(
            context,
            Retroriflettometro(SIGN_COLORS.keys.toList()[selectedColor],
                photoPath: finalPath,
                value02: textControllers[0].text,
                value033: textControllers[1].text,
                value20: textControllers[2].text,
                note: noteController.text));
        break;
      case TipoRilievo.colorimetro:
        if (widget.existingRilievo == null) {
          if (this.photoPath != null) {
            await salvare("Color");
          }
        } else {
          // AGGIORNO
          final oldColor = (widget.existingRilievo as Colorimetro);
          if (this.photoPath != null) {
            if (oldColor.photoPath != this.photoPath) {
              if (oldColor.photoPath != null &&
                  await File(oldColor.photoPath!).exists()) {
                await File(oldColor.photoPath!).delete();
              }
              await salvare("Color");
            } else {
              finalPath = this.photoPath;
            }
          } else {
            if (oldColor.photoPath != null &&
                await File(oldColor.photoPath!).exists()) {
              await File(oldColor.photoPath!).delete();
            }
          }
        }

        Navigator.pop(
            context,
            Colorimetro(SIGN_COLORS.keys.toList()[selectedColor],
                photoPath: finalPath,
                beta: textControllers[0].text,
                x: textControllers[1].text,
                y: textControllers[2].text,
                note: noteController.text));
        break;
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textControllers.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }

  onRilevaSchermo() async {
    double aspectRatio;
    List<List<double>> blockPerc;

    switch (widget.tipo) {
      case TipoRilievo.retroriflettometro:
        aspectRatio = 0.67;
        blockPerc = [
          [1 / 2, 300 / 1097],
          [1 / 2, 419 / 1097],
          [1 / 2, 540 / 1097],
        ];
        break;
      case TipoRilievo.colorimetro:
        aspectRatio = 1.48;
        blockPerc = [
          [568 / 1044, 237 / 705],
          [568 / 1044, 322 / 705],
          [568 / 1044, 410 / 705],
        ];
        break;
    }

    var result = await Navigator.push<RilevamentoResult>(
        context,
        CupertinoPageRoute(
            builder: (context) => RilevamentoView(aspectRatio, blockPerc)));
    if (result != null) {
      final regexRule = RegExp(r"\d+([\.,]\d+)?");
      if (widget.tipo == TipoRilievo.colorimetro) {}

      switch (widget.tipo) {
        case TipoRilievo.retroriflettometro:
          textControllers[0].text =
              regexRule.stringMatch(result.values[0]) ?? result.values[0];
          textControllers[1].text =
              regexRule.stringMatch(result.values[1]) ?? result.values[1];
          textControllers[2].text =
              regexRule.stringMatch(result.values[2]) ?? result.values[2];
          break;
        case TipoRilievo.colorimetro:
          textControllers[0].text =
              regexRule.stringMatch(result.values[0]) ?? result.values[0];
          textControllers[1].text =
              regexRule.stringMatch(result.values[1]) ?? result.values[1];
          textControllers[2].text =
              regexRule.stringMatch(result.values[2]) ?? result.values[2];
          break;
        default:
          break;
      }

      setState(() {
        this.photoPath = result.photoPath;
      });
    }
  }
}
