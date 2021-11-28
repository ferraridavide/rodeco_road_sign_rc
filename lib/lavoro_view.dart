import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'evento_view.dart';
import 'models.dart';

class LavoroView extends StatefulWidget {
  const LavoroView({Key? key}) : super(key: key);

  @override
  _LavoroViewState createState() => _LavoroViewState();
}

class _LavoroViewState extends State<LavoroView> {
  @override
  Widget build(BuildContext context) {
    final lavoro = Provider.of<Lavoro>(context);
    final eventi = lavoro.getEventi();

    return Scaffold(
        appBar: AppBar(
          title: Text(lavoro.nomeLavoro),
          actions: [
            PopupMenuButton<int>(
              onSelected: (s) {
                if (s == 0) {
                  onExportLavoro(lavoro);
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Esporta dati'}.map((String choice) {
                  return PopupMenuItem<int>(
                    value: 0,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: (eventi.length == 0)
            ? Center(
                child: Text("Aggiungi un evento per cominciare"),
              )
            : ListView.builder(
                itemCount: eventi.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(eventi[index].idEvento),
                    subtitle: Text("Creato il " +
                        DateFormat('dd/MM/yyyy – kk:mm')
                            .format(eventi[index].createdAt)),
                    onTap: () => onOpenEvento(eventi[index]),
                    onLongPress: () => onDeleteEvento(lavoro, eventi[index]),
                    leading: Column(
                      children: <Widget>[Icon(Icons.flag, size: 32)],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                    trailing: Icon(Icons.navigate_next),
                  );
                }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => onNewEvento(lavoro),
          child: Icon(Icons.note_add),
        ));
  }

  onNewEvento(Lavoro lavoro) async {
    TextEditingController _controller = TextEditingController();
    _controller.text = "#${(lavoro.getEventi().length + 1).toString()}";
    var result = await showDialog<String>(
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
                  child: Text('Inserire ID Evento:'),
                ),
                new TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: "ID"))
              ],
            ),
            actions: <Widget>[
              new TextButton(
                  child: const Text('ANNULLA'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new TextButton(
                  child: const Text('CREA'),
                  onPressed: () {
                    Navigator.pop(context, _controller.text);
                  })
            ],
          );
        });

    if (result != null && result.isNotEmpty) {
      await lavoro.addEvento(new Evento(result));
    }
  }

  onOpenEvento(Evento evento) {
    final lavoro = Provider.of<Lavoro>(context, listen: false);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => MultiProvider(providers: [
                  ChangeNotifierProvider<Evento>.value(value: evento),
                  ChangeNotifierProvider<Lavoro>.value(value: lavoro),
                ], child: EventoView())));
  }

  onDeleteEvento(Lavoro lavoro, Evento evento) async {
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
      lavoro.deleteEvento(evento);
    }
  }

  onExportLavoro(Lavoro lavoro) async {
    try {
      await lavoro.exportCsv();
      var zipPath = await lavoro.createZip();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Salvataggio CSV avvenuto con successo!"),
        action: SnackBarAction(label: "Condividi", onPressed: () => {Share.shareFiles([zipPath], mimeTypes: ["application/zip"])}),
      ));
    } catch (ex) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ex.toString())));
    }
  }
}
