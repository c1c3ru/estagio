import 'package:flutter/material.dart';

class SupervisorProfilePage extends StatelessWidget {
  const SupervisorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Supervisor'),
      ),
      body: const Center(
        child: Text('Página de Perfil do Supervisor'),
      ),
    );
  }
}
