// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lavoro _$LavoroFromJson(Map<String, dynamic> json) {
  return Lavoro(
    json['nomeLavoro'] as String,
  )
    ..eventi = (json['eventi'] as List<dynamic>)
        .map((e) => Evento.fromJson(e as Map<String, dynamic>))
        .toList()
    ..createdAt = DateTime.parse(json['createdAt'] as String);
}

Map<String, dynamic> _$LavoroToJson(Lavoro instance) => <String, dynamic>{
      'nomeLavoro': instance.nomeLavoro,
      'eventi': instance.eventi,
      'createdAt': instance.createdAt.toIso8601String(),
    };

Evento _$EventoFromJson(Map<String, dynamic> json) {
  return Evento(
    json['idEvento'] as String,
  )
    ..createdAt = DateTime.parse(json['createdAt'] as String)
    ..gpsPosition = json['gpsPosition'] == null
        ? null
        : GpsPosition.fromJson(json['gpsPosition'] as Map<String, dynamic>)
    ..fotoList = (json['fotoList'] as List<dynamic>)
        .map((e) => Foto.fromJson(e as Map<String, dynamic>))
        .toList()
    ..retroriflettometroList = (json['retroriflettometroList'] as List<dynamic>)
        .map((e) => Retroriflettometro.fromJson(e as Map<String, dynamic>))
        .toList()
    ..colorimetroList = (json['colorimetroList'] as List<dynamic>)
        .map((e) => Colorimetro.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$EventoToJson(Evento instance) => <String, dynamic>{
      'idEvento': instance.idEvento,
      'createdAt': instance.createdAt.toIso8601String(),
      'gpsPosition': instance.gpsPosition,
      'fotoList': instance.fotoList,
      'retroriflettometroList': instance.retroriflettometroList,
      'colorimetroList': instance.colorimetroList,
    };

Foto _$FotoFromJson(Map<String, dynamic> json) {
  return Foto(
    photoPath: json['photoPath'] as String,
  );
}

Map<String, dynamic> _$FotoToJson(Foto instance) => <String, dynamic>{
      'photoPath': instance.photoPath,
    };

Retroriflettometro _$RetroriflettometroFromJson(Map<String, dynamic> json) {
  return Retroriflettometro(
    json['colore'] as String,
    photoPath: json['photoPath'] as String?,
    value02: json['value02'] as String,
    value033: json['value033'] as String,
    value20: json['value20'] as String,
    note: json['note'] as String,
  );
}

Map<String, dynamic> _$RetroriflettometroToJson(Retroriflettometro instance) =>
    <String, dynamic>{
      'photoPath': instance.photoPath,
      'value02': instance.value02,
      'value033': instance.value033,
      'value20': instance.value20,
      'colore': instance.colore,
      'note': instance.note,
    };

Colorimetro _$ColorimetroFromJson(Map<String, dynamic> json) {
  return Colorimetro(
    json['colore'] as String,
    photoPath: json['photoPath'] as String?,
    beta: json['beta'] as String,
    x: json['x'] as String,
    y: json['y'] as String,
    note: json['note'] as String,
  );
}

Map<String, dynamic> _$ColorimetroToJson(Colorimetro instance) =>
    <String, dynamic>{
      'photoPath': instance.photoPath,
      'beta': instance.beta,
      'x': instance.x,
      'y': instance.y,
      'colore': instance.colore,
      'note': instance.note,
    };

GpsPosition _$GpsPositionFromJson(Map<String, dynamic> json) {
  return GpsPosition(
    (json['latitude'] as num).toDouble(),
    (json['longitude'] as num).toDouble(),
  );
}

Map<String, dynamic> _$GpsPositionToJson(GpsPosition instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
