# Activator key names

These are the key names accepted by `--keys=KEY1+KEY2`, matching the names produced by
`ActivatorKey.swift`. Names are case-insensitive.

```bash
keypause --keys=leftcommand+leftshift
```
```bash
keypause --keys=cmd+shift
```
```bash
keypause --keys=#55+#56
```

Activator keys must be different from each other. If a key you press during interactive setup
isn't listed here (e.g. an unusual keyboard's special key), Keypause will
print it as its raw keycode number, which you can pass to `--keys` prefixed
with `#` (no quoting needed).

These are also the names Keypause writes to `~/.config/keypause/config` (as
`keys=Name1+Name2`) when it saves your resolved activator combo, so the saved
file uses the same names as this table.

| Key | Type as | Raw key number |
| --- | --- | --- |
| Left Command | `leftcommand`, `cmd`, `command` | 55 |
| Right Command | `rightcommand`, `rightcmd` | 54 |
| Left Shift | `leftshift`, `shift` | 56 |
| Right Shift | `rightshift` | 60 |
| Left Option | `leftoption`, `leftopt`, `leftalt`, `option`, `opt`, `alt` | 58 |
| Right Option | `rightoption`, `rightopt`, `rightalt` | 61 |
| Left Control | `leftcontrol`, `leftctrl`, `control`, `ctrl` | 59 |
| Right Control | `rightcontrol`, `rightctrl` | 62 |
| Caps Lock | `capslock`, `caps` | 57 |
| Fn (Function) | `function` | 63 |
| A | `a` | 0 |
| B | `b` | 11 |
| C | `c` | 8 |
| D | `d` | 2 |
| E | `e` | 14 |
| F | `f` | 3 |
| G | `g` | 5 |
| H | `h` | 4 |
| I | `i` | 34 |
| J | `j` | 38 |
| K | `k` | 40 |
| L | `l` | 37 |
| M | `m` | 46 |
| N | `n` | 45 |
| O | `o` | 31 |
| P | `p` | 35 |
| Q | `q` | 12 |
| R | `r` | 15 |
| S | `s` | 1 |
| T | `t` | 17 |
| U | `u` | 32 |
| V | `v` | 9 |
| W | `w` | 13 |
| X | `x` | 7 |
| Y | `y` | 16 |
| Z | `z` | 6 |
| 0 | `0` | 29 |
| 1 | `1` | 18 |
| 2 | `2` | 19 |
| 3 | `3` | 20 |
| 4 | `4` | 21 |
| 5 | `5` | 23 |
| 6 | `6` | 22 |
| 7 | `7` | 26 |
| 8 | `8` | 28 |
| 9 | `9` | 25 |
| F1 | `f1` | 122 |
| F2 | `f2` | 120 |
| F3 | `f3` | 99 |
| F4 | `f4` | 118 |
| F5 | `f5` | 96 |
| F6 | `f6` | 97 |
| F7 | `f7` | 98 |
| F8 | `f8` | 100 |
| F9 | `f9` | 101 |
| F10 | `f10` | 109 |
| F11 | `f11` | 103 |
| F12 | `f12` | 111 |
| F13 | `f13` | 105 |
| F14 | `f14` | 107 |
| F15 | `f15` | 113 |
| F16 | `f16` | 106 |
| F17 | `f17` | 64 |
| Left Arrow | `leftarrow` | 123 |
| Right Arrow | `rightarrow` | 124 |
| Up Arrow | `uparrow` | 126 |
| Down Arrow | `downarrow` | 125 |
| Return | `return`, `enter` | 36 |
| Tab | `tab` | 48 |
| Space | `space` | 49 |
| Delete (Backspace) | `delete` | 51 |
| Forward Delete | `forwarddelete` | 117 |
| Escape | `escape` | 53 |
| Help | `help` | 114 |
| Home | `home` | 115 |
| End | `end` | 119 |
| Page Up | `pageup` | 116 |
| Page Down | `pagedown` | 121 |
| ` (backtick) | `` ` `` | 50 |
| - (minus) | `-` | 27 |
| = (equals) | `=` | 24 |
| [ (left bracket) | `[` | 33 |
| ] (right bracket) | `]` | 30 |
| \ (backslash) | `\` | 42 |
| ; (semicolon) | `;` | 41 |
| ' (quote) | `'` | 39 |
| , (comma) | `,` | 43 |
| . (period) | `.` | 47 |
| / (slash) | `/` | 44 |
| Keypad 0 | `keypad0` | 82 |
| Keypad 1 | `keypad1` | 83 |
| Keypad 2 | `keypad2` | 84 |
| Keypad 3 | `keypad3` | 85 |
| Keypad 4 | `keypad4` | 86 |
| Keypad 5 | `keypad5` | 87 |
| Keypad 6 | `keypad6` | 88 |
| Keypad 7 | `keypad7` | 89 |
| Keypad 8 | `keypad8` | 91 |
| Keypad 9 | `keypad9` | 92 |
| Keypad . | `keypaddecimal` | 65 |
| Keypad * | `keypadmultiply` | 67 |
| Keypad + | `keypadplus` | 69 |
| Keypad Clear | `keypadclear` | 71 |
| Keypad / | `keypaddivide` | 75 |
| Keypad Enter | `keypadenter` | 76 |
| Keypad - | `keypadminus` | 78 |
| Keypad = | `keypadequals` | 81 |
