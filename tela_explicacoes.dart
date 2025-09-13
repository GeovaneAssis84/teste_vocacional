

import 'package:flutter/material.dart';

class ExplanationsScreen extends StatelessWidget {
  const ExplanationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explicações Detalhadas'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Text(
          'Os resultados são baseados no modelo "Big Five" de personalidade, que descreve cinco grandes traços:\n\n'
          '1. Abertura à Experiência: Apreciação por arte, emoção, aventura, ideias incomuns, imaginação e curiosidade.\n\n'
          '2. Conscienciosidade: Tendência a ser organizado e confiável, mostrar autodisciplina, agir com responsabilidade e visar o sucesso.\n\n'
          '3. Extroversão: Energia, emoções positivas, assertividade, sociabilidade e a tendência a buscar a companhia de outros.\n\n'
          '4. Amabilidade: Tendência a ser compassivo e cooperativo em vez de desconfiado e antagônico em relação aos outros.\n\n'
          '5. Neuroticismo: Tendência a experienciar emoções desagradáveis facilmente, como raiva, ansiedade, depressão ou vulnerabilidade.\n\n'
          'Este teste é apenas para fins de entretenimento e autoconhecimento, não substituindo uma avaliação psicológica profissional.',
          style: TextStyle(fontSize: 17, height: 1.5),
        ),
      ),
    );
  }
}