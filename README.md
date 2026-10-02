# nvimdots

Cloud0310's personal Neovim configuration, originally based on
[ayamir/nvimdots](https://github.com/ayamir/nvimdots). Configuration is maintained
directly in this repository, with lazy.nvim managing plugins.

## Installation

Use Neovim 0.12 or newer, Git, a Nerd Font, and `ripgrep`. The configured search
backend also uses `fzf`. Language features need their respective runtimes and
build tools; see [language toolchains](docs/language-toolchains.md). Mason installs
the tools listed in `lua/config/settings.lua`.

Move any existing configuration to a backup before cloning. On Linux and macOS:

```sh
git clone https://github.com/Cloud0310/nvimdots.git "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
nvim
```

On Windows, using PowerShell:

```powershell
git clone https://github.com/Cloud0310/nvimdots.git "$env:LOCALAPPDATA\nvim"
nvim
```

If you set `XDG_CONFIG_HOME` or `NVIM_APPNAME`, clone into Neovim's corresponding
configuration directory (`:echo stdpath('config')`). The first start downloads
lazy.nvim and missing plugins. Use `:Lazy restore` to restore plugin versions from
`lazy-lock.json`; `:Mason` shows external tool installation status.

AI adapters are configured in `lua/config/settings.lua`. Credentials are read on
demand through environment variables or `rbw` callbacks; configure the adapter's
credential source for your environment.

## Layout

```text
init.lua                 Entry point
lua/config/              Startup, settings, options, autocmds, diagnostics, keymaps
lua/plugins/             Native lazy.nvim specs with plugin configuration and keys
lua/util/                Shared helpers and runtime operations
snips/                   LuaSnip snippets
nixos/                   Home Manager module and development environment
tutor/                   :Tutor dots
docs/                    Toolchain behavior and language notes
```

Edit the relevant configuration directly. Shared settings live in
`lua/config/settings.lua`, basic mappings in `lua/config/keymaps.lua`, and plugin
settings and mappings alongside their specs in `lua/plugins/`.

## Usage

The leader key is Space. `<C-p>` opens the command and keymap picker.

| Command or key | Action |
| --- | --- |
| `<C-n>` | Toggle file explorer |
| `<leader>ff` / `<leader>fp` | Find files / search text |
| `<A-i>` / `<A-o>` | Next / previous buffer |
| `:Format` / `<A-S-f>` | Format buffer |
| `:FormatToggle` / `<A-f>` | Toggle format on save |
| `:ConformInfo` | Inspect formatter selection and logs |
| `<leader>Tn` / `<leader>T%` | Run nearest test / current file |
| `:Lazy` / `:Mason` | Manage plugins / external tools |
| `:checkhealth` | Inspect Neovim and plugin health |

See [tool installation, formatting, and diagnostics](docs/toolchain-migration.md)
and [language toolchains](docs/language-toolchains.md) for configuration details.

## Nix

The flake exports `homeManagerModules.default`. Add this repository as an input to
your Home Manager flake:

```nix
inputs.nvimdots.url = "github:Cloud0310/nvimdots";
```

Then include the module in your Home Manager configuration:

```nix
imports = [ inputs.nvimdots.homeManagerModules.default ];
programs.neovim.nvimdots = {
  enable = true;
  setBuildEnv = true;
  withBuildTools = true;
};
```

`setBuildEnv` and `withBuildTools` provide the build environment required on
NixOS. The module links this repository's configuration. `bindLazyLock` makes the
plugin lockfile read-only; `mergeLazyLock` merges repository versions into the
writable local lockfile. Choose at most one of these options.

For the repository development environment, run `nix develop`. It uses
`NVIM_APPNAME=nvimdots` and links the configuration into that app directory.

## License

[BSD 3-Clause](LICENSE). The original nvimdots authors and copyright notices are
preserved in the license.
