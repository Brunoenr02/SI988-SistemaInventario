import '../../domain/entities/lote_entity.dart';

/// Modelo de datos para Lote (mapeo con PostgreSQL / Supabase)
class LoteModel extends LoteEntity {
  const LoteModel({
    required super.id,
    required super.medicamentoId,
    required super.numeroLote,
    super.fechaFabricacion,
    required super.fechaVencimiento,
    super.laboratorio,
    super.proveedor,
    super.precioCompra,
    super.precioVenta,
    super.numBoleta,
    super.justificacion,
    super.temperaturaRecepcion,
    super.observaciones,
    super.activo,
  });

  factory LoteModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic dateVal) {
      if (dateVal == null) return DateTime.now();
      if (dateVal is DateTime) return dateVal;
      return DateTime.tryParse(dateVal.toString()) ?? DateTime.now();
    }

    return LoteModel(
      id: map['id']?.toString() ?? '',
      medicamentoId: map['medicamento_id']?.toString() ?? '',
      numeroLote: map['numero_lote']?.toString() ?? '',
      fechaFabricacion: map['fecha_fabricacion'] != null ? parseDate(map['fecha_fabricacion']) : null,
      fechaVencimiento: parseDate(map['fecha_vencimiento']),
      laboratorio: map['laboratorio']?.toString(),
      proveedor: map['proveedor']?.toString(),
      precioCompra: map['precio_compra'] != null ? double.tryParse(map['precio_compra'].toString()) : null,
      precioVenta: map['precio_venta'] != null ? double.tryParse(map['precio_venta'].toString()) : null,
      numBoleta: map['num_boleta']?.toString(),
      justificacion: map['justificacion']?.toString(),
      temperaturaRecepcion: (map['temperatura_recepcion'] as num?)?.toDouble(),
      observaciones: map['observaciones']?.toString(),
      activo: map['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicamento_id': medicamentoId,
      'numero_lote': numeroLote.trim(),
      if (fechaFabricacion != null)
        'fecha_fabricacion': fechaFabricacion!.toIso8601String().split('T').first,
      'fecha_vencimiento': fechaVencimiento.toIso8601String().split('T').first,
      if (laboratorio != null && laboratorio!.isNotEmpty) 'laboratorio': laboratorio!.trim(),
      if (proveedor != null && proveedor!.isNotEmpty)
        'proveedor': proveedor!.trim(),
      if (precioCompra != null) 'precio_compra': precioCompra,
      if (precioVenta != null) 'precio_venta': precioVenta,
      if (numBoleta != null && numBoleta!.isNotEmpty) 'num_boleta': numBoleta!.trim(),
      if (justificacion != null && justificacion!.isNotEmpty) 'justificacion': justificacion!.trim(),
      if (temperaturaRecepcion != null)
        'temperatura_recepcion': temperaturaRecepcion,
      if (observaciones != null && observaciones!.isNotEmpty)
        'observaciones': observaciones!.trim(),
      'activo': activo,
    };
  }
}
