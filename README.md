# GSView — DLL de Previsualización de Informes para Clarion

**Autor:** Gustavo Saracca  
**Año:** 2024  
**Plataforma:** Clarion (CW12+), Windows

---

## ¿Qué hace?

`gsview.dll` es una DLL reutilizable para Clarion que provee una ventana de previsualización de informes multipágina basada en archivos WMF (Windows Metafile). Expone una única función de alto nivel (`ITPreViewer`) que recibe una cola de archivos de imagen —uno por página del informe— y presenta al usuario una interfaz completa con:

- Navegación entre páginas (primero / anterior / siguiente / último, PgUp/PgDn)
- Zoom configurable (acercar, alejar, ajustar al ancho, ajustar al alto, 100%)
- Panel lateral de lista de páginas (toggle on/off)
- Búsqueda de texto dentro del contenido de las páginas
- Selección de páginas para imprimir (toggle por página o por búsqueda)
- Impresión: página actual o todas las páginas marcadas
- Selector de impresora
- Exportación a PDF, TXT, HTML, XML, PNG y XLS (requiere `ReportTargetSelectorClass`)

---

## Estructura del proyecto

```
GSView/
├── gsview.app           — Aplicación Clarion (fuente del generador)
├── gsview.clw           — Módulo principal: inicialización de la DLL, globals
├── gsview001.clw        — Procedimiento ITPreViewer + todas las clases internas
├── GSVIEW_BC.CLW        — Módulo de diccionario (DctInit / DctKill)
├── libsrc/
│   ├── TPRE_TYPES.CLW   — Definición de TQ_Pages (cola de páginas)
│   ├── TPRN_TYPES.CLW   — Definición de TQ_PRINTERS y equates de impresoras
│   ├── ZoomModule.clw   — Clase TZoomClass
│   ├── ZoomModule.inc   — Interfaz de TZoomClass y TQ_ZoomSteps
│   ├── TPrinter.clw     — Clase TPrinterClass
│   ├── TPrinter.inc     — Interfaz de TPrinterClass
│   ├── TWaitClass.clw   — Clase TWaitClass (diálogo de espera)
│   ├── TWaitClass.inc   — Interfaz de TWaitClass
│   ├── PercentModule.clw — Clase TPercentClass (barra de progreso de búsqueda)
│   └── PercentModule.inc
└── images/              — Íconos de la barra de herramientas (.ico)
```

---

## Integración en una aplicación Clarion

### 1. Declarar la DLL en el MAP

En el MAP de tu programa o DLL llamadora incluye:

```clarion
MAP
  MODULE('gsview.dll')
    gsview:Init  PROCEDURE(<ErrorClass curGlobalErrors>, <INIClass curINIMgr>), DLL
    gsview:Kill  PROCEDURE, DLL
    ITPreViewer  FUNCTION(*Queue pImageQueue, Short pZoom, Byte pMaximize, |
                          String pWindowCaption, Byte pStartPageList, |
                          <*ReportTargetSelectorClass pTargetSelector>), BYTE, DLL
  END
END
```

> El archivo `GSVIEW001.INC` generado por el compilador no exporta el prototipo completo de `ITPreViewer`; es necesario declararlo manualmente como se muestra arriba.

### 2. Inicializar y terminar la DLL

Llama a `gsview:Init` al arrancar tu aplicación (una sola vez) y a `gsview:Kill` antes de cerrarla:

```clarion
! Al inicio de la aplicación
gsview:Init(GlobalErrors, INIMgr)

! Al finalizar la aplicación
gsview:Kill()
```

Ambas funciones son idempotentes (protegidas con flags `STATIC`): llamadas múltiples no producen efectos secundarios.

### 3. Definir la cola de imágenes

Declara en tu procedimiento una cola compatible con `TQ_Pages`:

```clarion
  INCLUDE('TPRE_TYPES.CLW'), ONCE   ! define TQ_Pages

  MyImageQueue  TQ_Pages
```

O bien declara tu propia queue con al menos el campo `WmfFile` en la misma posición y tipo —la DLL accede al primer campo de tipo cstring(1000) como nombre de archivo.

> **Nota:** La forma más segura es usar `TQ_Pages` directamente o derivar una queue `LIKE(TQ_Pages)`.

### 4. Poblar la cola y llamar al previewer

Cada entrada de la cola corresponde a una página del informe, almacenada como un archivo WMF en disco:

```clarion
! Asumiendo que el informe ya generó los archivos WMF en disco:
CLEAR(MyImageQueue)
MyImageQueue = 'C:\Temp\Pagina001.wmf'  ! el campo WmfFile es el primero
ADD(MyImageQueue)
MyImageQueue = 'C:\Temp\Pagina002.wmf'
ADD(MyImageQueue)

! Llamar al previewer
Result = ITPreViewer( |
    MyImageQueue,          |  ! Cola de páginas (WMF)
    100,                   |  ! Zoom inicial (100 = 100%)
    TRUE,                  |  ! Maximizar ventana al abrir
    'Vista Previa - Factura', |  ! Título de la ventana
    TRUE,                  |  ! Mostrar panel de lista de páginas
    MyTargetSelector       |  ! Opcional: para exportar a PDF/HTML/etc.
)
```

