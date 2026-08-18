# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A [ZMK](https://zmk.dev) firmware **user config** repo — it does not contain the ZMK firmware source itself. It is consumed as a `west` module (`config/west.yml` pins `zmkfirmware/zmk` at `revision: v0.3`) that layers custom boards, a custom display shield, and keymaps on top of stock ZMK. There is no local build toolchain; firmware is built exclusively by GitHub Actions.

Three wireless split keyboards are defined, each as a `left`/`right` sibling pair of custom ARM boards under `boards/arm/`:

| Board id | Directory | Encoder? |
|---|---|---|
| `corne_choc_pro` | `boards/arm/corne_choc_pro/` | yes |
| `piantor_pro_bt` | `boards/arm/piantor_pro_bt/` | no |
| `sofle_choc_pro` | `boards/arm/sofle_choc_pro/` | yes |

Plus one custom shield: `boards/shields/nice_view_disp/` — a variant of the nice!view display with a custom-drawn status widget (C code, LVGL-free raw drawing via `art.c`, `bolt.c`, `status.c`, `peripheral_status.c`, `util.c`).

## My hardware

I own a **Sofle Choc Pro**. Unless I say otherwise, only edit `config/sofle_choc_pro.keymap` (and its `.conf`/`.json`) — leave `corne_choc_pro` and `piantor_pro_bt` alone.

My physical build uses **`nice_view`** displays and has **no rotary encoders**, even though `boards/arm/sofle_choc_pro/sofle_choc_pro.zmk.yml` lists `encoder` as a board feature and `config/sofle_choc_pro.keymap` still has `sensor-bindings` entries — that metadata/keymap reflects the board's hardware *capability*, not my actual build. Don't assume encoder bindings do anything on my keyboard, and don't add encoder-dependent features expecting them to work without confirming first.

## My configuration philosophy

Goal: get the keymap right once, deliberately, rather than repeatedly redoing it. Some relearning is fine, but too many changes at once risks frustration and giving up.  I will keep using the MacBook keyboard alongside this one — so changes need to stay learnable and not clash too badly with it.

