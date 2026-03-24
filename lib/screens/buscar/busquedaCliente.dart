import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rebooty_repair/models/Cliente.dart';
import '../../DataBaseHelper.dart';

class PantallaBusquedaCliente extends StatefulWidget {
  const PantallaBusquedaCliente({super.key});

  @override
  State<PantallaBusquedaCliente> createState() => _PantallaBusquedaClienteState();
}

class _PantallaBusquedaClienteState extends State<PantallaBusquedaCliente> {
  late TextEditingController _dniController;

  List<Cliente> listaClientes = [];

  Future<void> cargarClientes() async {
    final clientes = await DatabaseHelper.instance.obtenerClientes();
    setState(() {
      listaClientes = clientes;
    });
  }

  @override
  void initState() {
    super.initState();
    _dniController = TextEditingController();
    cargarClientes();
  }

  @override
  void dispose() {
    _dniController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listado de clientes"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.chevron_left_outlined),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dniController,
                    decoration: InputDecoration(
                      labelText: "Documento",
                      prefixIcon: const Icon(Icons.badge),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('Buscar'),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Expanded(
              child: Builder(
                builder: (context) {
                  final filtro = _dniController.text.toLowerCase();
                  final clientesFiltrados = listaClientes.where((cliente) {
                    // Usamos documento_oficial que es el nombre en la nueva tabla
                    final doc = cliente.documentoOficial.toString().toLowerCase() ?? '';
                    return doc.contains(filtro);
                  }).toList();

                  return ListView.separated(
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: clientesFiltrados.length,
                    itemBuilder: (context, index) {
                      final cliente = clientesFiltrados[index];
                      return ListTile(
                        // a la izquierda mostramos la foto del cleinte o un icono si no ha elegido
                        leading: (cliente.rutaFoto == null || cliente.rutaFoto!.isEmpty)
                            ? const Icon(Icons.person)
                            : Image.file(File(cliente.rutaFoto!)),
                        title: Text(cliente.nombre),
                        subtitle: Text("${cliente.tipoDocumento}: ${cliente.documentoOficial}"),
                        onTap: () async {
                          await Navigator.pushNamed(context, "detalles_cliente", arguments: cliente);
                          setState(() {});
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                    "¿Estás seguro de que quieres borrar este campo de la base de datos?",
                                  ),

                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          if (cliente.id != null) {
                                            await Navigator.pushNamed(context, "detalles_cliente", arguments: cliente.id!);
                                          }
                                          setState(() {});
                                          Navigator.pop(context);
                                        },
                                        label: const Row(children: [Icon(Icons.check), Text("Confirmar")]),
                                      ),

                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        label: const Row(children: [Icon(Icons.cancel_outlined), Text("Cancelar")]),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
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
