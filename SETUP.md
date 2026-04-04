# Setup

This config works on both Windows and macOS.

On macOS, path handling now defaults to POSIX-style separators. Windows-specific path conversion is only applied when Neovim is actually running on Windows.

Clone location:

- Windows: `%LOCALAPPDATA%\nvim`
- macOS: `~/.config/nvim`

Repository:

```text
https://github.com/tadhgdowdall/tadhg.nvim.git
```

## Windows

Recommended package manager: `winget`

### 1. Install core tools

```powershell
winget install Neovim.Neovim
winget install Git.Git
winget install BurntSushi.ripgrep.MSVC
winget install junegunn.fzf
```

### 2. Clone the config

```powershell
git clone https://github.com/tadhgdowdall/tadhg.nvim.git "$env:LOCALAPPDATA\nvim"
```

### 3. Install language runtimes

```powershell
winget install OpenJS.NodeJS.LTS
winget install Python.Python.3.12
winget install GoLang.Go
winget install LLVM.LLVM
winget install Rustlang.Rustup
```

### 4. Install external formatters

```powershell
npm install -g prettier prettierd @biomejs/biome sql-formatter
python -m pip install black isort
go install golang.org/x/tools/cmd/goimports@latest
go install mvdan.cc/gofumpt@latest
cargo install stylua
```

### 5. Start Neovim once to install plugins

```powershell
nvim
```

### 6. Install or verify Mason LSP servers

Inside Neovim:

```vim
:Mason
```

Expected servers:

- `clangd`
- `html`
- `lua_ls`
- `gopls`
- `ts_ls`
- `pyright`
- `tailwindcss`

### 7. Verify installed tools

```powershell
nvim --version
git --version
rg --version
fzf --version
node --version
python --version
go version
clang-format --version
clangd --version
stylua --version
prettierd --version
biome --version
black --version
isort --version
```

## macOS

Recommended package manager: `brew`

### 1. Install Homebrew if needed

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install core tools

```bash
brew install neovim git ripgrep fzf
$(brew --prefix)/opt/fzf/install
```

### 3. Clone the config

```bash
git clone https://github.com/tadhgdowdall/tadhg.nvim.git ~/.config/nvim
```

If `~/.config` does not exist yet:

```bash
mkdir -p ~/.config
git clone https://github.com/tadhgdowdall/tadhg.nvim.git ~/.config/nvim
```

### 4. Install language runtimes and toolchains

```bash
brew install node python go llvm rustup-init
rustup-init -y
source "$HOME/.cargo/env"
```

### 5. Install external formatters

```bash
npm install -g prettier prettierd @biomejs/biome sql-formatter
python3 -m pip install black isort
go install golang.org/x/tools/cmd/goimports@latest
go install mvdan.cc/gofumpt@latest
cargo install stylua
```

### 6. Make sure LLVM tools are on your path if needed

```bash
echo 'export PATH="/opt/homebrew/opt/llvm/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### 7. Start Neovim once to install plugins

```bash
nvim
```

### 8. Install or verify Mason LSP servers

Inside Neovim:

```vim
:Mason
```

Expected servers:

- `clangd`
- `html`
- `lua_ls`
- `gopls`
- `ts_ls`
- `pyright`
- `tailwindcss`

### 9. Verify installed tools

```bash
nvim --version
git --version
rg --version
fzf --version
node --version
python3 --version
go version
clang-format --version
clangd --version
stylua --version
prettierd --version
biome --version
black --version
isort --version
```

## Notes

- Plugins install automatically the first time Neovim starts.
- LSP servers may be installed through Mason, but the external formatters still need to exist on the machine.
- Only install the language tools you actually use.
- `ripgrep` and `fzf` are required for your search workflow.
