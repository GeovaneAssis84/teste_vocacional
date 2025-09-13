import 'package:flutter/material.dart';
import 'package:teste_vocacional/tela_avaliacao.dart';
import 'package:teste_vocacional/tela_instrucoes.dart';
import 'main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-vindo!'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Questionário Teste Vocacional',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Navega para a tela do questionário
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuestionnaireScreen()),
                  );
                },
                child: const Text('Iniciar Questionário'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                  side: const BorderSide(color: Colors.deepPurple)
                ),
                onPressed: () {
                  // Navega para a tela de instruções.
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InstructionsScreen()),
                  );
                },
                child: const Text('Ler Instruções'),
              ),
              
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                  side: const BorderSide(color: Colors.deepPurple)
                ),
                onPressed: () {
                  // Navega para a tela de instruções.
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EvaluationScreen()),
                  );
                },
                child: const Text('Avaliar o Aplicativo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
