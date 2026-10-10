import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/pedido_abastecimiento_entity.dart';
import '../states/almacen_state.dart';
import '../viewmodels/almacen_viewmodel.dart';
import 'dialogs/transferir_a_farmacia_dialog.dart';

/// Pantalla dedicada a la visualización y atención de solicitudes de abastecimiento
/// enviadas por la guardia de Farmacia Central hacia Almacén General (Flujo nuevo).
class SolicitudesAbastecimientoView extends StatefulWidget {
  const SolicitudesAbastecimientoView({super.key});

  @override
  State<SolicitudesAbastecimientoView> createState() =>
      _SolicitudesAbastecimientoViewState();
}

class _SolicitudesAbastecimientoViewState
    extends State<SolicitudesAbastecimientoView> {
  String _filtroEstado = 'PENDIENTES'; // 'PENDIENTES', 'EN CURSO', 'COMPLETADOS'

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AlmacenViewModel>();
    final state = vm.state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Solicitudes de Abastecimiento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Peticiones de reposición inter-áreas', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: AppColors.almacenColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: state is AlmacenLoaded
          ? _buildBody(context, state, vm.isSaving)
          : const Center(child: CircularProgressIndicator(color: AppColors.almacenColor)),
    );
  }

  Widget _buildBody(BuildContext context, AlmacenLoaded loaded, bool isSaving) {
    final solicitudes = loaded.solicitudes;

    final filtradas = solicitudes.where((s) {
      if (_filtroEstado == 'PENDIENTES') return s.esPendiente;
      if (_filtroEstado == 'EN CURSO') return s.esEnPreparacion || (s.esListo && !s.confirmadoAlmacen);
      if (_filtroEstado == 'COMPLETADOS') return s.esCompletado || (s.esListo && s.confirmadoAlmacen);
      return true;
    }).toList();

    return RefreshIndicator(
      color: AppColors.almacenColor,
      onRefresh: () => context.read<AlmacenViewModel>().cargarInventario(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Selector de Filtros
          Row(
            children: [
              _buildFilterChip('PENDIENTES', 'Nuevos', Colors.redAccent),
              const SizedBox(width: 8),
              _buildFilterChip('EN CURSO', 'En Curso', Colors.orange),
              const SizedBox(width: 8),
              _buildFilterChip('COMPLETADOS', 'Finalizados', AppColors.success),
            ],
          ),

          const SizedBox(height: 16),

          // 2. Lista de Solicitudes
          if (filtradas.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'No hay solicitudes en esta categoría',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtradas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filtradas[index];
                return _buildSolicitudCard(context, item, loaded, isSaving);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String valor, String etiqueta, Color color) {
    final activo = _filtroEstado == valor;
    return ChoiceChip(
      label: Text(etiqueta),
      selected: activo,
      selectedColor: color.withOpacity(0.18),
      labelStyle: TextStyle(
        color: activo ? color : AppColors.textSecondary,
        fontWeight: activo ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) => setState(() => _filtroEstado = valor),
    );
  }

  Widget _buildSolicitudCard(
    BuildContext context,
    PedidoAbastecimientoEntity item,
    AlmacenLoaded loaded,
    bool isSaving,
  ) {
    final esPendiente = item.esPendiente;
    final esEnPreparacion = item.esEnPreparacion;
    final esListo = item.esListo;
    final esCompletado = item.esCompletado;
    
    Color estadoColor = AppColors.textSecondary;
    IconData estadoIcon = Icons.info_outline;

    if (esPendiente) {
      estadoColor = Colors.redAccent;
      estadoIcon = Icons.new_releases_rounded;
    } else if (esEnPreparacion) {
      estadoColor = Colors.orange;
      estadoIcon = Icons.inventory_2_rounded;
    } else if (esListo) {
      estadoColor = Colors.blue;
      estadoIcon = Icons.local_shipping_rounded;
    } else if (esCompletado) {
      estadoColor = AppColors.success;
      estadoIcon = Icons.check_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: esPendiente ? Colors.redAccent.withOpacity(0.3) : AppColors.surfaceVariant,
          width: esPendiente ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera: Código, Estado y Modalidad
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.codigo,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'Turno: ${item.turno} | Motivo: ${item.justificacion == "STOCK_CERO" ? "Stock Cero" : "Relleno"}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: estadoColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(estadoIcon, size: 14, color: estadoColor),
                    const SizedBox(width: 4),
                    Text(
                      item.estado.replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: estadoColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Solicitante y fecha
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.solicitanteNombre,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
              Text(
                '${item.fechaSolicitud.day.toString().padLeft(2, '0')}/${item.fechaSolicitud.month.toString().padLeft(2, '0')} ${item.fechaSolicitud.hour.toString().padLeft(2, '0')}:${item.fechaSolicitud.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),

          if (item.modalidadEntrega != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(item.modalidadEntrega == 'ENTREGA' ? Icons.hail_rounded : Icons.directions_walk_rounded, size: 16, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  'Modalidad definida: ${item.modalidadEntrega}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Lista de ítems solicitados
          const Text(
            'Medicamentos Solicitados:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),

          ...item.items.map((it) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.medication_outlined, size: 16, color: AppColors.almacenColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${it.nombreMedicamento} ${it.formaFarmaceutica ?? ""}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${it.cantidadSolicitada} unid.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 14),

          // Botones de Acción según el estado
          if (esPendiente)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: isSaving ? null : () => _cambiarEstadoPedido(item.id, 'EN_PREPARACION'),
                icon: isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.back_hand_rounded, size: 18),
                label: const Text('Tomar Pedido'),
              ),
            )
          else if (esEnPreparacion)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: isSaving ? null : () => _mostrarDialogoModalidad(item),
                icon: isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.done_all_rounded, size: 18),
                label: const Text('Alistado & Marcar Listo'),
              ),
            )
          else if (esListo && !item.confirmadoAlmacen)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: isSaving ? null : () => _marcarRealizado(item.id),
                icon: isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(item.modalidadEntrega == 'ENTREGA' ? 'Marcar como Entregado' : 'Marcar como Entregado (Recojo)'),
              ),
            )
          else if (esListo && item.confirmadoAlmacen && !item.confirmadoFarmacia)
            const Row(
              children: [
                Icon(Icons.hourglass_top_rounded, color: Colors.orange, size: 16),
                SizedBox(width: 6),
                Text(
                  'Esperando confirmación de Farmacia',
                  style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ],
            )
          else if (esCompletado)
             Row(
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.success, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Completado bilateralmente el ${item.fechaCompletado?.day}/${item.fechaCompletado?.month} a las ${item.fechaCompletado?.hour}:${item.fechaCompletado?.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _cambiarEstadoPedido(String pedidoId, String nuevoEstado) async {
    // Aquí invocaríamos el ViewModel para actualizar el estado en BD
    // context.read<AlmacenViewModel>().cambiarEstadoPedido(pedidoId, nuevoEstado);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cambiando estado a $nuevoEstado... (Mock)')),
    );
  }

  void _marcarRealizado(String pedidoId) async {
    // context.read<AlmacenViewModel>().marcarPedidoRealizado(pedidoId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marcado como entregado/realizado por Almacén.')),
    );
  }

  void _mostrarDialogoModalidad(PedidoAbastecimientoEntity item) {
    String modalidadSeleccionada = 'RECOJO';
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Pedido Alistado'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Cómo se entregará este pedido a Farmacia?',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                RadioListTile(
                  title: const Text('Farmacia vendrá a Recogerlo'),
                  value: 'RECOJO',
                  groupValue: modalidadSeleccionada,
                  onChanged: (val) => setStateModal(() => modalidadSeleccionada = val.toString()),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile(
                  title: const Text('Almacén lo Entregará allá'),
                  value: 'ENTREGA',
                  groupValue: modalidadSeleccionada,
                  onChanged: (val) => setStateModal(() => modalidadSeleccionada = val.toString()),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // Invocar ViewModel para marcar como LISTO y setear modalidad
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Marcado como LISTO. Modalidad: $modalidadSeleccionada')),
                  );
                },
                child: const Text('Confirmar & Notificar'),
              ),
            ],
          );
        }
      ),
    );
  }
}
