import 'package:flutter/material.dart';

void main() {
  runApp(const AplicativoEstacionamento());
}

class AplicativoEstacionamento extends StatelessWidget {
  const AplicativoEstacionamento({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estacionamento',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const TelaEstacionamento(),
    );
  }
}

class RegistroEstacionamento {
  const RegistroEstacionamento({
    required this.placa,
    required this.modelo,
    required this.vaga,
  });

  final String placa;
  final String modelo;
  final String vaga;
}

class TelaEstacionamento extends StatefulWidget {
  const TelaEstacionamento({super.key});

  @override
  State<TelaEstacionamento> createState() => _TelaEstacionamentoState();
}

class _TelaEstacionamentoState extends State<TelaEstacionamento> {
  final List<RegistroEstacionamento> _registros = [];

  Future<void> _abrirFormulario({int? indice}) async {
    final registroAtual = indice == null ? null : _registros[indice];
    final registroSalvo =
        await Navigator.of(context).push<RegistroEstacionamento>(
      MaterialPageRoute(
        builder: (contexto) => TelaFormularioEstacionamento(
          registro: registroAtual,
        ),
      ),
    );

    if (registroSalvo == null || !mounted) return;

    setState(() {
      if (indice == null) {
        _registros.add(registroSalvo);
      } else {
        _registros[indice] = registroSalvo;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          indice == null
              ? 'Veículo cadastrado com sucesso.'
              : 'Cadastro atualizado com sucesso.',
        ),
      ),
    );
  }

  void _excluirRegistro(int indice) {
    final placaExcluida = _registros[indice].placa;
    setState(() => _registros.removeAt(indice));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Veículo $placaExcluida removido da lista.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estacionamento'),
        centerTitle: true,
      ),
      body: _registros.isEmpty
          ? const _MensagemListaVazia()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _registros.length,
              separatorBuilder: (contexto, indice) =>
                  const SizedBox(height: 8),
              itemBuilder: (contexto, indice) {
                final registro = _registros[indice];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(registro.vaga.toUpperCase()),
                    ),
                    title: Text(
                      registro.placa,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Modelo: ${registro.modelo}\nVaga: ${registro.vaga}',
                    ),
                    isThreeLine: true,
                    onTap: () => _abrirFormulario(indice: indice),
                    trailing: IconButton(
                      tooltip: 'Excluir veículo',
                      onPressed: () => _excluirRegistro(indice),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Cadastrar veículo'),
      ),
    );
  }
}

class _MensagemListaVazia extends StatelessWidget {
  const _MensagemListaVazia();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_parking,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum veículo cadastrado',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Toque em “Cadastrar veículo” para adicionar o primeiro registro.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class TelaFormularioEstacionamento extends StatefulWidget {
  const TelaFormularioEstacionamento({super.key, this.registro});

  final RegistroEstacionamento? registro;

  @override
  State<TelaFormularioEstacionamento> createState() =>
      _TelaFormularioEstacionamentoState();
}

class _TelaFormularioEstacionamentoState
    extends State<TelaFormularioEstacionamento> {
  final _chaveFormulario = GlobalKey<FormState>();
  late final TextEditingController _controladorPlaca;
  late final TextEditingController _controladorModelo;
  late final TextEditingController _controladorVaga;

  bool get _estaEditando => widget.registro != null;

  @override
  void initState() {
    super.initState();
    _controladorPlaca =
        TextEditingController(text: widget.registro?.placa ?? '');
    _controladorModelo =
        TextEditingController(text: widget.registro?.modelo ?? '');
    _controladorVaga =
        TextEditingController(text: widget.registro?.vaga ?? '');
  }

  @override
  void dispose() {
    _controladorPlaca.dispose();
    _controladorModelo.dispose();
    _controladorVaga.dispose();
    super.dispose();
  }

  void _salvarRegistro() {
    if (!_chaveFormulario.currentState!.validate()) return;

    Navigator.of(context).pop(
      RegistroEstacionamento(
        placa: _controladorPlaca.text.trim().toUpperCase(),
        modelo: _controladorModelo.text.trim(),
        vaga: _controladorVaga.text.trim().toUpperCase(),
      ),
    );
  }

  String? _validarCampoObrigatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Preencha este campo.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_estaEditando ? 'Editar veículo' : 'Cadastrar veículo'),
      ),
      body: Form(
        key: _chaveFormulario,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _controladorPlaca,
              decoration: const InputDecoration(
                labelText: 'Placa',
                hintText: 'Ex.: XYZ2A34',
                prefixIcon: Icon(Icons.directions_car_outlined),
              ),
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              validator: _validarCampoObrigatorio,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controladorModelo,
              decoration: const InputDecoration(
                labelText: 'Modelo',
                hintText: 'Ex.: Onix',
                prefixIcon: Icon(Icons.commute_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: _validarCampoObrigatorio,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controladorVaga,
              decoration: const InputDecoration(
                labelText: 'Vaga',
                hintText: 'Ex.: B12',
                prefixIcon: Icon(Icons.local_parking),
              ),
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _salvarRegistro(),
              validator: _validarCampoObrigatorio,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _salvarRegistro,
              icon: const Icon(Icons.save_outlined),
              label: Text(_estaEditando ? 'Salvar alterações' : 'Salvar veículo'),
            ),
          ],
        ),
      ),
    );
  }
}
