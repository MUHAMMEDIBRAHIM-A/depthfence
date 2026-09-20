# Architecture Decision Record (ADR) — DepthFence

## ADR 001: Clean Architecture with Provider State Management

### Context
DepthFence requires a predictable, testable, and highly responsive architecture for handling complex geospatial data, real-time map interactions, astro-math height calculations, and multi-format report exports.

### Decision
Adopt a feature-first, layered architecture (Core, Domain, Data, Presentation) powered by `Provider` (`ChangeNotifier`).

### Consequences
- **Pros**:
  - Clear separation of business logic (`SurveyGeometryService`) from UI rendering.
  - Testable domain models (`LandParcelModel`, `AnomalyModel`) with 100% test coverage.
  - Predictable state flows across the entire application lifecycle.
- **Cons**:
  - Requires maintaining dedicated model mappers between raw API JSON responses and domain models.

---

## ADR 002: Offline-First Data & Synchronization Strategy

### Context
Field surveyors operating in remote Indian land parcels often experience intermittent or zero cellular connectivity.

### Decision
Implement an offline-first repository pattern backed by local `SharedPreferences` persistence and a `PendingSyncOperation` queue.

### Consequences
- **Pros**:
  - Full app functionality offline (drawing boundaries, shadow height math, CAD blueprint preview, PNG export).
  - Background synchronization when network connectivity is restored.
- **Cons**:
  - Requires managing conflict resolution when updating modified records on Supabase.

---

## ADR 003: Direct Gemini REST API Integration with Multi-Model Fallback

### Context
The deprecated `google_generative_ai` Flutter package had version constraints and model availability shifts across Google AI Studio.

### Decision
Call Google's Generative Language REST API directly using `http.post` and the `x-goog-api-key` header, implementing automatic multi-model fallback (`gemini-3.6-flash`, `gemini-3.5-flash`, `gemini-2.5-flash`, `gemini-2.0-flash`, `gemini-1.5-flash`).

### Consequences
- **Pros**:
  - Zero dependency on third-party Gemini wrappers.
  - Automatic resilience against 404 model deprecations.
  - Supports both `AIzaSy...` and `AQ...` key formats smoothly.

---

## ADR 004: Client-Side Vector & Bitmap Exporters (DXF, PDF, RepaintBoundary PNG)

### Context
Surveyors need immediate access to printable CAD files (.dxf) and official certificates (.pdf / .png) in the field without relying on cloud processing servers.

### Decision
Implement all exporters on-device:
1. **ASCII DXF R12 Exporter**: Writes native `.dxf` vector files with LWPOLYLINE boundaries, corner POINTs, and TEXT labels.
2. **RepaintBoundary 300 DPI PNG Exporter**: Uses `boundary.toImage(pixelRatio: 3.0)` to generate high-resolution image report cards.

### Consequences
- **Pros**:
  - 100% offline report and CAD file generation.
  - Zero server infrastructure or bandwidth costs.
- **Cons**:
  - Uses ~30–40 MB peak RAM during high-resolution 300 DPI PNG canvas capture.
