<img src="logo.svg" alt="zna" width="200"/>

# zna

`zna` (Zen Navigation Assistant) is a minimal, lightning-fast command-line directory navigator written in Zig.

## Installation

### From Binary (recommended)

```bash
# Linux (x86_64)
curl -L https://github.com/cherninlab/zna/releases/latest/download/zna-linux-x86_64 -o zna
chmod +x zna
sudo mv zna /usr/local/bin/
```

### From Source

```bash
git clone https://github.com/cherninlab/zna.git
cd zna
zig build -Drelease-safe
sudo cp zig-out/bin/zna /usr/local/bin/
```

## Usage

```bash
$ zna                       # Start navigation in current directory
Arrow keys to navigate      # ↑↓ to select
Enter to go into dir        # Enter directory
q to quit                   # Quit the program
```

## License

MIT
