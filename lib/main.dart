import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';


const request = "https://api.hgbrasil.com/finance/quotations?key=0be0fb1c";

void main() async {

  
  runApp(MaterialApp(
    title: 'Conversor de Moedas',
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white
    ),
  ));
  
}

Future<Map> getData() async {  
    try {
    http.Response response = await http.get(request);   
    return json.decode(response.body);      
    } catch (e) {
      return Future.error(Error);      
    }
  

} 

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final realController = TextEditingController();

  double dolar;
  double euro;

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    String textSemVirgula;
    textSemVirgula = text.replaceAll(',' , '.');
    double real = double.parse(textSemVirgula);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }
 
  void _dolarChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    String textSemVirgula;
    textSemVirgula = text.replaceAll(',' , '.');
    double dolar = double.parse(textSemVirgula);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }
 
  void _euroChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    String textSemVirgula;
    textSemVirgula = text.replaceAll(',' , '.');
    double euro = double.parse(textSemVirgula);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Conversor \$', style: TextStyle(fontSize: 30.0, color: Colors.black),),
          centerTitle: true,
          backgroundColor: Colors.amber,
          actions: <Widget>[
            IconButton(
              onPressed: () { setState(() {
                _clearAll();
              });},
              icon: Icon(Icons.refresh),
              iconSize: 30.0,
            )
          ],
        ),
        backgroundColor: Colors.black54,
        body: FutureBuilder<Map>(
          future: getData().catchError((e) => Error),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                case ConnectionState.waiting:
                return Center(
                  child: Text("Carregando dados...",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center, 
                  ),
                );
                break;
              default:
              if (snapshot.hasError) {
                return Center(
                  child: Text("Conecte-se a internet =/",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center, 
                  ),
                );
              } else {
                dolar = snapshot.data['results']['currencies']['USD']['buy'];
                euro = snapshot.data['results']['currencies']['EUR']['buy'];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),
                      Divider(),
                      buidTextField('Reais', 'R\$', realController, _realChanged),
                      Divider(),
                      buidTextField('Dólares', 'U\$', dolarController, _dolarChanged),
                      Divider(),
                      buidTextField('Euros', '£', euroController, _euroChanged),
                    ],
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

Widget buidTextField (String label, String prefix, TextEditingController controller, Function changed) {
  return TextField(
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber),
      ),
      prefixText: '$prefix ',
    ),
    controller: controller,
    style: TextStyle(color: Colors.amber, fontSize: 25.0),     
    onChanged: changed,      
    keyboardType: TextInputType.numberWithOptions(decimal: true),             
  );
  
}