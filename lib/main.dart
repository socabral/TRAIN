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
  final fmt = NumberFormat('#,##0.00', 'pt_BR');

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
  void realChanged(String texto){
    double real = fmt.parse(texto);
    dolarController.text = fmt.format(real/dolar);
    euroController.text = fmt.format(real/euro);
  }
  void dolarChanged(String texto){
    double valorEmReal = fmt.parse(texto) * dolar;
    realController.text = fmt.format(valorEmReal);
    euroController.text = fmt.format(valorEmReal/euro);
  }
  void euroChanged(String texto){
    double valorEmReal = fmt.parse(texto) * euro;
    realController.text = fmt.format(valorEmReal);
    dolarController.text = fmt.format(valorEmReal/dolar);
  }
  Widget buildTextField(String label, String prefixo,
      TextEditingController controller, Function Converter){
    return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefixText: prefixo,
      border: OutlineInputBorder(),
      labelStyle: TextStyle(color: Colors.amber)
    ),
      style: TextStyle(color: Colors.amber, fontSize: 25),
      onChanged: Converter,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      );
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight (250 - 0.2  * MediaQuery.of(context).size.width),
            child: Stack(
              fit: StackFit.expand,
              children:[
              Container(
                height: 200,
                  child: Image.asset('imagens/money.jpeg', fit: BoxFit.cover)
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: Text('Trading View',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      letterSpacing: 1.2,
                      shadows: [
                        BoxShadow(color: Colors.white38, offset: Offset(3, 3))
                      ]
                    )
                ),
              )

              ]
            ),
            ),
          body: DefaultTextStyle.merge(
            style: TextStyle(
              color: Colors.amber,
              fontSize: 25,
              decoration: TextDecoration.none
               ),
            textAlign: TextAlign.center,
            child: FutureBuilder<Map>(
              future: dados,
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                 return Center(child: Text('Carregando dados...'));
                  default:
                    if(snapshot.hasError) {
                      return Center(child: Text('Erro ao carregar dados...'));
                    }else{
                      dolar = snapshot.data['results']['currencies']['USD']['buy'];
                      euro = snapshot.data['results']['currencies']['EUR']['buy'];

                      return SingleChildScrollView(
                       padding: EdgeInsets.all(10),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.stretch,
                         children: <Widget>[
                           buildTextField('Reais','R\$',realController, realChanged),
                           SizedBox(height: 16),
                           buildTextField('Dolares','US\$',dolarController,dolarChanged),
                           SizedBox(height: 16),
                           buildTextField('Euros','€',euroController,euroChanged),
                         ],
                       ),
                      );
                    }
                   }
              },
            ),
          ),
        ),
      ),
    );
  }
}
