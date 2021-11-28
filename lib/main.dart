import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lavoro_view.dart';
import 'models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MultiProvider(
      providers: [ChangeNotifierProvider<Store>(create: (_) => Store())],
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rodeco Road Sign RC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
      final Store store = Provider.of<Store>(context, listen: false);
    checkLastLavoro(store);
  }


  @override
  Widget build(BuildContext context) {
    final Store store = Provider.of<Store>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Rodeco Road Sign RC"),
      ),
      body: FutureBuilder<List<Lavoro>>(
          initialData: null,
          future: store.getLavori(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if ((snapshot.data!.length == 0)) {
                return Center(child: Text("Crea un lavoro per iniziare"));
              } else {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: ListTile(
                          title: Text(snapshot.data![index].nomeLavoro),
                          subtitle: Text("Creato il " +
                              DateFormat('dd/MM/yyyy – kk:mm')
                                  .format(snapshot.data![index].createdAt)),
                          leading: Column(
                            children: <Widget>[
                              Icon(Icons.engineering, size: 32)
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                          ),
                          trailing: Icon(Icons.navigate_next),
                          onTap: () => onTapLavoro(snapshot.data![index]),
                          onLongPress: () => showDeleteLavoroDialog(
                              store, snapshot.data![index]),
                        ),
                      );
                    },
                    padding: const EdgeInsets.all(8));
              }
            } else {
              return Center(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Caricamento in corso..."),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LinearProgressIndicator(value: null),
                  ),
                ],
              ));
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddLavoroDialog(store),
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> onTapLavoro(Lavoro lavoro) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("lastLavoro", Helpers.getFolderSafeName(lavoro.nomeLavoro));
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => ChangeNotifierProvider<Lavoro>.value(
                value: lavoro, child: LavoroView())));
  }

  showAddLavoroDialog(Store store) async {
    TextEditingController _controller = TextEditingController();
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
                  child: Text('Inserire nome lavoro:'),
                ),
                new TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: "Lavoro"))
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
      try {
        await store.addLavoro(new Lavoro(result));
      } on Exception catch (ex) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(ex.toString())));
      }
    }
  }

  showDeleteLavoroDialog(Store store, Lavoro lavoro) async {
    TextEditingController _controller = TextEditingController();
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
                  child: Text(
                      'Per eliminare il lavoro selezionato, riscrivere il nome "' +
                          lavoro.nomeLavoro +
                          '":'),
                ),
                new TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: lavoro.nomeLavoro))
              ],
            ),
            actions: <Widget>[
              new TextButton(
                  child: const Text('ANNULLA'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new TextButton(
                  child: const Text('ELIMINA'),
                  onPressed: () {
                    Navigator.pop(context, _controller.text);
                  })
            ],
          );
        });

    if (result != null && result.isNotEmpty && result == lavoro.nomeLavoro) {
      await store.deleteLavoro(lavoro);
    }
  }

  void checkLastLavoro(Store store) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastLavoro = prefs.getString("lastLavoro");
    if (lastLavoro != null){
      List<Lavoro> lavoro = (await store.getLavori()).where((element) => Helpers.getFolderSafeName(element.nomeLavoro) == lastLavoro).toList();
      if (lavoro.length != 0){
        onTapLavoro(lavoro[0]);
      }
    }
  }
}
