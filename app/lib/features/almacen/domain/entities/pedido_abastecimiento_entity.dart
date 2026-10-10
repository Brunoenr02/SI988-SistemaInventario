/// Entidad pura de Dominio que representa un ítem solicitado en un pedido de abastecimiento
class PedidoAbastecimientoItemEntity {
  final String id;
  final String pedidoId;
  final String medicamentoId;
  final String nombreMedicamento;
  final String? formaFarmaceutica;
  final int cantidadSolicitada;
  final int cantidadDespachada;
  final String? loteId;

  const PedidoAbastecimientoItemEntity({
    required this.id,
    required this.pedidoId,
    required this.medicamentoId,
    required this.nombreMedicamento,
    this.formaFarmaceutica = '',
    required this.cantidadSolicitada,
    this.cantidadDespachada = 0,
    this.loteId,
  });
}

/// Entidad pura de Dominio que representa una solicitud de abastecimiento (Flujo inter-áreas)
class PedidoAbastecimientoEntity {
  final String id;
  final String codigo;
  
  final String? solicitanteId;
  final String solicitanteNombre;
  
  final String? responsableAlmacenId;
  final String? responsableFarmaciaId;

  final String areaOrigen;
  final String areaDestino;
  
  final String estado; // 'PENDIENTE', 'EN_PREPARACION', 'LISTO', 'COMPLETADO', 'RECHAZADO'
  
  final String turno; // 'DIA', 'TARDE', 'NOCHE'
  final String justificacion; // 'STOCK_CERO', 'RELLENAR_STOCK'
  final String? modalidadEntrega; // 'ENTREGA', 'RECOJO'
  
  final bool confirmadoAlmacen;
  final bool confirmadoFarmacia;

  final String? notas;
  final String? notasAlmacen;
  final String? motivoRechazo;

  final DateTime fechaSolicitud;
  final DateTime? fechaToma;
  final DateTime? fechaListo;
  final DateTime? fechaDespacho;
  final DateTime? fechaConfirmacionAlmacen;
  final DateTime? fechaConfirmacionFarmacia;
  final DateTime? fechaCompletado;

  final List<PedidoAbastecimientoItemEntity> items;

  const PedidoAbastecimientoEntity({
    required this.id,
    required this.codigo,
    this.solicitanteId,
    this.solicitanteNombre = 'Guardia de Farmacia',
    this.responsableAlmacenId,
    this.responsableFarmaciaId,
    this.areaOrigen = 'FARMACIA',
    this.areaDestino = 'ALMACEN',
    this.estado = 'PENDIENTE',
    this.turno = 'DIA',
    this.justificacion = 'RELLENAR_STOCK',
    this.modalidadEntrega,
    this.confirmadoAlmacen = false,
    this.confirmadoFarmacia = false,
    this.notas,
    this.notasAlmacen,
    this.motivoRechazo,
    required this.fechaSolicitud,
    this.fechaToma,
    this.fechaListo,
    this.fechaDespacho,
    this.fechaConfirmacionAlmacen,
    this.fechaConfirmacionFarmacia,
    this.fechaCompletado,
    this.items = const [],
  });

  bool get esPendiente => estado == 'PENDIENTE';
  bool get esEnPreparacion => estado == 'EN_PREPARACION';
  bool get esListo => estado == 'LISTO';
  bool get esCompletado => estado == 'COMPLETADO';
  bool get esRechazado => estado == 'RECHAZADO';

  /// Total de unidades solicitadas en la orden
  int get totalUnidadesSolicitadas =>
      items.fold(0, (sum, i) => sum + i.cantidadSolicitada);
}
