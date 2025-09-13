
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teste_vocacional/tela_avaliacao.dart';
import 'dart:convert';
import 'tela_inicial.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherUtil {
  static Future<void> launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ops! Não foi possível abrir o link.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


// Link individual
class LinkData {
  final String titulo;
  final String url;

  LinkData({required this.titulo, required this.url});

  factory LinkData.fromJson(Map<String, dynamic> json) {
    return LinkData(
      titulo: json['titulo'],
      url: json['url'],
    );
  }
}

// Resultado completo
class ResultadoData {
  final String explicacao;
  final List<LinkData> links;

  ResultadoData({required this.explicacao, required this.links});

  factory ResultadoData.fromJson(Map<String, dynamic> json) {
    var linksList = json['links'] as List;
    List<LinkData> links = linksList.map((i) => LinkData.fromJson(i)).toList();

    return ResultadoData(
      explicacao: json['explicacao'],
      links: links,
    );
  }
}

// TELA DE RESULTADOS
class ResultsScreen extends StatefulWidget {
  final Map<String, int> scores;

  const ResultsScreen({super.key, required this.scores});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  // Estados para controlar o carregamento e os dados
  bool _isLoading = true;
  String? _error;
  Map<String, ResultadoData> _resultadosData = {};
  late List<MapEntry<String, int>> _sortedScores;

  @override
  void initState() {
    super.initState();
    _loadDataAndProcessScores();
  }

  // Carrega o JSON e processa as pontuações
  Future<void> _loadDataAndProcessScores() async {
    try {
      
      final String response = await rootBundle.loadString('assets/resultados.json');
      final Map<String, dynamic> data = json.decode(response);
      
      // Converte o Map
      final Map<String, ResultadoData> loadedData = data.map((key, value) {
        return MapEntry(key, ResultadoData.fromJson(value));
      });

      // Ordenar as pontuações
      final entries = widget.scores.entries.toList();
      entries.sort((a, b) => b.value.compareTo(a.value));

      setState(() {
        _resultadosData = loadedData;
        _sortedScores = entries;
        _isLoading = false;
      });

    } catch (e) {
      // Em caso de erro, atualiza o estado para exibir uma mensagem
      setState(() {
        _error = "Erro ao carregar os dados dos resultados. Tente novamente.";
        _isLoading = false;
      });
    }
  }
  
  // Caso o resultado seja indefinido (empate)
  Widget _buildIndefiniteResultUI(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Resultado Indefinido',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300)
          ),
          child: const Text(
            'Houve um empate entre três ou mais perfis. Isso indica que suas respostas não apontaram para um perfil predominante.\n\nSugerimos que você refaça o teste.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, height: 1.4),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => _navigateToHome(context),
          child: const Text('Refazer o Teste'),
        ),
      ],
    );
  }

  // Caso haja empate duplo
  Widget _buildTwoWayTieUI(BuildContext context) {
    final profile1 = _sortedScores[0];
    final profile2 = _sortedScores[1];

    final data1 = _resultadosData[profile1.key];
    final data2 = _resultadosData[profile2.key];

    return ListView( // Usando ListView para telas menores
      padding: const EdgeInsets.all(24.0),
      children: [
         const Text(
          'Você se identifica com dois perfis!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        const SizedBox(height: 10),
        const Text(
          'Suas respostas indicaram uma pontuação igual para os dois perfis abaixo. Leia as descrições e veja com qual você se identifica mais, ou refaça o teste.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),

        // Perfil 1
        if (data1 != null) _buildResultCard(context, profile1.key, data1),
        const SizedBox(height: 20),
        
        // Perfil 2
        if (data2 != null) _buildResultCard(context, profile2.key, data2),
        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: () => _navigateToHome(context),
          child: const Text('Refazer o Teste'),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade600),
          onPressed: () => _navigateToHome(context),
          child: const Text('Voltar para o Início'),
        ),
      ],
    );
  }

  // Constrói a interface para resultado único
  Widget _buildSingleResultUI(BuildContext context) {
    final highestProfile = _sortedScores[0];
    final data = _resultadosData[highestProfile.key];

    if (data == null) {
      return const Center(child: Text("Perfil não encontrado."));
    }

    return ListView( 
      padding: const EdgeInsets.all(24.0),
      children: [
         const Text(
          'Seu Resultado Final:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        const SizedBox(height: 20),
        _buildResultCard(context, highestProfile.key, data),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => _navigateToHome(context),
          child: const Text('Voltar para o Início'),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
               onPressed: () {
                  // Navega para a tela de avaliação
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EvaluationScreen()),
                  );
                },
          child: const Text('Avalie o Aplicativo'),
        ),
        const SizedBox(height: 15),
        TextButton(
          onPressed: () => SystemNavigator.pop(),
          child: const Text('Fechar App', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  // Widget para mostrar os detalhes de um perfil
  Widget _buildResultCard(BuildContext context, String profileName, ResultadoData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profileName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          const SizedBox(height: 10),
          Text(
            data.explicacao,
            style: const TextStyle(fontSize: 18, height: 1.4),
          ),
          if (data.links.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Profissões sugeridas:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            // Cria um botão para cada link
            ...data.links.map((link) => Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => UrlLauncherUtil.launchURL(context, link.url),
                child: Text(link.titulo, style: const TextStyle(fontSize: 16)),
              ),
            )).toList(),
          ]
        ],
      ),
    );
  }

  // Função para navegar de volta para o início
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _error != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 18)),
                  )
                : _buildContent(context),
      ),
    );
  }

  // Decide qual UI construir com base nas pontuações
  Widget _buildContent(BuildContext context) {
    // Caso 1: Empate entre os 3 primeiros ou mais
    if (_sortedScores.length >= 3 && 
        _sortedScores[0].value == _sortedScores[1].value && 
        _sortedScores[1].value == _sortedScores[2].value) {
      return _buildIndefiniteResultUI(context);
    }
    // Caso 2: Empate entre os 2 primeiros
    else if (_sortedScores.length >= 2 &&
             _sortedScores[0].value == _sortedScores[1].value) {
      return _buildTwoWayTieUI(context);
    }
    // Caso 3: Um perfil com maior pontuação
    else {
      return _buildSingleResultUI(context);
    }
  }
}