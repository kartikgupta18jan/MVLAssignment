# AirQualityBooking — MVL iOS Assignment

A SwiftUI app for selecting two air-quality-aware map locations (A → B) and booking a journey between them.

---

## Demo Video

 https://www.image2url.com/r2/default/videos/1780222594557-3f2df20e-7b3a-4360-8601-4c8d047d4e47.mp4 

### What the video demonstrates

| # | What to show |
|---|---|
| 1 | App launching on simulator |
| 2 | Map loads with live AQI — drag map to see number animate |
| 3 | Tap **V** → Set A (address appears in A chip) |
| 4 | Tap A chip → Screen 2, assign nickname "Home", tap V |
| 5 | Move map → Tap **V** → Set B |
| 6 | Tap **V** (Book) → Screen 3 shows A, B, nickname, price |
| 7 | Tap **V** → Screen 4 history list, scroll to hide header |
| 8 | Tap a history row → back to map with A/B pre-loaded, AQI refreshed |
| 9 | Repeat full flow once more to prove stability |
| 10 | Show `Config/Secrets.xcconfig` — token not hardcoded in Swift source |
| 11 | Briefly explain layers: Domain / Data / Presentation / DIContainer |


## Quick Start

### 1 — Requirements

| Tool | Version |
|------|---------|
| Xcode | 15.0+ |
| iOS Simulator | 17.0+ |

No additional tools needed — the `.xcodeproj` is included.

### 2 — Open the project

```bash
open AirQualityBooking.xcodeproj
```

Xcode resolves Alamofire via Swift Package Manager automatically on first build (~30 seconds, requires internet).

### 3 — Run

Select any **iPhone 17** simulator and press **⌘R**.

The app launches immediately in **live mode** using the configured AQICN token. If the token is removed or blank, the app auto-falls back to **fully-mocked mode** — every screen still works with dynamic, coordinate-dependent data.

---

## API Token

The AQICN token lives in `Config/Secrets.xcconfig` (git-ignored, never committed):

```
AQICN_API_TOKEN = <your_token>
```

It is injected via build setting → `Info.plist` → read at runtime in `AppConfiguration`. It does **not** appear anywhere in Swift source code.

To run without a token: leave `AQICN_API_TOKEN` blank — the app detects this and uses `MockServer` for all network calls.

---

## Architecture

### Clean Architecture — strict layer separation

```
App/                    ← Composition root only. Imports all layers.
│
Domain/                 ← Pure Swift. Zero external dependencies.
│   Entities/           ← Coordinate, PlaceSelection, Booking
│   RepositoryInterfaces/  ← Protocols only (AirQualityRepository, etc.)
│   UseCases/           ← Business logic. Calls repository protocols.
│
Data/                   ← Implements Domain interfaces.
│   Network/            ← APIClient protocol + AlamofireClient
│   Network/Mock/       ← MockURLProtocol + MockServer (all mock logic here)
│   DTOs/               ← JSON ↔ domain model mapping
│   Repositories/       ← Concrete implementations + LocationCache
│   Config/             ← AppConfiguration (reads token from Info.plist)
│
Presentation/           ← Depends on Domain only. Never imports Data.
    Common/             ← BookingSession, AppRouter, Theme, Components
    Map/                ← Screen 1: MapViewModel + MapView
    LocationDetail/     ← Screen 2: nickname editor
    BookingConfirmation/← Screen 3: POST /books result
    History/            ← Screen 4: GET /books list
    CachedLocations/    ← Screen 5: cached location picker
```

**Dependency rule:** arrows point inward only.
- `Domain` knows nothing about `Data` or `Presentation`
- `Presentation` depends on `Domain` interfaces, never on `Data` classes
- `App/DIContainer` is the only file that wires all layers together

### MVVM + Unidirectional Data Flow

Each screen follows:
```
View  →  ViewModel.send(Action)  →  mutates @Published State  →  View re-renders
```

