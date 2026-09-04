# Sprint Backlog — Sprint 1

## Sprint Goal

Al final del Sprint 1, un usuario podrá acceder de forma segura a SITRA-Luz
mediante registro e inicio de sesión, dejando preparada la base de acceso
para continuar con el flujo de solicitudes de medicamentos.

## Fechas

- Inicio: 04/09/2026
- Fin: 14/09/2026
- Sprint Review: 14/09/2026
- Sprint Retrospective: 14/09/2026

## Capacidad del Sprint

### Cálculo

3 Developers × 10 días hábiles × 3 horas por día = 90 horas

### Descuentos

- Eventos Scrum: aproximadamente 8 horas.
- Imprevistos: 15 %.
- Horas efectivas aproximadas: 70 horas.

Por no existir velocidad histórica, el equipo adopta un compromiso
conservador para el primer sprint.

## Historias seleccionadas

| ID | Historia | Puntos |
|---|---|---:|
| US-01 | Inicio de sesión | 5 |
| US-02 | Registro de usuario | 5 |

**Total comprometido: 10 puntos**

El compromiso se encuentra dentro del rango recomendado de 8 a 13 puntos
para el Sprint 1.

## Plan de entrega

### US-01 — Inicio de sesión

Tareas:

- Crear pantalla de registro.
- Validar campos obligatorios.
- Validar formato del correo.
- Implementar registro mediante el servicio correspondiente.
- Mostrar mensajes de éxito y error.
- Probar escenarios Gherkin.
- Realizar autoprueba en el emulador.

Responsable inicial: Integrante 1.

### US-02 — Registro de usuario

Tareas:

- Crear pantalla de inicio de sesión.
- Validar credenciales.
- Gestionar sesión del usuario.
- Mostrar mensajes de error.
- Probar escenarios Gherkin.
- Realizar autoprueba en el emulador.

Responsable inicial: Integrante 2.

### Tareas técnicas

- Revisar estructura actual del proyecto.
- Preparar rama de desarrollo del Sprint 1.
- Configurar entorno de pruebas.
- Verificar integración con el servicio.
- Registrar impedimentos en GitHub Projects.

Responsable inicial: Integrante 3.

## Riesgos del Sprint

| Riesgo | Impacto | Acción |
|---|---|---|
| Problemas de conexión con el servicio | Alto | Registrar impedimento y utilizar datos de prueba mientras se resuelve. |
| Errores en autenticación | Alto | Probar escenarios positivos y negativos antes de pasar a revisión. |
| Falta de tiempo | Medio | Mantener el compromiso en 10 puntos y respetar el WIP. |

## Acuerdo de la Daily

- Hora: 10:00 a. m.
- Canal: GitHub / comunicación del equipo.
- Duración máxima: 15 minutos.

Cada integrante responderá:

1. ¿Qué hice ayer?
2. ¿Qué haré hoy?
3. ¿Tengo algún impedimento?

Los impedimentos se registrarán en GitHub Projects.

## Prueba del Sprint Goal

El Sprint Goal fue definido antes de seleccionar las historias.

La eliminación de una historia no debe interpretarse como una simple suma
de funcionalidades; el equipo revisará que el objetivo siga siendo
alcanzable y que las historias seleccionadas contribuyan directamente al
objetivo del sprint.

## Definition of Done

Una historia podrá pasar a "Listo" cuando:

- Los criterios de aceptación estén verificados.
- El código compile correctamente.
- La funcionalidad haya sido probada en el emulador.
- La Pull Request haya sido revisada por otro integrante.
- CI se encuentre en estado correcto.
- No existan errores conocidos que impidan cumplir la historia.
