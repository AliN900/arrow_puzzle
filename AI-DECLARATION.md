---
version: "0.1.2"
level: copilot
processes:
  design: assist
  implementation: pair
  documentation: pair
  testing: assist
  review: none
  deployment: none
---

This format is based on [AI-DECLARATION.md](https://ai-declaration.md/en/0.1.2).

## Notes

### Original project (ArrowEscape by sidhant947)
- The original game was developed using a **local LLM** via [Ollama](https://ollama.com/) paired with [OpenCode](https://opencode.ai/). No online LLM was used.

### This fork (Arrow Puzzle by AHB.Dev)
- The UI redesign, Settings screen, theme system, and other modifications in this fork were developed **with assistance from an online AI assistant (Claude / ChatGPT)**.
- All AI-generated code has been reviewed, tested, and adapted by the project author.

### Expectations for contributors

If you use AI to help write a contribution, **please declare it first**. PRs that can be done easily with simple logic may be rejected if they contain unnecessary AI overthinking.