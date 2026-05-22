import 'package:flutter/material.dart';

class calculadora extends StatefulWidget {
  const calculadora({super.key, required this.titulo});

  final String titulo;

  @override
  State<calculadora> createState() => _calculadoraState();
}

class _calculadoraState extends State<calculadora> {
  final TextEditingController _pantallaCalculadora = TextEditingController(
    text: "0",
  );
  final TextEditingController _pantallaAnterior = TextEditingController(
    text: "",
  );
  String _operacion = "";
  String _textoActual = "0";
  dynamic _valorAnterior = 0;
  bool _esperandoNuevoNumero = false;
  bool _tieneDecimal = false;

  List<dynamic> simbolosBotones = [
    [7, 8, 9, "+"],
    [4, 5, 6, "-"],
    [1, 2, 3, "*"],
    ["=", 0, ".", "/"],
  ];

  double opera(String operador) {
    double valorActual = double.parse(_textoActual);
    switch (operador) {
      case "+":
        return _valorAnterior + valorActual;
      case "-":
        return _valorAnterior - valorActual;
      case "*":
        return _valorAnterior * valorActual;
      case "/":
        return _valorAnterior / valorActual;
      default:
        return valorActual;
    }
  }

  void _presionarBotonCalculadora(dynamic n) {
    if (n is num) {
      setState(() {
        if (_textoActual == "0" || _esperandoNuevoNumero) {
          _textoActual = "$n";
          _esperandoNuevoNumero = false;
          _tieneDecimal = false;
        } else {
          _textoActual = _textoActual + "$n";
        }
        _pantallaCalculadora.text = _textoActual;
      });
      return;
    }

    switch (n) {
      case ".":
        if (_tieneDecimal) break;
        setState(() {
          if (_esperandoNuevoNumero) {
            _textoActual = "0.";
            _esperandoNuevoNumero = false;
          } else {
            _textoActual = _textoActual + ".";
          }
          _tieneDecimal = true;
          _pantallaCalculadora.text = _textoActual;
        });
        break;

      case "+":
      case "-":
      case "*":
      case "/":
        setState(() {
          if (_operacion == "") {
            _valorAnterior = double.parse(_textoActual);
          } else {
            _valorAnterior = opera(_operacion);
          }

          _operacion = n;
          _esperandoNuevoNumero = true;
          _tieneDecimal = false;

          _pantallaAnterior.text = "$_valorAnterior $_operacion";
          _pantallaCalculadora.text = "$_valorAnterior";
        });
        break;

      case "=":
        if (_operacion != "") {
          double resultado = opera(_operacion);

          String textoResultado = resultado == resultado.truncateToDouble()
              ? "${resultado.toInt()}"
              : "$resultado";

          setState(() {
            _pantallaCalculadora.text = textoResultado;
            _pantallaAnterior.text = "";
          });

          _textoActual = textoResultado;
          _valorAnterior = 0;
          _operacion = "";
          _esperandoNuevoNumero = true;
          _tieneDecimal = textoResultado.contains(".");
        }
        break;
    }
  }

  Widget _construyeTeclado() {
    return Expanded(
      child: Column(
        children: List.generate(simbolosBotones.length, (j) {
          return Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(simbolosBotones[j].length, (i) {
                dynamic digito = simbolosBotones[j][i];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SizedBox(
                      height: double.infinity,
                      child: MaterialButton(
                        onPressed: () => _presionarBotonCalculadora(digito),
                        color: Colors.black,
                        child: Text(
                          "$digito",
                          style: const TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.titulo),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SizedBox(height: 5),
              Container(
                height: 40,
                width: double.infinity,
                color: Colors.grey,
                child: TextField(
                  controller: _pantallaAnterior,
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 40,
                width: double.infinity,
                color: Colors.grey,
                child: TextField(
                  controller: _pantallaCalculadora,
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(height: 10),
              _construyeTeclado(),
            ],
          ),
        ),
      ),
    );
  }
}