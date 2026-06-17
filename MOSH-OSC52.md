# Patched mosh — OSC 52 clipboard over mosh + tmux

Copying text in tmux **inside a mosh session** and having it land in the local
machine's clipboard does **not** work with stock mosh 1.4.0. This documents the
fix that is deployed on the `latte` server.

## Why stock mosh fails

Two upstream bugs, both fixed only in the unmerged PR
[mobile-shell/mosh#1104](https://github.com/mobile-shell/mosh/pull/1104):

1. mosh 1.4 only accepts OSC 52 with the `c` (clipboard) selector; tmux emits a
   different selector, so mosh **silently drops** the copy
   ([tmux/tmux#3423](https://github.com/tmux/tmux/issues/3423)).
2. mosh caches the last clipboard value and refuses to re-send identical text,
   so repeated copies **stick on the first one**
   ([mobile-shell/mosh#1090](https://github.com/mobile-shell/mosh/issues/1090)).

The complete fix = patched mosh (PR #1104) on **both** client and server, plus
the tmux settings already in `dot_config/tmux/tmux.conf`. Both ends must be
patched because the clipboard wire format changed.

## tmux side (already tracked in this repo)

In `dot_config/tmux/tmux.conf`:

```tmux
set -g set-clipboard on
set -ga terminal-features ",xterm*:clipboard"
# mosh 1.4 only accepts the `c` selector; force tmux to always emit `c;`
set -ga terminal-overrides ',xterm*:Ms=\E]52;c%p1%.0s;%p2%s\7'
bind-key -T copy-mode-vi Enter            send-keys -X copy-selection-and-cancel
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-and-cancel
```

## Ghostty side (Mac terminal)

Ghostty allows OSC 52 clipboard writes by default. To be explicit, in
`~/.config/ghostty/config`:

```
clipboard-write = allow
copy-on-select = clipboard
```

## Server build (Linux + Linuxbrew)

PR #1104 is unmerged, so build from the PR branch. On Ubuntu 20.04 + Linuxbrew a
hand `make` fails to link (system `ld` vs brew's newer glibc/libstdc++), so build
it through Homebrew in a **local tap** — brew's build environment handles the
toolchain correctly.

```bash
# 1. Fetch the PR source and snapshot it to a tarball
mkdir -p ~/src && cd ~/src
git clone https://github.com/mobile-shell/mosh.git mosh-osc52 && cd mosh-osc52
git fetch origin pull/1104/head:osc52
git checkout osc52
git archive --format=tar.gz --prefix=mosh-osc52/ -o ~/mosh-osc52-src.tar.gz osc52
sha256sum ~/mosh-osc52-src.tar.gz        # note the SHA for the formula below

# 2. Create a local tap and formula
brew tap-new hattajr/local --no-git
TAP="$(brew --repository)/Library/Taps/hattajr/homebrew-local/Formula"
# write $TAP/mosh-osc52.rb (see formula below), pasting the SHA from step 1

# 3. Build + install (replaces the stock brew mosh)
brew uninstall --ignore-dependencies mosh 2>/dev/null || true
brew install --build-from-source hattajr/local/mosh-osc52

# 4. Make mosh-server findable by mosh's NON-interactive ssh shell.
#    brew shellenv is only in ~/.zshrc (interactive). ~/.local/bin IS on the
#    non-interactive PATH (set in ~/.zshenv), so symlink the binary there.
ln -sf "$(brew --prefix)/bin/mosh-server" ~/.local/bin/mosh-server
```

The tap formula (`$TAP/mosh-osc52.rb`) — set `sha256` to the value from step 1:

```ruby
class MoshOsc52 < Formula
  desc "Remote terminal app with PR #1104 OSC52 clipboard fix"
  homepage "https://mosh.org"
  url "file:///home/hattajr/mosh-osc52-src.tar.gz"
  sha256 "REPLACE_WITH_SHA256"
  version "1.4.0-osc52"
  license "GPL-3.0-or-later"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkgconf" => :build
  depends_on "protobuf"

  uses_from_macos "ncurses"

  on_linux do
    depends_on "openssl@3"
    depends_on "zlib-ng-compat"
  end

  def install
    ENV.append_to_cflags "-DNDEBUG"
    inreplace "scripts/mosh.pl", "'mosh-client", "'#{bin}/mosh-client"
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}", "--enable-completion", "--disable-silent-rules"
    system "make", "install"
  end

  test do
    system bin/"mosh-client", "-c"
  end
end
```

Keep `~/mosh-osc52-src.tar.gz` — the formula builds from it, so it is required
for any future `brew reinstall` / `upgrade`. Optionally `brew pin mosh-osc52` so a
stray `brew upgrade` cannot replace it.

## Mac build (client)

macOS has no toolchain mismatch, so a plain source build into `~/.local` works:

```bash
brew install autoconf automake pkgconf protobuf abseil
mkdir -p ~/src && cd ~/src

# Get the source: either fetch the PR, or scp the server tarball:
#   scp <you>@latte:~/mosh-osc52-src.tar.gz ~/src/
#   mkdir mosh-osc52 && tar xzf mosh-osc52-src.tar.gz -C mosh-osc52 --strip-components=1 && cd mosh-osc52
git clone https://github.com/mobile-shell/mosh.git mosh-osc52 && cd mosh-osc52
git fetch origin pull/1104/head:osc52 && git checkout osc52

export PKG_CONFIG_PATH="$(brew --prefix protobuf)/lib/pkgconfig:$(brew --prefix abseil)/lib/pkgconfig:$PKG_CONFIG_PATH"
export CXXFLAGS="-std=gnu++17"            # protobuf 35 needs C++17
./autogen.sh
./configure --prefix="$HOME/.local"
make -j"$(sysctl -n hw.ncpu)"
make install

brew unlink mosh 2>/dev/null || true      # let ~/.local/bin win
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
exec zsh
```

## Verify

```bash
which mosh mosh-client    # both -> ~/.local/bin (Mac)
mosh-client -c            # prints "256" on success
```

Then start a **fresh** `mosh latte`, attach tmux, and copy two *different* texts
in copy-mode — both should paste correctly on the Mac, not stick on the first.

## Caveats / hidden dependencies

- **Both ends must be patched** — the clipboard wire format changed in the PR.
- **Server PATH dependency**: mosh-server is found only because `~/.local/bin`
  is on the *non-interactive* PATH set by `~/.zshenv`. `~/.zshenv` is **not**
  tracked by chezmoi, so on a freshly-bootstrapped machine either re-add that
  PATH entry, re-create the symlink, or connect with
  `mosh --server=$HOME/.local/bin/mosh-server latte`.
- This patched mosh (tap formula, tarball, symlink) is **local machine state**,
  not reproduced by `chezmoi apply`. Re-run the build steps above on a rebuild.
