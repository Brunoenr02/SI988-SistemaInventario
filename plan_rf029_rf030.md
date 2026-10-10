# Plan de Implementación: RF-029 y RF-030 (Solicitudes de Abastecimiento)

Este documento detalla el plan para construir el flujo de abastecimiento interno entre **Farmacia** y **Almacén** (HU-029 y HU-030), manteniendo el diseño estético de la aplicación y proponiendo ajustes necesarios a nivel de base de datos (Supabase).

---

## 1. Análisis de la Base de Datos Actual (`setup_sitra_luz.sql`)

He revisado el script SQL y cómo están estructurados los pedidos. Actualmente tienes dos tablas principales para movimientos:

1. **`dispensaciones` (Fichas):** Orientadas a despachos hacia pacientes o áreas (SOP, Emergencia). Incluyen `doctor_id`, `paciente_nombre`, etc.
2. **`pedidos_abastecimiento`:** Orientada al reabastecimiento interno de stock. Actualmente está definida así:
   ```sql
   CREATE TABLE public.pedidos_abastecimiento (
       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
       codigo TEXT UNIQUE NOT NULL, 
       solicitante_id UUID REFERENCES public.profiles(id),
       area_origen TEXT NOT NULL DEFAULT 'FARMACIA',
       area_destino TEXT NOT NULL DEFAULT 'ALMACEN',
       estado TEXT NOT NULL DEFAULT 'PENDIENTE', -- ('PENDIENTE', 'DESPACHADO', 'RECIBIDO', 'RECHAZADO')
       -- ...
   );
   ```

### 🔴 Problema Detectado (Lo que mencionaste sobre las áreas)
Tal como notaste, actualmente `area_origen` y `area_destino` en la tabla `pedidos_abastecimiento` son simples textos estáticos (`TEXT DEFAULT 'FARMACIA'`). **No están vinculados a tu tabla oficial de `areas`**. 

Si en el futuro (o ahora mismo) un área como "SOP" o "EMERGENCIA" quiere pedir abastecimiento de botiquín a "FARMACIA", o si tienes múltiples farmacias (Ej: Farmacia Piso 1, Farmacia Emergencia), el diseño actual te limitará.

### 🟢 Propuesta de Modificación SQL
Debemos alterar la base de datos para que los pedidos de abastecimiento sean dinámicos y dependan de la tabla `areas`.

```sql
-- Modificación propuesta a ejecutar en Supabase:
ALTER TABLE public.pedidos_abastecimiento 
  ADD CONSTRAINT fk_area_origen FOREIGN KEY (area_origen) REFERENCES public.areas(codigo),
  ADD CONSTRAINT fk_area_destino FOREIGN KEY (area_destino) REFERENCES public.areas(codigo);
```
Esto permitirá que el formulario en la app lea las áreas dinámicamente y el sistema sepa exactamente de qué inventario descontar y a cuál sumar al hacer la transferencia atómica.

---

## 2. Plan para RF-029: Registrar solicitud de abastecimiento (App - Farmacia)

**Objetivo:** El usuario de farmacia selecciona ítems y solicita reposición.
*   **UI/UX:** 
    *   Crear una vista `SolicitudAbastecimientoView`.
    *   Mantener el estilo "Glassmorphism" y colores vibrantes del dashboard.
    *   Un buscador superior interactivo para encontrar el medicamento del catálogo.
    *   Una lista tipo "carrito" donde se va agregando el medicamento y se usa un `Stepper` (botones +/-) para la cantidad solicitada.
*   **Lógica (`SolicitudAbastecimientoCubit`):**
    *   Al guardar, inserta en `pedidos_abastecimiento` (estado: `PENDIENTE`) y los detalles en `pedidos_abastecimiento_items`.
    *   El `area_origen` se tomará automáticamente del perfil del usuario (ej. su `areas_asignadas[0]`).
    *   El `area_destino` será seleccionable (por defecto 'ALMACEN').

---

## 3. Plan para RF-030: Atender solicitudes (App - Almacén)

**Objetivo:** Almacén visualiza la petición, ajusta si es necesario, y aprueba, transfiriendo el stock.
*   **UI/UX:**
    *   Crear una vista `AtenderSolicitudesDashboardView`.
    *   Lista de tarjetas elegantes mostrando las solicitudes pendientes (quién pide, hace cuánto tiempo).
    *   Al tocar una tarjeta, se abre un *BottomSheet* o diálogo expandido detallando los ítems pedidos vs el **Stock Actual** del almacén.
*   **Lógica (`AtenderSolicitudCubit`):**
    *   El operario de almacén puede confirmar la cantidad o reducirla (si falta stock).
    *   Al confirmar (`DESPACHADO`), se debe invocar una **función RPC (Stored Procedure)** en Supabase.
    *   *¿Por qué RPC?* Porque descontar de `inventario_stock` del ALMACÉN y sumar a FARMACIA requiere **Integridad Transaccional (RNF-003)**. No debe hacerse desde Flutter (para evitar que un error de red descuente de un lado y no sume en el otro).

---

## 4. Preguntas para alinear el desarrollo (¡Por favor responde estas dudas!)

1. **Sobre las Áreas:** ¿Estás de acuerdo con modificar la base de datos para que los pedidos soporten cualquier área solicitando a cualquier otra área (ej. SOP pidiendo a Farmacia), o esta tabla de pedidos será *estrictamente* de Farmacia pidiendo a Almacén?
2. **Sobre los Lotes (FEFO):** Cuando Almacén atiende la solicitud, ¿el operario de almacén debe elegir manualmente **qué Lote** específico está enviando a farmacia, o el sistema debe descontar automáticamente del lote más próximo a vencer (First Expired, First Out)?
3. **Sobre la Función Atómica:** ¿Tienes actualmente un Stored Procedure (RPC) en Supabase para transferir stock, o quieres que yo te genere el script SQL de esa función como primer paso?
