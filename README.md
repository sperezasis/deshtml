# deshtml

Opinionated Claude Code skill that turns ideas into beautifully designed, self-contained HTML documents — story-first, one command to install.

Status: pre-launch. Full README ships at v0.1.0.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh | bash
```

The installer:
- Refuses to run as root.
- Reads the current version from this repo's `VERSION` file.
- Shallow-clones the matching git tag into a temp directory.
- Atomically replaces `~/.claude/skills/deshtml/` with the new payload.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/uninstall.sh | bash
```

Or remove the directory directly:

```bash
rm -rf ~/.claude/skills/deshtml
```

## License

MIT. See `LICENSE`.
