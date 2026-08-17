# zmk-config

ZMK firmware config for a **Sofle Choc Pro**. See [`CLAUDE.md`](CLAUDE.md) for the full repo architecture, build setup, and my hardware notes (nice!view displays, no rotary encoders). This file just describes the current keymap.

## Layout at a glance

Four layers, defined in [`config/sofle_choc_pro.keymap`](config/sofle_choc_pro.keymap). `LOWER` and `RAISE` are reachable from either hand's thumb cluster via layer-tap keys; holding both together auto-activates `ADJUST`.

- **default (QWERTY)** — standard US-ANSI-ish letters/numbers, close to a stock keyboard so it stays easy to switch back and forth with the MacBook keyboard. Left thumb row: `GUI ALT CTRL LOWER/TAB RAISE/ENTER`; right thumb row: `RAISE/SPACE LOWER/BSPC CTRL ALT GUI`. A `MUTE`/`PLAY` pair sits in the top-right corner of each half's inner column. Home-row mods on `A S D F` / `J K L ;` mirror the thumb-key order (`GUI ALT CTRL SHIFT`, pinky→index on the left, mirrored on the right) — hold for the modifier, tap for the letter. Tuned as balanced hold-taps restricted to cross-hand key presses (via `hold-trigger-key-positions`) so same-hand rolls like `as` or `fr` resolve as taps, not accidental modifiers. The two innermost thumb keys tap `ENTER`/`SPACE` and hold for `RAISE`; the next pair out tap `TAB`/`BSPC` and hold for `LOWER` — both layers are now reachable from either hand. These are also balanced hold-taps, so a genuine hold (not just fast rollover into the next key) is required to activate the layer — the trade-off is that holding `ENTER`/`SPACE`/`TAB`/`BSPC` no longer auto-repeats via the OS.
- **lower (NUMBER/FUNCTION)** — numbers and their shifted symbols on the home rows (`1`–`0` and `!@#$%…`), `F1`–`F12` above them, remaining programming symbols (`{ } [ ] ; : \ | + - = \``) filling out the rest.
- **raise (NAV/BT/SYSTEM)** — arrow keys and `HOME`/`END`/`PGUP`/`PGDN`/`DEL`/`BSPC` under the right hand for navigation; Bluetooth profile select/clear (`BT_SEL 0-4`, `BT_CLR`) and edit shortcuts (`UNDO`/`CUT`/`COPY`/`PASTE`), `CAPS`, `INS`, `PSCRN`, and `studio_unlock` under the left hand.
- **adjust (RGB/POWER)** — held-together layer for things touched rarely: RGB hue/saturation/brightness/effect controls and `ext_power` toggle on the left half; right half is unused (`&none`).

Full per-key detail: see the diagram below, or read the ASCII-art banners above each layer's `bindings` block in the `.keymap` file itself — those are kept in sync with the actual bindings and are the fastest way to check an exact key.

## Diagram

![Sofle Choc Pro keymap](docs/sofle_choc_pro-keymap.svg)

A print-friendly version is at [`docs/sofle_choc_pro-keymap.pdf`](docs/sofle_choc_pro-keymap.pdf).

Both are generated from the actual `.keymap` + physical layout devicetree via [keymap-drawer](https://github.com/caksoylar/keymap-drawer), so they can't drift from the real bindings. To regenerate after editing the keymap:

```sh
./docs/generate-keymap-diagram.sh
```

This creates a throwaway Python venv (`.venv-keymap-drawer/`, gitignored) with `keymap-drawer` installed, and uses `rsvg-convert` (`brew install librsvg`) for the PDF if it's available.
