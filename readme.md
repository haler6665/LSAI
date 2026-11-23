
# LSAI

**LSAI — Lua Script Analysis Interface**

Version: 0.1.0  
Default Language: English  
Platform: Delta Android (compatibility not fully verified)

## About

LSAI is a modular Lua script inspection utility.

It is designed to inspect Lua source code as text without executing the scripts being inspected.

## Features

- Static Lua source inspection
- Device information
- Built-in instructions
- Customizable interface
- Settings management
- Visual macro system
- Module loading checks

## Project Structure

```text
LSAI/
├── LSAI.lua
├── boot.lua
├── database.lua
└── modules/
    ├── security.lua
    ├── instructions.lua
    ├── device.lua
    ├── interface.lua
    ├── settings.lua
    └── macros.lua
```

## Modules

| Module | Purpose |
|---|---|
| security.lua | Static script inspection |
| instructions.lua | Help and documentation |
| device.lua | Device information |
| interface.lua | User interface |
| settings.lua | Application settings |
| macros.lua | Visual macro system |

## Startup Files

- `boot.lua` — startup checks.
- `LSAI.lua` — main entry point.
- `database.lua` — application data and settings.

## Security

LSAI is designed to inspect source code as text.

It does not need to execute inspected scripts.

Detection results are heuristic and do not guarantee that a script is safe.

## Compatibility

Some functions depend on the APIs provided by the target Lua environment.

Delta compatibility must be tested before relying on filesystem access or module loading.

## License

Not specified yet.

