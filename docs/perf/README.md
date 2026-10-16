# Scroll performance (welcome page)

Measured with `scripts/profile-welcome-scroll.mjs`: Playwright **iPhone 13** emulation, **4× CPU throttle**, ~4s scroll via `mouse.wheel` while sampling `requestAnimationFrame` deltas on a **release** web build (`ENABLE_SEMANTICS=true` for automation).

| Label | Median frame | p95 frame | Est. FPS | >16.7ms frames |
|-------|-------------|-----------|----------|----------------|
| **before** (main @ PR start) | 98.0 ms | 131.7 ms | ~10.2 | 65% |
| **after** (layout + scroll fixes) | 66.6 ms | 77.6 ms | ~15.0 | 57% |
| **after + `--wasm`** (skwasm build) | 49.7 ms | 71.6 ms | ~20.1 | 56% |

Changes in the **after** build:

- Fixed gradient behind scroll content (no full-screen repaint on scroll)
- Removed large blurred `BoxShadow` on the app icon; light border instead
- `Image.asset` `cacheWidth` / `cacheHeight` for the welcome icon
- `RepaintBoundary` on hero, feature tiles, folder/card list rows
- Shared `appScrollPhysics` (`ClampingScrollPhysics` on web)

Default production build remains **CanvasKit** unless `flutter build web --wasm` is enabled (Firebase workflow can opt into wasm for additional mobile gains).
