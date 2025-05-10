import 'package:flutter/material.dart';
import 'package:flutter_snake/Utilidades/preferencias.dart';

class AjustesPagina extends StatefulWidget {
  const AjustesPagina({Key? key}) : super(key: key);
  @override
  State<AjustesPagina> createState() => _AjustesPaginaState();
}

class _AjustesPaginaState extends State<AjustesPagina> {
  late Dificultad _seleccionada = Dificultad.facil;

  @override
  void initState() {
    super.initState();
    Preferencias.getDificultad().then((d) {
      setState(() => _seleccionada = d);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Dificultad:', style: TextStyle(fontSize: 18)),
            DropdownButton<Dificultad>(
              value: _seleccionada,
              items: Dificultad.values.map((d) {
                return DropdownMenuItem(
                  value: d,
                  child: Text({
                    Dificultad.muyFacil: 'Muy Fácil',
                    Dificultad.facil:    'Fácil',
                    Dificultad.normal:   'Normal',
                    Dificultad.dificil:  'Difícil',
                  }[d]!),
                );
              }).toList(),
              onChanged: (d) {
                if (d == null) return;
                setState(() => _seleccionada = d);
                Preferencias.setDificultad(d);
              },
            ),
          ],
        ),
      ),
    );
  }
}
