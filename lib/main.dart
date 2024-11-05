import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oráculo Virtual',
      debugShowCheckedModeBanner: false, // Oculta la etiqueta "Debug"
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: OraclePage(),
    );
  }
}

class OraclePage extends StatefulWidget {
  const OraclePage({super.key});

  @override
  OraclePageState createState() => OraclePageState();
}

class OraclePageState extends State<OraclePage> with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  String _userQuestion = "";
  String _response = "";
  bool _isListening = false;
  final List<Map<String, String>> _history = []; // Historial de preguntas y respuestas
  late AnimationController _controller;
  late Animation<double> _animation;

  final Map<String, String> _responses = {
    "que me depara el destino": "Tu destino tiene sorpresas inesperadas; mantén la mente abierta y el corazón dispuesto a recibir lo que venga.",
    "tendre suerte en el amor": "Veo en el horizonte un romance apasionado que se aproxima.",
    "voy a tener exito en mi carrera": "El éxito te está esperando, pero deberás trabajar duro para alcanzarlo.",
    "debo tomar esa decision importante": "La decisión es tuya, pero el oráculo sugiere que confíes en tu intuición.",
    "voy a tener buena salud": "La energía positiva rodea tu salud, pero no olvides cuidarte y ser constante.",
    "que debo hacer hoy": "Hoy es un buen día para cuidar de ti mismo y relajarte.",
    "cual es mi destino": "Tu destino está lleno de aventuras y grandes logros.",
    "mis decisiones son correctas": "Las decisiones que tomas hoy construirán tu mañana. Confía en ti mismo y sigue aprendiendo de cada paso."
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();

    // Initialize animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  void _startVoiceRecognition() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _userQuestion = "";
        _response = "";
      });
      HapticFeedback.lightImpact();
      _speech.listen(
        onResult: (result) {
          setState(() {
            _userQuestion = result.recognizedWords;
          });
          if (result.finalResult) {
            _generateResponse();
          }
        },
        localeId: "es_ES",
      );
    }
  }

  String _normalizeText(String text) {
    return text.toLowerCase().replaceAllMapped(RegExp(r'[áéíóúÁÉÍÓÚ]'), (match) {
      switch (match.group(0)) {
        case 'á':
          return 'a';
        case 'é':
          return 'e';
        case 'í':
          return 'i';
        case 'ó':
          return 'o';
        case 'ú':
          return 'u';
        default:
          return match.group(0)!;
      }
    });
  }

  void _generateResponse() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      String normalizedQuestion = _normalizeText(_userQuestion);
      _response = _responses[normalizedQuestion] ?? "El oráculo no tiene una respuesta para esa pregunta. Intenta preguntar algo diferente.";
      _history.add({"Pregunta": _userQuestion, "Respuesta": _response});
    });
    _speak(_response);
    HapticFeedback.heavyImpact();
    _controller.forward(from: 0);
  }

  void _speak(String text) async {
    await _tts.setLanguage("es-ES");
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  void _openHistoryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage(history: _history),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Consulta al Oráculo"),
        backgroundColor: const Color.fromARGB(255, 32, 104, 213),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _openHistoryPage,
          ),
        ],
      ),
      body: Container(
        width: double.infinity, // Asegura que tome todo el ancho disponible
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, const Color.fromARGB(255, 122, 105, 179)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                "¡Haz tu pregunta!",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Image.asset(
                'assets/robot-removebg-preview.png',
                height: 150,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 8,
                ),
                icon: const Icon(Icons.mic, color: Colors.black),
                label: const Text(
                  "Hablar",
                  style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                onPressed: _isListening ? null : _startVoiceRecognition,
              ),
              const SizedBox(height: 20),
              if (_userQuestion.isNotEmpty)
                FadeTransition(
                  opacity: _animation,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Pregunta: $_userQuestion",
                      style: const TextStyle(color: Colors.white70, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              if (_response.isNotEmpty)
                FadeTransition(
                  opacity: _animation,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent[700],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Oráculo: $_response",
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class HistoryPage extends StatelessWidget {
  final List<Map<String, String>> history;

  const HistoryPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Consultas"),
        backgroundColor: const Color.fromARGB(255, 32, 104, 213),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: "Buscar en el historial...",
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search, color: Colors.white54),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (query) {
                // Aquí puedes agregar la lógica de filtrado.
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final entry = history[index];
                  return ListTile(
                    title: Text(
                      entry["Pregunta"] ?? "",
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      entry["Respuesta"] ?? "",
                      style: const TextStyle(color: Colors.white54),
                    ),
                    tileColor: Colors.blueGrey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
