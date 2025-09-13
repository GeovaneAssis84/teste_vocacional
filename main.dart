import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tela_resultados.dart';
import 'tela_inicial.dart';

void main() {
  runApp(const QuestionnaireApp());
}


// Classe para representar uma pergunta do JSON.
class Question {
  final String questionText;
  final String type;

  Question({required this.questionText, required this.type});

  // Cria uma Question a partir de um mapa JSON.
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['questionText'],
      type: json['type'],
    );
  }
}

// Widget principal
class QuestionnaireApp extends StatelessWidget {
  const QuestionnaireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Questionário Teste Vocacional',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      
      home: const HomeScreen(),
    );
  }
}


// Tela do Questionário
class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  // Mapa para acumular as pontuações de cada tipo.
  final Map<String, int> _scores = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  // Função para carregar as perguntas do arquivo JSON
  Future<void> _loadQuestions() async {
    try {
      final String response = await rootBundle.loadString('assets/questions.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _questions = data.map((json) => Question.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      // Trata possíveis erros ao carregar o arquivo.
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar perguntas: $e')),
      );
    }
  }


  // Função chamada quando uma resposta é selecionada.
  void _answerQuestion(int score) {
    
    String questionType = _questions[_currentQuestionIndex].type;
    // Adiciona a pontuação ao tipo correspondente.
    _scores[questionType] = (_scores[questionType] ?? 0) + score;
    // Avança para a próxima pergunta ou finaliza o questionário.
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        // Se for a última pergunta, navega para a tela de resultados.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ResultsScreen(scores: _scores)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pergunta ${_currentQuestionIndex + 1} de ${_questions.length}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? const Center(child: Text('Nenhuma pergunta encontrada.'))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Texto da pergunta
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(51),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          _questions[_currentQuestionIndex].questionText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22.0),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      // Botões de resposta
                      const Text(
                        '1 (Discordo totalmente) a 5 (Concordo totalmente)',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 10.0),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10.0,
                        runSpacing: 10.0,
                        children: List.generate(5, (index) {
                          int score = index + 1;
                          return ElevatedButton(
                            onPressed: () => _answerQuestion(score),
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                              backgroundColor: Colors.deepPurple.shade100,
                              foregroundColor: Colors.deepPurple,
                            ),
                            child: Text(
                              '$score',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
    );
  }
}

