import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tela_debates.dart';
import 'tela_login.dart';

class TelaLivros extends StatefulWidget {
  const TelaLivros({super.key});

  @override
  State<TelaLivros> createState() => _TelaLivrosState();
}

class _TelaLivrosState extends State<TelaLivros> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filtroGenero = 'Todos';

  Future<void> _cadastrarLivroExemplo() async {
    await _firestore.collection('livros').add({
      'titulo': 'O Iluminado',
      'autor': 'Stephen King',
      'genero': 'Terror',
      'totalCapitulos': 50,
    });
  }

  Future<void> _deslogar() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TelaLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Consulta Filtro 1: Filtrar livros por gênero
    Query query = _firestore.collection('livros');
    if (_filtroGenero != 'Todos') {
      query = query.where('genero', isEqualTo: _filtroGenero);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Livros em Debate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _deslogar,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: _filtroGenero == 'Todos',
                  onSelected: (_) => setState(() => _filtroGenero = 'Todos'),
                ),
                FilterChip(
                  label: const Text('Terror'),
                  selected: _filtroGenero == 'Terror',
                  onSelected: (_) => setState(() => _filtroGenero = 'Terror'),
                ),
                FilterChip(
                  label: const Text('Ficção'),
                  selected: _filtroGenero == 'Ficção',
                  onSelected: (_) => setState(() => _filtroGenero = 'Ficção'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var livro = docs[index];
                    return ListTile(
                      title: Text(livro['titulo']),
                      subtitle: Text(
                        '${livro['autor']} - Gênero: ${livro['genero']}',
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TelaDebates(
                              livroId: livro.id,
                              tituloLivro: livro['titulo'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cadastrarLivroExemplo,
        tooltip: 'Cadastrar Livro de Exemplo',
        child: const Icon(Icons.add),
      ),
    );
  }
}