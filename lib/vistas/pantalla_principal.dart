import 'package:flutter/material.dart';
import '../viewmodels/principal_viewmodel.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});
  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  late final PrincipalViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = PrincipalViewModel();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EcoRuta')),
      body: Stack(
        children: [
          const Center(child: Text('Mapa aqui')),
          DraggableScrollableSheet(
            controller: viewModel.controladorPanel,
            initialChildSize: 0.3,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    GestureDetector(
                      onTap: viewModel.alternarPanel,
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      controller: viewModel.controladorBusqueda,
                      decoration: const InputDecoration(
                        labelText: 'Origen',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: viewModel.controladorDestino,
                      decoration: const InputDecoration(
                        labelText: 'Destino',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}