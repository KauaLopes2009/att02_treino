import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Montador de Perfil de Treino',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TrainingProfilePage(),
    );
  }
}

class TrainingProfilePage extends StatefulWidget {
  const TrainingProfilePage({super.key});

  @override
  State<TrainingProfilePage> createState() => _TrainingProfilePageState();
}

class _TrainingProfilePageState extends State<TrainingProfilePage> {
  String? objetivo;
  String? nivel;

  final Set<String> restricoes = {};

  final List<String> alergias = [];

  final TextEditingController alergiaController = TextEditingController();

  double tempoTreino = 60;

  int? frequencia;

  bool notificacoesAgua = false;

  bool termosAceitos = false;

  @override
  void dispose() {
    alergiaController.dispose();
    super.dispose();
  }

  void adicionarAlergia() {
    final texto = alergiaController.text.trim();

    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite uma alergia antes de adicionar.')),
      );
      return;
    }

    final jaExiste = alergias.any(
      (alergia) => alergia.toLowerCase() == texto.toLowerCase(),
    );

    if (jaExiste) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Essa alergia já foi adicionada.')),
      );
      return;
    }

    setState(() {
      alergias.add(texto);
      alergiaController.clear();
    });
  }

  void removerAlergia(String alergia) {
    setState(() {
      alergias.remove(alergia);
    });
  }

  void gerarPlano() {
    final erros = <String>[];

    if (objetivo == null) {
      erros.add('Objetivo do treino não selecionado.');
    }

    if (nivel == null) {
      erros.add('Nível de experiência não informado.');
    }

    if (frequencia == null) {
      erros.add('Frequência semanal não selecionada.');
    }

    if (!termosAceitos) {
      erros.add('É necessário aceitar os termos e condições.');
    }

    if (erros.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erros.join('\n')),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Seu perfil de treino',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 24),

                resumoItem('Objetivo', objetivo!),

                resumoItem('Nível', nivel!),

                resumoItem(
                  'Restrições alimentares',
                  restricoes.isEmpty ? 'Nenhuma' : restricoes.join(', '),
                ),

                resumoItem(
                  'Alergias',
                  alergias.isEmpty ? 'Nenhuma' : alergias.join(', '),
                ),

                resumoItem('Tempo diário', '${tempoTreino.toInt()} minutos'),

                resumoItem('Frequência', '$frequencia dias por semana'),

                resumoItem(
                  'Notificações de água',
                  notificacoesAgua ? 'Ativadas' : 'Desativadas',
                ),

                resumoItem('Termos', 'Aceitos'),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget resumoItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            valor,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Montador de Perfil de Treino')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==========================================
            // OBJETIVO DO TREINO
            // ==========================================
            const Text(
              'Objetivo do treino',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            SegmentedButton<String>(
              emptySelectionAllowed: true,

              segments: const [
                ButtonSegment<String>(
                  value: 'Emagrecimento',
                  label: Text('Emagrecimento'),
                ),

                ButtonSegment<String>(
                  value: 'Hipertrofia',
                  label: Text('Hipertrofia'),
                ),

                ButtonSegment<String>(
                  value: 'Condicionamento',
                  label: Text('Condicionamento'),
                ),
              ],

              selected: objetivo == null ? <String>{} : <String>{objetivo!},

              onSelectionChanged: (Set<String> selecionado) {
                setState(() {
                  if (selecionado.isNotEmpty) {
                    objetivo = selecionado.first;
                  } else {
                    objetivo = null;
                  }
                });
              },
            ),

            const SizedBox(height: 28),

            // ==========================================
            // NÍVEL
            // ==========================================
            const Text(
              'Nível de experiência',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Iniciante'),
                  selected: nivel == 'Iniciante',
                  onSelected: (selecionado) {
                    setState(() {
                      nivel = selecionado ? 'Iniciante' : null;
                    });
                  },
                ),

                ChoiceChip(
                  label: const Text('Intermediário'),
                  selected: nivel == 'Intermediário',
                  onSelected: (selecionado) {
                    setState(() {
                      nivel = selecionado ? 'Intermediário' : null;
                    });
                  },
                ),

                ChoiceChip(
                  label: const Text('Avançado'),
                  selected: nivel == 'Avançado',
                  onSelected: (selecionado) {
                    setState(() {
                      nivel = selecionado ? 'Avançado' : null;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ==========================================
            // RESTRIÇÕES ALIMENTARES
            // ==========================================
            const Text(
              'Restrições alimentares',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Vegetariano'),
                  selected: restricoes.contains('Vegetariano'),
                  onSelected: (selecionado) {
                    setState(() {
                      if (selecionado) {
                        restricoes.add('Vegetariano');
                      } else {
                        restricoes.remove('Vegetariano');
                      }
                    });
                  },
                ),

                FilterChip(
                  label: const Text('Vegano'),
                  selected: restricoes.contains('Vegano'),
                  onSelected: (selecionado) {
                    setState(() {
                      if (selecionado) {
                        restricoes.add('Vegano');
                      } else {
                        restricoes.remove('Vegano');
                      }
                    });
                  },
                ),

                FilterChip(
                  label: const Text('Sem lactose'),
                  selected: restricoes.contains('Sem lactose'),
                  onSelected: (selecionado) {
                    setState(() {
                      if (selecionado) {
                        restricoes.add('Sem lactose');
                      } else {
                        restricoes.remove('Sem lactose');
                      }
                    });
                  },
                ),

                FilterChip(
                  label: const Text('Sem glúten'),
                  selected: restricoes.contains('Sem glúten'),
                  onSelected: (selecionado) {
                    setState(() {
                      if (selecionado) {
                        restricoes.add('Sem glúten');
                      } else {
                        restricoes.remove('Sem glúten');
                      }
                    });
                  },
                ),

                FilterChip(
                  label: const Text('Low Carb'),
                  selected: restricoes.contains('Low Carb'),
                  onSelected: (selecionado) {
                    setState(() {
                      if (selecionado) {
                        restricoes.add('Low Carb');
                      } else {
                        restricoes.remove('Low Carb');
                      }
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ==========================================
            // ALERGIAS
            // ==========================================
            const Text(
              'Alergias',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: alergiaController,
                    textInputAction: TextInputAction.done,

                    onSubmitted: (_) {
                      adicionarAlergia();
                    },

                    decoration: const InputDecoration(
                      labelText: 'Digite uma alergia',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                FilledButton(
                  onPressed: adicionarAlergia,
                  child: const Text('Adicionar'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (alergias.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: alergias.map((alergia) {
                  return InputChip(
                    label: Text(alergia),

                    onDeleted: () {
                      removerAlergia(alergia);
                    },
                  );
                }).toList(),
              ),

            const SizedBox(height: 28),

            // ==========================================
            // TEMPO DIÁRIO
            // ==========================================
            const Text(
              'Tempo diário de treino',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [Text('15 min'), Text('120 min')],
            ),

            Slider(
              min: 15,
              max: 120,
              divisions: 21,
              value: tempoTreino,
              label: '${tempoTreino.toInt()} min',

              onChanged: (valor) {
                setState(() {
                  tempoTreino = valor;
                });
              },
            ),

            Center(
              child: Text(
                'Tempo selecionado: '
                '${tempoTreino.toInt()} minutos',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // FREQUÊNCIA SEMANAL
            const Text(
              'Frequência semanal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            RadioListTile<int>(
              title: const Text('2 dias por semana'),
              value: 2,
              groupValue: frequencia,
              onChanged: (valor) {
                setState(() {
                  frequencia = valor;
                });
              },
            ),

            RadioListTile<int>(
              title: const Text('3 dias por semana'),
              value: 3,
              groupValue: frequencia,
              onChanged: (valor) {
                setState(() {
                  frequencia = valor;
                });
              },
            ),

            RadioListTile<int>(
              title: const Text('4 dias por semana'),
              value: 4,
              groupValue: frequencia,
              onChanged: (valor) {
                setState(() {
                  frequencia = valor;
                });
              },
            ),

            RadioListTile<int>(
              title: const Text('5 dias por semana'),
              value: 5,
              groupValue: frequencia,
              onChanged: (valor) {
                setState(() {
                  frequencia = valor;
                });
              },
            ),

            RadioListTile<int>(
              title: const Text('6 dias por semana'),
              value: 6,
              groupValue: frequencia,
              onChanged: (valor) {
                setState(() {
                  frequencia = valor;
                });
              },
            ),

            const SizedBox(height: 12),

            // NOTIFICAÇÕES DE ÁGUA

            SwitchListTile(
              contentPadding: EdgeInsets.zero,

              title: const Text('Receber notificações para beber água'),

              subtitle: Text(
                notificacoesAgua
                    ? 'Lembretes durante o dia: ON'
                    : 'Lembretes durante o dia: OFF',
              ),

              value: notificacoesAgua,

              onChanged: (valor) {
                setState(() {
                  notificacoesAgua = valor;
                });
              },
            ),

            const SizedBox(height: 12),


            // TERMOS

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,

              title: const Text(
                'Aceito os termos e condições para '
                'geração do plano de treino.',
              ),

              value: termosAceitos,

              onChanged: (valor) {
                setState(() {
                  termosAceitos = valor ?? false;
                });
              },
            ),

            const SizedBox(height: 20),


            // BOTÃO GERAR PLANO

            SizedBox(
              width: double.infinity,
              height: 52,

              child: FilledButton.icon(
                onPressed: gerarPlano,

                icon: const Icon(Icons.fitness_center),

                label: const Text(
                  'Gerar Plano',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
