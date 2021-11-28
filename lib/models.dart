import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:archive/archive_io.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'models.g.dart'; // flutter pub run build_runner build

const String LAVORO_FILENAME = "data.json";

const SIGN_COLORS = {
  "Bianco": Color(0xFFFFFFFF),
  "Giallo": Color(0xFFFFFF00),
  "Rosso": Color(0xFFFF0000),
  "Verde": Color(0xFF00A500),
  "Blu": Color(0xFF003FFF),
  "Rosso scuro": Color(0xFFA50000),
  "Arancione": Color(0xFFFF7F00),
  "Grigio": Color(0xFF808080)
};

class Store extends ChangeNotifier {
  addLavoro(Lavoro lavoro) async {
    var safeName = Helpers.getFolderSafeName(lavoro.nomeLavoro);
    String root = await Helpers.localPath;

    if (!await Directory(p.join(root, safeName)).exists()) {
      await Directory(p.join(root, safeName)).create();
      await Helpers.saveLavoro(lavoro);
    } else {
      throw Exception("Un lavoro con questo nome esiste già");
    }
    notifyListeners();
  }

  deleteLavoro(Lavoro lavoro) async {
    await Directory(await lavoro.getPath()).delete(recursive: true);
    notifyListeners();
  }

  Future<List<Lavoro>> getLavori() async {
    String root = await Helpers.localPath;
    return Directory(root)
        .listSync()
        .where(
            (folder) => File(p.join(folder.path, LAVORO_FILENAME)).existsSync())
        .map((folder) {
      final contents =
          File(p.join(folder.path, LAVORO_FILENAME)).readAsStringSync();
      return Lavoro.fromJson(jsonDecode(contents));
    }).toList();
  }
}

@JsonSerializable()
class Lavoro extends ChangeNotifier {
  Lavoro(this.nomeLavoro);

  Future<String> getPath() async => p.join(
      await Helpers.localPath, Helpers.getFolderSafeName(this.nomeLavoro));

  String nomeLavoro = "";

  List<Evento> _eventi = [];
  List<Evento> get eventi {
    return _eventi;
  }

  set eventi(List<Evento> value) {
    _eventi = value;
    _eventi.forEach((evento) {
      evento.addListener(() async => await _update());
    });
  }

  List<Evento> getEventi() => _eventi;

  DateTime createdAt = DateTime.now();

  addEvento(Evento evento) async {
    evento.addListener(() async => await _update());
    _eventi.add(evento);
    await _update();
  }

  void deleteEvento(Evento evento) async {
    evento.getFoto().forEach((element) async {
      if (await File(element.photoPath).exists()) {
        File(element.photoPath).delete();
      }
    });
    evento.getRetroriflettometro().forEach((element) async {
      if (element.photoPath != null &&
          await File(element.photoPath!).exists()) {
        File(element.photoPath!).delete();
      }
    });
    evento.getColorimetro().forEach((element) async {
      if (element.photoPath != null &&
          await File(element.photoPath!).exists()) {
        File(element.photoPath!).delete();
      }
    });
    _eventi.remove(evento);
    await _update();
  }

  _update() async {
    await Helpers.saveLavoro(this);
    notifyListeners();
  }

  factory Lavoro.fromJson(Map<String, dynamic> json) => _$LavoroFromJson(json);
  Map<String, dynamic> toJson() => _$LavoroToJson(this);

  Future<void> exportCsv() async {
    List<List<String>> foto =  [["NOME EVENTO", "DATA EVENTO", "FOTO"]];
    List<List<String>> retro = [["NOME EVENTO", "DATA EVENTO", "COLORE RILIEVO", "FOTO", "0.2", "0.33", "2.0", "LATITUDE", "LONGITUDE"]];
    List<List<String>> color = [["NOME EVENTO", "DATA EVENTO", "COLORE RILIEVO", "FOTO", "BETA", "X", "Y", "LATITUDE", "LONGITUDE"]];

    _eventi.forEach((element) {
      foto.addAll(element.fotoList.map((e) => [element.idEvento, element.createdAt.toString(), e.photoPath]).toList());
      retro.addAll(element.retroriflettometroList.map((e) => [element.idEvento, element.createdAt.toString(), e.colore, e.photoPath ?? "", e.value02, e.value033, e.value20, (element.gpsPosition?.latitude ?? "").toString(), (element.gpsPosition?.longitude ?? "").toString()]).toList());
      color.addAll(element.colorimetroList.map((e) => [element.idEvento, element.createdAt.toString(), e.colore, e.photoPath ?? "", e.beta, e.x, e.y, (element.gpsPosition?.latitude ?? "").toString(), (element.gpsPosition?.longitude ?? "").toString()]).toList());
    });
    
    final path = await this.getPath();
    await File(p.join(path, "foto.csv")).writeAsString(const ListToCsvConverter().convert(foto));
    await File(p.join(path, "retroriflettometro.csv")).writeAsString(const ListToCsvConverter().convert(retro));
    await File(p.join(path, "colorimetro.csv")).writeAsString(const ListToCsvConverter().convert(color));
  }

  Future<String> createZip() async {
    var encoder = ZipFileEncoder();
    var finalZipPath = p.join(await Helpers.localPath,'${Helpers.getFolderSafeName(this.nomeLavoro)}Export.zip');
    encoder.create(finalZipPath);
    encoder.addDirectory(Directory(await this.getPath()));
    encoder.close();
    return finalZipPath;
  }
}

