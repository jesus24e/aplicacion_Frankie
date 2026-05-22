import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Principal extends StatefulWidget {
  const Principal({super.key, required this.titulo});
  final String titulo;

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  void _leerDatoNube() async {
    DocumentSnapshot elDoc = await db
        .collection("prueba")
        .doc("miPagina")
        .get();
    setState(() {
      _counter = elDoc.get("elContador");
    });
  }

  void _escribirDatoNube() async {
    db.collection("prueba").doc("miPagina").set({"elContador": _counter});
  }

  double _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter += 2;
    });
    _escribirDatoNube();
  }

  void _decrementCounter() {
    setState(() {
      if (_counter >= 2) {
        _counter -= 2;
      }
    });
    _escribirDatoNube();
  }

  @override
  void initState() {
    _leerDatoNube();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.titulo),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Has presionado el boton $_counter veces',
              style: TextStyle(fontSize: _counter),
            ),
            MaterialButton(
              onPressed: () {},
              color: Colors.amber,
              child: Text(
                "Texto Prueba",
                style: TextStyle(fontSize: _counter),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _decrementCounter,
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
