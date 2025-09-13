
import 'package:flutter/material.dart';


// Tela de Instruções
class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instruções'),
        // O botão de voltar é adicionado automaticamente pelo Navigator.
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            'Responda a cada pergunta de acordo com suas preferências pessoais.\n\n'
'Utilize a escala de 1 a 5, onde:\n'
'1 - Discordo totalmente\n'
'2 - Discordo\n'
'3 - Neutro\n'
'4 - Concordo\n'
'5 - Concordo totalmente\n\n'
'Suas respostas ajudarão a identificar áreas de interesse e possíveis caminhos profissionais compatíveis com o seu perfil.\n '
'Responda com sinceridade para obter um resultado mais preciso.\n'
'Busque diversificar suas respostas, evitando escolher sempre o mesmo número.\n\n'
'No final as profissões terão links para você pesquisar mais sobre elas.\n\n\n'
'NÃO ESQUEÇA DE AVALIAR O APLICATIVO NO FINAL DO QUESTIONÁRIO!',
            style: TextStyle(fontSize: 18, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}