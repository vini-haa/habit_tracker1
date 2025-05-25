import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/habit.dart'; // Importa o modelo Habit
import 'package:frontend/utils/string_extensions.dart'; // Adicione esta linha

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  late Future<List<Habit>>
  futureHabits; // Futuro que conterá a lista de hábitos

  @override
  void initState() {
    super.initState();
    futureHabits =
        fetchHabits(); // Inicia a busca pelos hábitos quando a tela é criada
  }

  Future<List<Habit>> fetchHabits() async {
    final String apiUrl =
        'http://10.0.2.2:5000/habits'; // A mesma URL do backend
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Se o servidor retornar um status OK (200),
        // parseie o JSON e mapeie para uma lista de objetos Habit.
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Habit.fromJson(json)).toList();
      } else {
        // Se o servidor retornar uma resposta de erro,
        // lance uma exceção.
        throw Exception('Falha ao carregar hábitos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha ao conectar com o backend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Hábitos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                futureHabits = fetchHabits(); // Recarrega a lista de hábitos
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Habit>>(
        future: futureHabits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Enquanto espera, mostra um indicador de progresso
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Se ocorrer um erro, mostra uma mensagem
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Se não houver dados, mostra uma mensagem de "nenhum hábito"
            return const Center(child: Text('Nenhum hábito cadastrado ainda.'));
          } else {
            // Se houver dados, exibe a lista de hábitos
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Habit habit = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (habit.description != null &&
                            habit.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(habit.description!),
                          ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Método de Contagem: ${habit.countMethod.capitalize()}',
                        ),
                        Text(
                          'Método de Completude: ${habit.completionMethod.capitalize()}',
                        ),
                        if (habit.targetQuantity != null)
                          Text(
                            'Alvo: ${habit.targetQuantity} ${habit.completionMethod == 'minutes' ? 'min' : 'x'}',
                          ),
                        if (habit.targetDaysPerWeek != null)
                          Text(
                            'Dias na Semana/Mês: ${habit.targetDaysPerWeek}',
                          ),
                        Text(
                          'Criado em: ${habit.createdAt.split(' ')[0]}',
                        ), // Mostra apenas a data
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
