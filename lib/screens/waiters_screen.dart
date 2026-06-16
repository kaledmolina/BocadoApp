import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/waiters_provider.dart';
import '../widgets/custom_drawer.dart';

class WaitersScreen extends StatefulWidget {
  const WaitersScreen({super.key});

  @override
  State<WaitersScreen> createState() => _WaitersScreenState();
}

class _WaitersScreenState extends State<WaitersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WaitersProvider>().fetchWaitersData();
    });
  }

  void _showAddWaiterModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Añadir Mesero', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rellena todos los campos')));
                return;
              }
              final success = await context.read<WaitersProvider>().createWaiter(
                nameCtrl.text, emailCtrl.text, passCtrl.text
              );
              if (mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Mesero añadido' : 'Error al añadir')),
                );
              }
            },
            child: const Text('Crear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WaitersProvider>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        drawer: const CustomDrawer(currentRoute: 'waiters'),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: const Text(
            'Gestión de Meseros',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5),
          ),
          bottom: const TabBar(
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.orange,
            tabs: [
              Tab(text: 'Activos'),
              Tab(text: 'Solicitudes'),
              Tab(text: 'Talentos'),
            ],
          ),
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
            : TabBarView(
                children: [
                  _buildWaitersList(provider),
                  _buildApplicationsList(provider),
                  _buildTalentsList(provider),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          onPressed: () => _showAddWaiterModal(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildWaitersList(WaitersProvider provider) {
    if (provider.waiters.isEmpty) {
      return const Center(child: Text('No tienes meseros activos', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.waiters.length,
      itemBuilder: (ctx, i) {
        final waiter = provider.waiters[i];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: Text(waiter.name.substring(0, 2).toUpperCase(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ),
            title: Text(waiter.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(waiter.email, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                    const SizedBox(width: 4),
                    Text('${waiter.averageRating} (${waiter.experienceHours}h)', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                if (waiter.isShiftActive)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                    child: const Text('En Turno', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: waiter.isActive,
                  activeColor: Colors.orange,
                  onChanged: (val) {
                    provider.toggleWaiterStatus(waiter.id);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    provider.deleteWaiter(waiter.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApplicationsList(WaitersProvider provider) {
    if (provider.applications.isEmpty) {
      return Column(
        children: [
          if (provider.invitationLink.isNotEmpty) _buildInviteLinkCard(provider.invitationLink),
          const Expanded(child: Center(child: Text('No hay solicitudes pendientes', style: TextStyle(color: Colors.grey)))),
        ],
      );
    }
    return Column(
      children: [
        if (provider.invitationLink.isNotEmpty) _buildInviteLinkCard(provider.invitationLink),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.applications.length,
            itemBuilder: (ctx, i) {
              final app = provider.applications[i];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: Text(app.user.name.substring(0, 2).toUpperCase(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(app.user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(app.user.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                              onPressed: () => provider.processApplication(app.id, 'rejected'),
                              child: const Text('Rechazar'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                              onPressed: () => provider.processApplication(app.id, 'approved'),
                              child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInviteLinkCard(String link) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enlace de Invitación', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 4),
          const Text('Comparte este enlace para invitar meseros:', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(link, style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20, color: Colors.orange),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: link));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copiado al portapapeles')));
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTalentsList(WaitersProvider provider) {
    if (provider.availableWaiters.isEmpty) {
      return const Center(child: Text('No hay meseros disponibles en la bolsa de talentos', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.availableWaiters.length,
      itemBuilder: (ctx, i) {
        final talent = provider.availableWaiters[i];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(talent.name.substring(0, 2).toUpperCase(), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(talent.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(talent.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                              const SizedBox(width: 4),
                              Text('${talent.averageRating} (${talent.experienceHours}h)', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (talent.status == 'invited')
                      const Text('Invitado', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12))
                    else if (talent.status == 'pending')
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () => provider.hireWaiter(talent.id),
                        child: const Text('Aceptar', style: TextStyle(color: Colors.white, fontSize: 12)),
                      )
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        onPressed: () => provider.hireWaiter(talent.id),
                        child: const Text('Contratar', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