@JsonSerializable()
class Evento extends ChangeNotifier {
  Evento(this.idEvento);
  String idEvento;

  DateTime createdAt = DateTime.now();

  GpsPosition? _gpsPosition;
  GpsPosition? get gpsPosition {
    return _gpsPosition;
  }

  set gpsPosition(GpsPosition? value) {
    _gpsPosition = value;
    notifyListeners();
  }


  List<Foto> fotoList = [];
  List<Foto> getFoto() => fotoList;

  List<Retroriflettometro> retroriflettometroList = [];
  List<Retroriflettometro> getRetroriflettometro() => retroriflettometroList;

  List<Colorimetro> colorimetroList = [];
  List<Colorimetro> getColorimetro() => colorimetroList;

  addFoto(Foto foto) {
    foto.addListener(() => notifyListeners());
    fotoList.add(foto);
    notifyListeners();
  }

  removeFoto(Foto foto) async {
    fotoList.remove(foto);
    if (await File(foto.photoPath).exists()) {
      await File(foto.photoPath).delete();
    }
    notifyListeners();
  }

  addRetroriflettometro(Retroriflettometro retroriflettometro) {
    retroriflettometro.addListener(() => notifyListeners());
    retroriflettometroList.add(retroriflettometro);
    notifyListeners();
  }

  removeRetroriflettometro(Retroriflettometro retroriflettometro) async {
    retroriflettometroList.remove(retroriflettometro);
    if (retroriflettometro.photoPath != null &&
        await File(retroriflettometro.photoPath!).exists()) {
      await File(retroriflettometro.photoPath!).delete();
    }
    notifyListeners();
  }

  addColorimetro(Colorimetro colorimetro) {
    colorimetro.addListener(() => notifyListeners());
    colorimetroList.add(colorimetro);
    notifyListeners();
  }

  removeColorimetro(Colorimetro colorimetro) async {
    colorimetroList.remove(colorimetro);
    if (colorimetro.photoPath != null &&
        await File(colorimetro.photoPath!).exists()) {
      await File(colorimetro.photoPath!).delete();
    }
    notifyListeners();
  }

  factory Evento.fromJson(Map<String, dynamic> json) => _$EventoFromJson(json);
  Map<String, dynamic> toJson() => _$EventoToJson(this);

  Future<void> replaceRetroriflettometro(Retroriflettometro oldR, Retroriflettometro newR) async {
    retroriflettometroList[retroriflettometroList.indexOf(oldR)] = newR;
    if (oldR.photoPath != newR.photoPath && oldR.photoPath != null && await File(oldR.photoPath!).exists()){
      await File(oldR.photoPath!).delete();
    }
    notifyListeners();
  }

  Future<void> replaceColorimetro(Colorimetro oldR, Colorimetro newR) async {
    colorimetroList[colorimetroList.indexOf(oldR)] = newR;
    if (oldR.photoPath != newR.photoPath && oldR.photoPath != null && await File(oldR.photoPath!).exists()){
      await File(oldR.photoPath!).delete();
    }
    notifyListeners();
  }
}

@JsonSerializable()
class Foto extends ChangeNotifier {
  Foto({this.photoPath = ""});
  String photoPath;

  factory Foto.fromJson(Map<String, dynamic> json) => _$FotoFromJson(json);
  Map<String, dynamic> toJson() => _$FotoToJson(this);
}

@JsonSerializable()
class Retroriflettometro extends ChangeNotifier {
  Retroriflettometro(this.colore,
      {this.photoPath = "",
      this.value02 = "",
      this.value033 = "",
      this.value20 = "", this.note = ""});

  String? photoPath;

  String value02;
  String value033;
  String value20;
  String colore;

  String note;

  factory Retroriflettometro.fromJson(Map<String, dynamic> json) =>
      _$RetroriflettometroFromJson(json);
  Map<String, dynamic> toJson() => _$RetroriflettometroToJson(this);
}

@JsonSerializable()
class Colorimetro extends ChangeNotifier {
  Colorimetro(this.colore,
      {this.photoPath = "", this.beta = "", this.x = "", this.y = "", this.note = ""});

  String? photoPath;

  String beta;
  String x;
  String y;

  String colore;

  String note;

  factory Colorimetro.fromJson(Map<String, dynamic> json) =>
      _$ColorimetroFromJson(json);
  Map<String, dynamic> toJson() => _$ColorimetroToJson(this);
}


@JsonSerializable()
class GpsPosition {
  GpsPosition(this.latitude, this.longitude);

  double latitude;
  double longitude;

  factory GpsPosition.fromPosition(Position position) => GpsPosition(position.latitude, position.longitude);
factory GpsPosition.fromJson(Map<String, dynamic> json) =>
      _$GpsPositionFromJson(json);
  Map<String, dynamic> toJson() => _$GpsPositionToJson(this);
}


enum TipoRilievo { retroriflettometro, colorimetro }

class Helpers {
  static Future<String> get localPath async {
    final directory = await getExternalStorageDirectory();
    return directory!.path;
  }

  static String getFolderSafeName(String text) {
    return text
        .replaceAll(RegExp(r'[\s+]'), '_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9\_]'), '');
  }

  static Future<void> saveLavoro(Lavoro lavoro) async {
    String json = jsonEncode(lavoro);
    await File(p.join(await lavoro.getPath(), LAVORO_FILENAME))
        .writeAsString(json);
    print("SAVED");
  }
}
