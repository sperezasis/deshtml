## Project

deshtml


---

## Technology Stack

# Stack Research

**Domain:** Claude Code skill — packaged + publicly distributed via GitHub, generates self-contained HTML documents from a fixed design system.
**Researched:** 2026-04-27
**Confidence:** HIGH (skill format + reference HTML pattern verified against current docs and an existing working reference; installer pattern verified against multiple public skill repos)

---

## TL;DR

The deshtml stack is **deliberately minimal**: a `SKILL.md` prompt + a small `templates/` directory of reference HTML scaffolds + a `bin/install.sh` shell script. No build system, no Node runtime at install time, no JS framework, no markdown-to-HTML preprocessor. Claude writes HTML directly from the tailored prompt, copying CSS verbatim from a checked-in reference template that matches the existing Caseproof HTML the design system was extracted from.

The most consequential decisions:

1. **Skill, not plugin, not subcommand.** Single `SKILL.md` at `~/.claude/skills/deshtml/SKILL.md` per the official

