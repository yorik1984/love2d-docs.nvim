<h1 align="center">♡&nbsp;&nbsp; <a href="https://love2d.org/wiki/Main_Page">LÖVE docs</a>&nbsp;&nbsp;♡</h1>

<a href="https://dotfyle.com/plugins/yorik1984/love2d-docs.nvim">
	<img src="https://dotfyle.com/plugins/yorik1984/love2d-docs.nvim/shield?style=flat" />
</a>

[![Generate love2d-docs](https://github.com/yorik1984/love2d-docs.nvim/actions/workflows/update-love-api.yml/badge.svg)](https://github.com/yorik1984/love2d-docs.nvim/actions/workflows/update-love-api.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/yorik1984/love2d-docs.nvim/blob/main/LICENSE)
[![Lua](https://img.shields.io/badge/Lua-5.1-blue.svg)](https://www.lua.org/)
[![LÖVE API](https://img.shields.io/badge/L%C3%96VE_API-11.5-EA316E.svg)](https://github.com/love2d-community/love-api)
[![Neovim](https://img.shields.io/badge/Neovim-0.5+-green.svg)](https://neovim.io/)
[![Vim](https://img.shields.io/badge/Vim-8.0+-green.svg)](https://www.vim.org/)

**Comprehensive documentation 📚**

## ✨ About

**love2d-docs.nvim** is a comprehensive plugin for [Neovim](https://neovim.io/) and [Vim](https://www.vim.org/) that brings the entire [LÖVE](http://love2d.org) game framework documentation right into your editor.

- 📖 **Built-in Help** — Complete LÖVE API documentation accessible via `:help LOVE-*`

<!-- TOC -->

## Table of Contents

- [📦 Installation](#-installation)
- [📚 Documentation](#-documentation)
- [🔄 Rebuilding the API](#-rebuilding-the-api)
  - [🤖 Automated Workflow](#-automated-workflow)
  - [✋ Manual Generation (Optional)](#-manual-generation-optional)
- [🎨 Screenshots](#-screenshots)
- [📚 References & Related Projects](#-references--related-projects)
- [©️ Credits](#-credits)

<!-- /TOC -->

## 📦 Installation

#### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
require("lazy").setup({
    "yorik1984/love2d-docs.nvim",
    branch = "main" -- default or `branch = "11.5"` for special API version
    ft = "lua",
})
```

#### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug "yorik1984/love2d-docs.nvim"
```

## 📚 Documentation

Access the complete LÖVE API documentation `:help LOVE-*`:

| What to find      | Command Example                  | Alias                            |
| ----------------- | -------------------------------- | -------------------------------- |
| **Function**      | `:help LOVE-love.window.setMode` | `:help love-love.window.setMode` |
| **Type**          | `:help LOVE-File`                | `:help love-File`                |
| **Type Method**   | `:help LOVE-File:isEOF`          | `:help love-File:isEOF`          |
| **Enum**          | `:help LOVE-BufferMode`          | `:help love-BufferMode`          |

## 🔄 Rebuilding the API

### 🤖 Automated Workflow

This plugin uses **GitHub Actions** to automatically stay up-to-date with the latest LÖVE API:

| Feature      | Details                                                                   |
| ------------ | ------------------------------------------------------------------------- |
| **Schedule** | Every Monday at 00:30 UTC                                                 |
| **Trigger**  | Manual dispatch via Actions tab                                           |
| **Source**   | [love2d-community/love-api](https://github.com/love2d-community/love-api) |
| **Updates**  | Documentation                                                             |

**How it works:**

1. 🔄 Fetches the latest LÖVE API specification
2. 📝 Generates help files (`love2d-docs.txt`)
3. 🚀 Automatically commits changes to the repository
4. 📌 Creates version branches (e.g., `11.5`, `12.0`) for API version tracking

> [!NOTE]
> The badge at the top of this README always shows the current LÖVE API version supported by this plugin.

### ✋ Manual Generation (Optional)

> [!TIP]
> **You don't need to do this!** The automated workflow keeps everything up-to-date.  
> Manual generation is only for:
> - Testing custom modifications
> - Contributing to plugin development
> - Offline environments without GitHub Actions

If you still want to generate files manually:

- Prerequisites:
```
# Ensure these are installed
git --version
lua -v           # Lua 5.1
nvim --version   # or vim
```

- Configure (optional):
Edit build/env.txt to set custom paths:
```
lua="lua5.1"     # Change to your Lua version
nvim="nvim"      # or "vim"
```

- Run the generator:
```bash
# On Linux/Mac
chmod +x build/gen.sh
./build/gen.sh

# On Windows
build/gen.bat
```

- Generated files:
    - 📄[`love2d-docs.txt`](doc/love2d-docs.txt) — API and plugin documentation

## 🎨 Screenshots

### Neovim with [newpaper.nvim](https://github.com/yorik1984/newpaper.nvim)

<div align="center">
  <img src="pics/screen1.png" alt="Neovim screenshot 1" width="80%">
</div>

### Vim with [papercolor-theme](https://github.com/NLKNguyen/papercolor-theme)

<div align="center">
  <img src="pics/screen3.png" alt="Vim screenshot" width="80%">
</div>

## 📚 References & Related Projects

+ **[love2d-definitions](https://github.com/yorik1984/love2d-definitions)**<br>
[LuaCATS](https://luals.github.io/wiki/annotations/) definition for [LÖVE](https://love2d.org/) framework.
Creates `---@class` and `---@alias` definitions for perfect autocompletion and type checking in IDEs with LuaCATS.
    - **🤖 Automated Updates:** Uses GitHub Actions to stay in sync with the official love-api, just like this plugin.
    - **📦 Ready-to-Use:** Provides a pre-generated `library/` folder that you can directly add to your workspace library.
    - **🧠 Smart Type System:** Intelligently handles type unions, plural forms (e.g., `tables` → `table[]`), optional parameters, and function overloads.
    - **📌 Version Branches:** Includes branches for specific LÖVE versions (e.g., `11.5`), so you can use annotations that match your project.

+ **[love2d-tresitter.nvim](https://github.com/yorik1984/love2d-treesitter.nvim)**<br>
Is a comprehensive plugin for [Neovim](https://neovim.io/) that highlight [LÖVE](http://love2d.org) syntax in your editor.
Provides complete LÖVE API syntax highlighting for LÖVE functions, modules, types, and callbacks, with full **[Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)** support.
    * **🤖 Automated Updates:** Uses GitHub Actions to stay in sync with the official love-api, just like this plugin.
    * **⚙️ Fully Customizable:** Offers flexible styling options for colors and font styles (bold, italic, etc.).
    * **📌 Version Branches:** Maintains version-specific branches (e.g., `11.5`) to match different LÖVE releases.

+ **[love2d-vim-syntax](https://github.com/yorik1984/love2d-vim-syntax)**<br>
Plugin for [Vim](https://www.vim.org/) that highlight [LÖVE](http://love2d.org) syntax in your editor.
    - 🎨 **Syntax Highlighting** — Colors LÖVE functions, modules, types, and callbacks
    - 🔧 **Customizable** — Flexible styling options for Vim

## ©️ Credits

* Original Author: [Davis Claiborne](https://github.com/davisdude) — Created and maintained the original [vim-love-docs](https://github.com/davisdude/vim-love-docs)
* Powered by: [love-api](https://github.com/love2d-community/love-api) — Community-maintained LÖVE API specification

<div align="center">
  <sub>
    Built with ♡ for the LÖVE community
    <br>
    <a href="https://github.com/yorik1984/love2d-docs.nvim/issues">Report Issue</a> ·
    <a href="https://github.com/yorik1984/love2d-docs.nvim/discussions">Discussion</a> ·
    <a href="https://love2d.org/">LÖVE</a>
  </sub>
</div>
