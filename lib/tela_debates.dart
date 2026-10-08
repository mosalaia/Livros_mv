import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaDebates extends StatefulWidget {
  final String livroId;
  final String tituloLivro;

  const TelaDebates({
    super.key,
    required this.livroId,
    required this.tituloLivro,
  });

  @override
  State<TelaDebates> createState() => _TelaDebatesState();
}

class _TelaDebatesState extends State<TelaDebates> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _comentarioCtrl = TextEditingController();
  final TextEditingController _capituloComentarioCtrl = TextEditingController();
  int _capituloLidoUsuario = 1;

  @override
  void initState() {
    super.initState();
    _carregarCapituloLido();
  }

  Future<void> _carregarCapituloLido() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _capituloLidoUsuario = prefs.getInt('capitulo_${widget.livroId}') ?? 1;
    });
  }

  Future<void> _salvarCapituloLido(int novoCapitulo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('capitulo_${widget.livroId}', novoCapitulo);
    setState(() {
      _capituloLidoUsuario = novoCapitulo;
    });
  }

  Future<void> _enviarComentario() async {
    if (_comentarioCtrl.text.isEmpty || _capituloComentarioCtrl.text.isEmpty) {
      return;
    }
    int capComentario = int.parse(_capituloComentarioCtrl.text);

    // Inserção na Subcoleção Incorporada: livros/{livroId}/debates_capitulo
    await _firestore
        .collection('livros')
        .doc(widget.livroId)
        .collection('debates_capitulo')
        .add({
      'texto': _comentarioCtrl.text,
      'numeroCapitulo': capComentario,
      'usuarioEmail': FirebaseAuth.instance.currentUser?.email ?? 'Anônimo',
      'criadoEm': FieldValue.serverTimestamp(),
    });

    _comentarioCtrl.clear();
    _capituloComentarioCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Debates: ${widget.tituloLivro}')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.deepPurple.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Capítulo onde você está: $_capituloLidoUsuario',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        TextEditingController capCtrl = TextEditingController(
                          text: _capituloLidoUsuario.toString(),
                        );
                        return AlertDialog(
                          title: const Text('Atualizar seu Progresso'),
                          content: TextField(
                            controller: capCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Li até o capítulo:',
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                _salvarCapituloLido(
                                  int.parse(capCtrl.text),
                                );
                                Navigator.pop(ctx);
                              },
                              child: const Text('Salvar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            // Consulta Filtro 2 (Anti-Spoiler): Subcoleção filtrada por número de capítulo
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('livros')
                  .doc(widget.livroId)
                  .collection('debates_capitulo')
                  .where('numeroCapitulo', isLessThanOrEqualTo: _capituloLidoUsuario)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var comentarios = snapshot.data!.docs;
                if (comentarios.isEmpty) {
                  return const Center(
                    child: Text('Nenhum comentário liberado para seu progresso.'),
                  );
                }
                return ListView.builder(
                  itemCount: comentarios.length,
                  itemBuilder: (context, index) {
                    var com = comentarios[index];
                    return ListTile(
                      title: Text(com['texto']),
                      subtitle: Text(
                        'Cap. ${com['numeroCapitulo']} - Autor: ${com['usuarioEmail']}',
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _capituloComentarioCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cap.'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _comentarioCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Escreva um comentário...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _enviarComentario,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}