Process:
- Iterate in small, narrowly-scoped changes — one concrete problem or missing function per change (a symbol that's unreachable/awkward, easily confused keys, missing navigation/media control, etc.), not sweeping redesigns.
- Leave enough time between changes to actually absorb one before making the next.
- Started from the Sofle's stock keymap (close to US-ANSI) as the baseline and change incrementally from there.
- Prioritize completeness and logical placement first ("can I reach every symbol and remember where it lives?"); optimize ergonomics/efficiency only after that's solid.
- Track changes in Git with clearly named commits/changelog; keep a README describing the current layout plus a diagram.

Preferences, in priority order:
- Characters/commands used frequently when programming and writing prose in English and German are most important.
- Prefer bindings that feel consistent with the MacBook keyboard, or are otherwise easy to remember.
- Lean toward [Miryoku](https://github.com/manna-harbour/miryoku/) layout principles ([reference manual](https://github.com/manna-harbour/miryoku/tree/master/docs/reference)) where practical:
  - Favor the home row and inner thumb keys.
  - Use layers instead of reaching — writing stays on the inner 5×3 keys; outer keys are for other functions.
  - Use both hands to avoid contortions; assign (and possibly duplicate) modifiers so every key is reachable with every modifier combo without contortion.
  - Keep Mac and Windows behavior as consistent as possible with each other.

## Build

There is no local build — firmware is compiled by GitHub Actions on every push/PR via ZMK's reusable workflow:

```yaml
# .github/workflows/build.yml
uses: zmkfirmware/zmk/.github/workflows/build-user-config.yml@v0.3
```

`build.yaml` at the repo root drives the build matrix (one entry per board+shield combination). Each keyboard has **three** build variants:
1. `<board>_left`/`<board>_right` + `nice_view`/`nice_view_disp` shield — the normal daily firmware, built with `-DCONFIG_ZMK_STUDIO=y` on the left (central) half only.
2. `<board>_left`/`<board>_right` + `settings_reset` shield — a utility firmware to wipe paired-bond/settings storage.
3. All builds add `snippet: studio-rpc-usb-uart` to enable ZMK Studio over USB.

To add a new board/shield combination, edit `build.yaml`; to test a change, push/open a PR and let CI build it (there's no faster local iteration loop).

If you need to validate `.dtsi`/`.overlay`/`.keymap` syntax before pushing, use the [ZMK web-based keymap editor / GitHub Actions logs](https://zmk.dev) — do not attempt to invoke `west build` locally unless a full Zephyr/ZMK toolchain is already set up outside this repo.

## Architecture

### Per-keyboard file set (repeated 3x, one per board)

For each board `<name>` there are two parallel locations that must stay in sync:

- **`boards/arm/<name>/`** — the ZMK board definition consumed by the build: devicetree (`<name>.dtsi`, `<name>_left.dts`, `<name>_right.dts`, `<name>-layouts.dtsi`), Kconfig (`Kconfig`, `Kconfig.board`, `Kconfig.defconfig`), `board.cmake`, `<name>.yaml` (hardware metadata), `<name>.zmk.yml` (ZMK hardware-metadata file used by zmk.studio / keymap editor — declares `features`, `outputs`, `siblings`), and a **fallback keymap** `<name>.keymap`.
- **`config/`** — the *actual* keymap/config used for builds: `<name>.keymap` (the real bindings), `<name>.conf` (Kconfig overrides, e.g. `CONFIG_ZMK_SLEEP`, `CONFIG_ZMK_KEYBOARD_NAME`), `<name>.json` (physical key layout / sensor metadata consumed by the keymap editor and `zmk,physical-layout`).

**The `config/*.keymap` files are authoritative** — that's what `west build` actually compiles for this repo (board root is `.`, per `zephyr/module.yml`). The `boards/arm/<name>/<name>.keymap` files are near-duplicates kept for board-level defaults/completeness; when changing keybindings, edit `config/<name>.keymap`.

### Keymap layer conventions — inconsistent across boards, know this before editing

- `corne_choc_pro` and `piantor_pro_bt` keymaps use a **shared, modern layout**: layers named `default_layer` (QWERTY) → `lower_layer` (NUMBER, `mo 1`) → `raise_layer` (SYMBOL, `mo 2`) → six empty `extra_layer_N` placeholders. Media keys, RGB, Bluetooth profile switching (`bt BT_SEL 0-4`, `bt BT_CLR`), `sys_reset`, `bootloader`, and `studio_unlock` live on `lower_layer`.
- `sofle_choc_pro` still uses an **older 4-layer scheme**, but with mnemonic layer names: `alpha_layer` (QWERTY) → `sym_layer` (numbers/symbols/F-keys) → `nav_layer` (arrows/nav/BT) → `sys_layer` (RGB/power/reset), with a `conditional_layers` node that auto-activates `sys_layer` when both SYM and NAV are held. It also uses `ext_power` (not present on the other two boards).
- If you're asked to bring feature parity to `sofle_choc_pro` or unify layouts, note the layer *names differ* (`sys_layer` has no equivalent on the other two boards) and the physical matrix differs (sofle is a 6-column layout, corne/piantor are similar but corne includes thumb-cluster arcs — see each `.json`'s `layout` coordinates).
- Encoders: `corne_choc_pro` and `sofle_choc_pro` define `sensor-bindings` (volume/page/track scroll via `inc_dec_kp`) only on layers where they're set; `piantor_pro_bt` has no encoder and no `sensor-bindings`.

### `nice_view_disp` shield

Custom fork of the stock nice!view display shield (`boards/shields/nice_view_disp/`). Key points if editing:
- `nice_view_disp.overlay` binds a Sharp `ls0xx` 160x68 LCD as `zephyr,display`.
- `CMakeLists.txt` conditionally compiles different widget sources depending on split role: the **central** half builds `widgets/status.c`; **peripheral** halves build `widgets/art.c` + `widgets/peripheral_status.c`. `widgets/bolt.c` and `widgets/util.c` are shared.
- Behavior toggles are documented in `boards/shields/nice_view_disp/README.md`: `CONFIG_ZMK_DISPLAY_STATUS_SCREEN_BUILT_IN=y` reverts to the stock ZMK status screen; `CONFIG_NICE_VIEW_DISP_ROTATE_180=y` flips the display — both set in a board's `config/<name>.conf`.

### Physical layouts (`config/*.json`)

Each JSON defines one or more named physical layouts (key `x`/`y`/rotation coordinates consumed by the ZMK Studio keymap editor) plus `sensors` metadata for rotary encoders. The `.keymap`'s `chosen { zmk,physical-layout = &default_layout; }` selects which layout node (from the matching `-layouts.dtsi`) is active — keep the `.json` layout and the devicetree layout node in sync when changing physical key count/position.

## Conventions when editing keymaps

- Match existing ASCII-art comment banners above each layer's `bindings` block — they document the physical key grid and are the primary way to review a layout change without loading it into a simulator.
- `&trans` fills unused positions on layers that pass through to the layer below; `&none` (used only in sofle's `sys_layer`) means "do nothing," not "pass through" — don't mix them up when porting bindings between boards.
- ZMK Studio integration (`studio_unlock`, the `studio-rpc-usb-uart` snippet, `CONFIG_ZMK_STUDIO=y`) is enabled repo-wide; don't remove `studio_unlock` bindings without checking `build.yaml` still needs the snippet.
