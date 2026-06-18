# Motion Breakdown Board Generator

Chinese version: [README.md](./README.md)

This is a Codex Skill for turning a single still image into a professional `motion breakdown board`, and optionally handing that board off to Dreamina CLI for video generation.

It is not a video renderer and not a regular poster generator. Its primary output is a clean, production-style static motion board that explains how the animation should work.

## What It Does

- Analyzes the subject, style, movable parts, and locked parts in an uploaded image
- Designs a default `8-second locked-camera seamless loop`
- Breaks the motion into `6 to 8 key phases`
- Outputs a concise motion design note
- Generates a static motion breakdown board
- Can derive a cleaner Dreamina handoff board that strips arrows, labels, and timeline graphics when needed
- Uses image generation directly when the environment supports it
- Continues into Dreamina CLI video generation only after the user confirms they are an `advanced Dreamina member`

## Typical Use Cases

Use this skill when the user says things like:

- Design motion for this image
- Generate a motion breakdown board
- Create an 8-second loop animation plan
- Make a seamless loop based on this image
- Produce a motion explainer board first, then send it to Dreamina

## Default Behavior

If the user does not specify a motion style, this skill defaults to:

- `8 seconds`
- `locked camera`
- `seamless loop`
- `subject identity preserved`
- `no extra complex scene building`
- `gradual progression`
- `final frame returns naturally to frame one`

If the user already specifies duration, motion type, camera behavior, rhythm, or emphasis, the skill follows the user's instruction first and uses the defaults only to fill gaps.

## Workflow

### 1. Image Understanding

The skill first analyzes:

- the main subject
- visual style
- main colors
- movable elements
- locked elements
- suitable motion keywords

### 2. Motion Design

The motion is then organized into a loop logic, typically shaped as:

- start
- anticipation
- expansion
- peak
- release
- rebound
- reset

### 3. Motion Board Output

The skill prioritizes a static professional board before any video generation. The board usually includes:

- one main reference area
- 6 to 8 key phase panels
- arrows, motion paths, ghost overlays, or displacement guides
- time labels
- short notes
- a `0s -> 8s -> 0s` loop timeline

The review board is optimized for human readability. If the workflow later continues to Dreamina, the skill can derive a cleaner handoff board with fewer overlay graphics.

### 4. Dreamina Video Branch

If the user wants to continue to video generation, the skill first asks:

`If you want to continue to video generation, please confirm whether you are an advanced Dreamina member.`

Branch rules:

- If the user says `no`, the flow stops at the motion board.
- If the user says `not sure`, the flow stops until the user verifies the account.
- If the user says `yes`, the skill moves directly into the Dreamina CLI video workflow without asking a second continuation question.

Even when the user says they are an advanced Dreamina member, the actual Dreamina CLI permission result is the final source of truth.

When the flow continues to Dreamina, the skill now prefers:

- image 1 = original source character image
- image 2 = clean handoff board when available, or the annotated review board with a stricter negative prompt

The Dreamina prompt should explicitly say that image 2 is a motion instruction reference, not a literal graphic layer to render into the final video. It should also explicitly forbid arrows, labels, numbers, borders, and timeline graphics from appearing in the output.

## Directory Structure

```text
motion-breakdown-board-generator/
├── SKILL.md
├── README.md
├── README.en.md
├── LICENSE
├── agents/
│   └── openai.yaml
├── references/
│   ├── board-spec.md
│   └── dreamina-video-workflow.md
└── scripts/
    └── submit_dreamina_video.ps1
```

## Important Files

- [SKILL.md](./SKILL.md)
  The main skill instruction file used by Codex.

- [references/board-spec.md](./references/board-spec.md)
  Board layout rules, prompt templates, and composition guidance.

- [references/dreamina-video-workflow.md](./references/dreamina-video-workflow.md)
  The Dreamina-specific video workflow notes.

- [scripts/submit_dreamina_video.ps1](./scripts/submit_dreamina_video.ps1)
  A PowerShell helper for `submit -> poll -> download` with Dreamina CLI.

## Example Prompts

### Board Only

```text
Design an 8-second seamless loop for this image and generate a motion breakdown board.
```

### User-Specified Motion Direction

```text
Make this a 5-second gentle floating loop with a locked camera, and focus on delayed hair and sleeve motion.
```

### Dreamina Handoff

```text
Generate the motion breakdown board first. After I confirm I am an advanced Dreamina member, continue to Dreamina video generation.
```

## Installation Location

To make Codex auto-discover this skill, common locations are:

- user-level: `~/.codex/skills/motion-breakdown-board-generator/`
- project-level: `<project>/.codex/skills/motion-breakdown-board-generator/`

This skill currently uses the project-level layout.

## Notes

- The core output of this skill is a `static motion breakdown board`
- Dreamina video generation is an optional branch, not the default main path
- The Dreamina branch expects the user to confirm they are an `advanced Dreamina member`
- If Dreamina CLI returns a permission failure, the flow must stop
- If Dreamina starts literalizing arrows, labels, or timeline graphics, retry with the cleaner handoff board plus the stricter negative prompt

## License

This project is licensed under the [MIT License](./LICENSE).
