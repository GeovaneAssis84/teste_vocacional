import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({super.key});

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

// Enum para as opções de rádio
enum CoherenceOption { sim, nao }

class _EvaluationScreenState extends State<EvaluationScreen> {
  // Chave para validar o formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar o texto dos campos
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _opinionController = TextEditingController();
  final _suggestionController = TextEditingController();

  // Variável para guardar o estado do botão de rádio
  CoherenceOption? _coherenceOption;

  bool _isLoading = false;

  @override
  void dispose() {
    // Limpar os controladores ao sair da tela para liberar memória
    _nameController.dispose();
    _ageController.dispose();
    _opinionController.dispose();
    _suggestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Avaliação do Aplicativo"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextFormField(
                controller: _nameController,
                label: "1. Nome Completo",
                validatorMessage: "Por favor, insira seu nome.",
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _ageController,
                label: "2. Idade",
                keyboardType: TextInputType.number,
                validatorMessage: "Por favor, insira sua idade.",
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _opinionController,
                label: "3. O que você achou do nosso aplicativo?",
                maxLines: 4,
                validatorMessage: "Por favor, deixe sua opinião.",
              ),
              const SizedBox(height: 24),
              const Text("4. O resultado foi coerente?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              _buildRadioOptions(),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _suggestionController,
                label: "5. Deixe uma sugestão ou reclamação (Opcional)",
                maxLines: 4,
                isOptional: true, // Campo opcional
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _generateAndSharePdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Gerar e Enviar PDF"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para os campos de texto
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? validatorMessage,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (!isOptional && (value == null || value.isEmpty)) {
          return validatorMessage;
        }
        return null;
      },
    );
  }

  // Widget auxiliar para os botões de rádio
  Widget _buildRadioOptions() {
    return Column(
      children: [
        RadioListTile<CoherenceOption>(
          title: const Text("Sim"),
          value: CoherenceOption.sim,
          groupValue: _coherenceOption,
          onChanged: (value) => setState(() => _coherenceOption = value),
        ),
        RadioListTile<CoherenceOption>(
          title: const Text("Não"),
          value: CoherenceOption.nao,
          groupValue: _coherenceOption,
          onChanged: (value) => setState(() => _coherenceOption = value),
        ),
      ],
    );
  }

  Future<void> _generateAndSharePdf() async {
    // Validar o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_coherenceOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, selecione se o resultado foi coerente.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 1. Criar o documento PDF
    final pdf = pw.Document();

    // 2. Adicionar uma página e conteúdo
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text("Relatório de Avaliação do Aplicativo", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 20),
          _buildPdfRow("Nome:", _nameController.text),
          _buildPdfRow("Idade:", _ageController.text),
          pw.SizedBox(height: 20),
          _buildPdfQuestion("O que você achou do nosso aplicativo?", _opinionController.text),
          _buildPdfQuestion("O resultado foi coerente?", _coherenceOption == CoherenceOption.sim ? "Sim" : "Não"),
          _buildPdfQuestion("Sugestão ou reclamação:", _suggestionController.text.isNotEmpty ? _suggestionController.text : "Nenhuma."),
        ],
      ),
    );

    try {
      // 3. Salvar o PDF em um diretório temporário
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/avaliacao_app.pdf");
      await file.writeAsBytes(await pdf.save());

      // 4. Compartilhar o arquivo
      await Share.shareXFiles(
        [XFile(file.path)],
        text: "Olá, aqui está minha avaliação sobre o aplicativo.",
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao gerar ou compartilhar o PDF: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Widgets auxiliares para o conteúdo do PDF
  pw.Widget _buildPdfRow(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.SizedBox(width: 10),
          pw.Text(value, style: const pw.TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfQuestion(String question, String answer) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(question, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.SizedBox(height: 5),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Text(answer, style: const pw.TextStyle(fontSize: 12)),
          )
        ],
      ),
    );
  }
}





