# deshtml

deshtml is a Claude Code skill — an add-on that gives Claude a specific job to do. You run `/deshtml`, answer six short questions about your topic, approve the proposed story arc, and Claude writes a single self-contained HTML file to the current directory. The HTML follows the Caseproof Documentation System: a fixed palette, fixed typography, a closed component library. You did not need to know the design system; the skill knows it.

## Install

Paste this in a terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/install.sh | bash
```

The skill installs to `~/.claude/skills/deshtml/`. Re-running the same command updates an existing install in place.

## First run

Open Claude Code in any directory and type `/deshtml`. The skill walks you through six short questions, then proposes a story arc as a table. Approve the arc with `approve`, and Claude writes the HTML file and opens it in your browser.

1. Claude asks the document type — pick `handbook`, `pitch`, `technical brief`, `presentation`, or `meeting prep`.
2. Claude asks five more questions about your audience, your material, your sections, your tone, and any inclusions or exclusions.
3. Claude shows a story-arc table with five columns and a flowing paragraph reading the arc as a single read.
4. Reply `approve` (or describe changes — Claude regenerates the arc until you approve).
5. Claude writes a `YYYY-MM-DD-<slug>-<type>.html` file to your current directory and opens it in your default browser. The absolute path is the last line of output.

## The five doc types

Each doc type runs a short tailored interview and lands in the format that fits its content shape:

- **Handbook** — multi-section reference doc. Sidebar layout (960px wide).
- **Pitch** — problem → solution → ask narrative. Linear layout (1440px wide).
- **Technical brief** — architecture or decision write-up for engineers. Sidebar layout.
- **Presentation** — single-page slide deck with anchor navigation. Full-viewport slides.
- **Meeting prep** — briefing doc with context, talking points, and anticipated questions. Linear layout.

The skill picks the format from the doc type and the section count automatically — you do not pick it.

## Source mode

If you already have a draft, run `/deshtml @path/to/draft.md` instead. The skill skips the interview entirely, reads the file, infers the document type from the source's shape, and proposes a story arc grounded in the source content. The same arc-approval gate runs — nothing is rendered until you approve. You can also paste raw text longer than ~200 characters as the prompt and the skill will use it the same way.

## Uninstall

Paste this in a terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/sperezasis/deshtml/main/bin/uninstall.sh | bash
```

Or remove the directory directly:

```bash
rm -rf ~/.claude/skills/deshtml
```

## Known limitations

- **Offline:** the generated HTML loads the Inter font from Google Fonts. Without internet, the document falls back to your system font and still renders correctly.
- **macOS-first:** after writing the file, the skill runs `open <file>` to launch your default browser. `open` is macOS-only; on Linux the file is written and the absolute path is printed, but the browser does not auto-open. Open the file manually.
- **One file per run:** the skill writes one HTML file and stops. To revise, ask Claude to edit the file in normal conversation — there is no in-skill revision loop.

## Design system

The palette, typography, and component library are based on the **Caseproof Documentation System**, an internal Caseproof design system. Public access is not yet available — contact Santiago Perez Asis for design-system reference materials.

## License

MIT. See [LICENSE](LICENSE).
