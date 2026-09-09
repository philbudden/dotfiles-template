# Dotfiles template

A deliberately small starting point for personal dotfiles. It installs Homebrew and a few broadly useful command-line tools.

## Included tools

- [Homebrew](https://brew.sh/) for package management.
- `gh` for GitHub from the command line.
- `ripgrep`, `fd`, `fzf`, `jq`, and `bat` for everyday terminal work.
- `stow` for linking configuration you choose to add later.

## Install

On GitHub, select **Use this template** to create your own dotfiles repository. Clone that new repository, then run:

```bash
git clone git@github.com:your-account/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles
./bootstrap.sh
```

The script installs Homebrew when needed, loads it from the standard macOS or Linux location, and adds Homebrew's official `shellenv` entry to `.zprofile` (Zsh) or `.bashrc` (Bash). It then installs the packages in `Brewfile`. It is safe to rerun: Homebrew Bundle installs missing packages and leaves installed packages alone.

On a new Linux machine or devcontainer, install the base prerequisites required by Homebrew first (including `curl`, `git`, and a compiler toolchain). See [Homebrew's installation documentation](https://docs.brew.sh/Installation) for the current prerequisites.

## Customise it

Add a generally useful command-line package to `Brewfile`:

```ruby
brew "example-tool"
```

Then rerun `./bootstrap.sh`, or run `brew bundle --file Brewfile` directly.

Keep personal configuration in separate, clearly named files or directories. Before adding a bootstrap action, consider whether every clone of the template should receive it by default.

The empty `stow/` directory is ready for configuration you decide to manage. If you choose to use Stow, create a package directory such as `stow/shell/.zshrc`. Then add its package name to the `stow_packages` array near the top of `bootstrap.sh`:

```bash
stow_packages=(shell)
```

On the next bootstrap, it will link the package using the same command you can run yourself:

```bash
stow --dir stow --target "$HOME" shell
```

The array starts empty, so the template does not link anything until you opt in.

For a fuller example of a Stow layout, see [philbudden/dotfiles](https://github.com/philbudden/dotfiles).

## Continuous integration

The bootstrap smoke test runs on every push. It creates a fresh Ubuntu environment, installs Homebrew and the Brewfile packages, then checks that a new shell can find them.
