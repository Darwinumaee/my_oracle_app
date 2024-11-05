import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  final List<Map<String, String>> history;

  const HistoryPage({super.key, required this.history});

  @override
  // ignore: library_private_types_in_public_api
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _searchText = "";
  List<Map<String, String>> _filteredHistory = [];

  @override
  void initState() {
    super.initState();
    _filteredHistory = widget.history;
  }

  void _filterHistory(String query) {
    setState(() {
      _searchText = query.toLowerCase();
      _filteredHistory = widget.history.where((entry) {
        return entry['Pregunta']!.toLowerCase().contains(_searchText) ||
               entry['Respuesta']!.toLowerCase().contains(_searchText);
      }).toList();
    });
  }

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
              decoration: InputDecoration(
                labelText: "Buscar en el historial",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterHistory,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredHistory.length,
                itemBuilder: (context, index) {
                  final entry = _filteredHistory[index];
                  return ListTile(
                    title: Text(
                      "Pregunta: ${entry['Pregunta']}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    subtitle: Text(
                      "Respuesta: ${entry['Respuesta']}",
                      style: const TextStyle(color: Colors.white),
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