`ITPreViewer` devuelve `TRUE` si el usuario eligió imprimir, `FALSE` si canceló.

---

## Parámetros de ITPreViewer

| Parámetro | Tipo | Descripción |
|---|---|---|
| `pImageQueue` | `*Queue` | Cola con los paths WMF de cada página. Se pasa por referencia. |
| `pZoom` | `Short` | Porcentaje de zoom inicial. `0` aplica el zoom "ajustar al ancho". |
| `pMaximize` | `Byte` | `TRUE` abre la ventana maximizada. |
| `pWindowCaption` | `String` | Texto en la barra de título. Si está vacío, se usa "GSoft - Previewer". |
| `pStartPageList` | `Byte` | `TRUE` muestra el panel lateral de páginas al abrir. |
| `pTargetSelector` | `*ReportTargetSelectorClass` | Opcional. Habilita los botones de exportación. Ver sección siguiente. |

---

## Exportación (PDF, HTML, TXT, XML, PNG, XLS)

Los botones de "Guardar como" se activan únicamente si se pasa un `ReportTargetSelectorClass` válido con los generadores cargados. La DLL consulta `pTargetSelector.Items()` e itera con `GetOutputGeneratorName(i)` para determinar qué formatos están disponibles.

Si no se necesita exportación, se puede omitir el parámetro (es opcional).

El `ReportTargetSelectorClass` es parte del framework ClaRun/ABC estándar de Clarion.

---

## Funcionamiento interno

### Ciclo de vida de los archivos WMF

Al inicializar la ventana la DLL realiza los siguientes pasos sobre los archivos de la cola:

1. **RenameMetaFiles:** copia cada archivo `original.ext` a `ITP_original.ext.wmf` y registra el par (original → nuevo) en una queue interna (`TQ_NewName`).
2. Durante la visualización e impresión trabaja exclusivamente con los archivos renombrados (`.wmf`).
3. Antes de imprimir llama a **RestoreMetaFiles:** copia de vuelta `nuevo → original` para que el driver de impresión pueda abrir los archivos con el path registrado en el REPORT.
4. Al cerrar la ventana llama a **RemoveMetaFiles:** elimina todos los archivos `ITP_*.wmf` creados en el paso 1.

> Este mecanismo garantiza que el proceso de impresión encuentra los archivos con el nombre exacto embebido en el informe Clarion, independientemente del formato original.

### Renderizado de páginas

La DLL usa un control `IMAGE` de Clarion (`PROP:Text`) para mostrar cada página. Al cambiar de página simplemente actualiza el path del control y llama a `SetPosition` para escalar la imagen según el zoom actual y el área disponible de la ventana.

### Búsqueda de texto

La búsqueda lee cada archivo WMF como texto plano en bloques de 4096 bytes (driver `DOS`). Esto funciona porque los archivos WMF generados por Clarion incluyen el texto del informe embebido como cadenas legibles. La búsqueda es case-insensitive.

**Prefijo `+` en la búsqueda:** anteponer `+` al término acumula resultados sobre la búsqueda anterior (las páginas ya marcadas no se desmarcan).

### Manejo del zoom

La clase `TZoomClass` mantiene una queue de pasos predefinidos (`TQ_ZoomSteps`) que popula el combo de zoom. Los cálculos de "ajustar al ancho" y "ajustar al alto" usan las dimensiones reales de la imagen (vía `PROP:Width`/`PROP:Height` sobre un `CREATE:Image` temporal) y el tamaño del área cliente de la ventana.

### Impresión

La impresión se realiza abriendo un `REPORT` en tiempo de ejecución con las dimensiones exactas de la primera imagen. Itera sobre la `PageQueue` e imprime solo las páginas con `PrintPage = TRUE`, usando un `DETAIL` con un `IMAGE` para cada una.

---

## Dependencias en tiempo de ejecución

| Archivo | Descripción |
|---|---|
| `gsview.dll` | Esta DLL |
| `clarunext.dll` | Runtime extendido de Clarion (debe estar en el path) |
| `ACCESS.DLL` | DLL de acceso a datos del sistema OSG (`\SOURCE\OSG\ACCESS\`) |
| `cfg.ini` | Archivo de configuración INI (se crea automáticamente en el directorio de trabajo) |

---

## Notas para el desarrollador

- La DLL usa `INIClass` con el archivo `cfg.ini` en modo `NVD_INI` (Windows INI). Si la aplicación llamadora ya tiene un `INIMgr` global, pásalo en `gsview:Init` para compartir la misma instancia.
- La variable global `SilentRunning` (`BYTE`) permite suprimir diálogos cuando la aplicación corre en modo batch; establécela en `TRUE` desde fuera de la DLL si es necesario.
- El evento personalizado `GS_EVENT:Sized` (`EQUATE(501h)`) se usa internamente para recalcular el layout al redimensionar la ventana; no interferirá con eventos de la aplicación llamadora salvo que esta también use el valor `0x501`.
- La búsqueda requiere un mínimo de 2 caracteres para ejecutarse.