Views never mutate state directly. All async work is dispatched through `send(_:)`.

### Dependency Injection

`DIContainer.swift` is the single composition root:
- Constructs transports (live Alamofire session vs MockURLProtocol session)
- Constructs repositories (injecting transport + config)
- Constructs use cases (injecting repository protocols)
- Exposes ViewModel factory methods (Presentation never constructs repositories)

Switching live ↔ fully-mocked is one line in `DIContainer`.

### Mock architecture

| What is mocked | Mechanism |
|---|---|
| `POST /books` | `MockURLProtocol` route in `MockServer` |
| `GET /books` | `MockURLProtocol` route in `MockServer` |
| AQI (mocked mode) | `MockURLProtocol` — AQI varies by coordinate |
| Geocoding (mocked mode) | `MockURLProtocol` — address varies by coordinate |

Repositories build **identical real URLRequests** in both modes. The mock intercepts at the transport layer — zero mock logic in any repository, use case, or ViewModel.

---

## Address Name Rule

From the assignment reference (BigDataCloud API):

```
administrative: [
  { order: 2, name: "South Korea" },
  { order: 3, name: "Seoul" },
  { order: 4, name: "Seocho District" },
  { order: 5, name: "Yangjae 2(i)-dong" }
]
```

**Result:** `"Seocho District, Yangjae 2(i)-dong"`

Implementation in `GeocodeDTO.swift`:
1. Sort `administrative` descending by `order`
2. Take the top two entries (orders 5 and 4)
3. Sort those two ascending (broader → specific)
4. Join with `", "`

---

## Coordinate Cache

Assignment rule: coordinates matching to **3 decimal places** are the same location.

- `37.5642, 127.0016` and `37.5645, 127.0018` → **same** (both → `"37.564,127.001"`)
- `37.5655, 127.2321` and `37.5624, 127.2328` → **different**

Implementation uses **truncation toward zero** (not rounding) in `Coordinate.cacheKey`.
`LocationCache` is a Swift `actor` for safe concurrent access.

---

## Screen Flow

```
Screen 1 (Map)
  ├─ Tap A/B chip (slot filled)  → Screen 2 (nickname editor)
  ├─ Tap A/B chip (slot empty)   → Screen 5 (cached location picker)
  ├─ V button "Set A"            → resolve + store slot A
  ├─ V button "Set B"            → resolve + store slot B
  └─ V button "Book"             → Screen 3 (booking confirmation)
                                     ├─ "View history" → Screen 4 (history)
                                     │      └─ tap record → Screen 1 (pre-loaded, V=Book, AQI refreshed)
                                     └─ back chevron → Screen 1 (state RESET)
```

---

## Running Tests

Press **⌘U** in Xcode, or from the terminal:

```bash
xcodebuild test \
  -project AirQualityBooking.xcodeproj \
  -scheme AirQualityBooking \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Test suites

| File | Covers |
|------|--------|
| `CoordinateCacheTests` | 3-decimal truncation, same/different location, actor cache |
| `GeocodeDTOTests` | Address name rule — assignment examples, edge cases |
| `AirQualityDTOTests` | Int / Double / string `"-"` AQI parsing, error status |
| `BookingSessionTests` | Action transitions, nickname, reset, AQI update, history load |
| `BookingRepositoryTests` | POST method+path, GET method+path+query params (SpyAPIClient) |
| `PlaceSelectionTests` | `displayName` nickname vs address fallback |
| `BookingAggregateTests` | `totalCount`, `totalPrice` on `[Booking]` |

---

## Dependencies

| Package | Version | Reason |
|---------|---------|--------|
| [Alamofire](https://github.com/Alamofire/Alamofire) | ≥ 5.9 | Required by assignment for all network calls |

MapKit is a system framework (no SPM entry needed).
The assignment permits MapKit when using SwiftUI — no Google Maps API key required.
