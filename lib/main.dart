import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(
MaterialApp(
  home: Home(),
  theme: ThemeData(
    primaryColor: Colors.white,
    accentColor: Colors.amber,
    primarySwatch:  Colors.amber,
    brightness: Brightness.dark

  )
)
);

class Home extends StatefulWidget {
@override
  _HomeState createState() => _HomeState();
}
const request ='https://api.hgbrasil.com/finance?format=json&key=f0e5e118';

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final fmt = NumberFormat('#,##0,00', 'pt_BR');

  double dolar;
  double euro;
  Future<Map> dados;

  @override
  void initState() {
   dados = _getData();
   //print(dados['results'][curr])
    super.initState();
  }
  Future<Map> _getData() async {
    http.Response response = await http.get(request);
    return json.decode(response.body);
  }
  Widget buildTextField(String label, String prefixo,
      TextEditingController controller, Function function){
    return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: prefixo,
      border: OutlineInputBorder(),
      labelStyle: TextStyle(color: Colors.amber)
    ),
      style: TextStyle(color: Colors.amber, fontSize: 25),
      onChanged: function,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map>(
        future: dados,
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
           return Center(child: Text('Carregando dados...'));
            default:
              if(snapshot.hasError) {
                return Center(child: Text('Carregando dados...'));
              }else{
                dolar = snapshot.data['results']['currencies']['USD']['buy'];
                euro = snapshot.data['results']['currencies']['EUR']['buy'];

                return SingleChildScrollView(
                 padding: EdgeInsets.all(10),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.stretch,
                   children: <Widget>[
                     Divider(),
                     buildTextField('Reais','R\$',realController, null),
                     Divider(),
                     buildTextField('Dolares','US\$',dolarController,null),
                     Divider(),
                     buildTextField('Euros','€',euroController,null),
                   ],
                 ),
                );
              }
             }
        },
      ),
    );
  }
}
