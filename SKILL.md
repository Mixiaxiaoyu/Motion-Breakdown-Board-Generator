---
name: motion-breakdown-board-generator
description: Analyze a user-provided image and turn it into a professional motion breakdown board / 动效运动说明图 rather than a rendered video, with an optional Dreamina（即梦） video handoff only after the user confirms they are an advanced Dreamina member. Use when the user uploads or references an image and asks to design motion, create a motion breakdown board, generate a loop animation plan, make a static animation explainer board, design an 8-second seamless loop, produce a motion proposal from a still image, or requests a flow such as “先出说明图再确认是不是高级会员”, “生成 motion breakdown board 后接即梦”, or “不是视频，是静态说明图”.
---

# Motion Breakdown Board Generator

Create a motion concept from a single still image and express it as one professional static board. Treat the first output as a design proposal image, not a video render, not a poster, and not a storyboard full of scene changes.

After the board is ready, optionally hand it off to Dreamina（即梦） for video generation, but only after the user confirms that they are an advanced Dreamina member who can use the CLI video workflow.

## Default Operating Mode

- Assume one source image and one short request.
- Default to an 8-second seamless loop with a locked camera.
- Preserve the subject's silhouette, proportions, composition, brand marks, text, costume, product geometry, and core visual identity.
- Keep the scene simple: do not add new complex environments, unrelated light effects, or decorative particles unless the user asks for them.
- Make the motion progress gradually and return naturally to the first state.
- Ask follow-up questions only if the source image is missing, unreadable, or the target image is ambiguous.
- Do not submit any paid video generation task until the user has seen the motion board and confirmed that they are an advanced Dreamina member.

## Workflow

### 1. Inspect the Image

- Open and inspect the uploaded image or referenced local image directly.
- Identify the main subject, composition, visual style, depth layers, rhythm, and implied motion opportunities.
- Distinguish between movable elements and locked elements before designing any motion.
- Create this internal object. Keep it internal unless showing it would help the user:

```json
{
  "subject": "main subject description",
  "visual_style": "visual style",
  "main_colors": ["main colors"],
  "movable_elements": ["movable parts"],
  "locked_elements": ["identity-critical parts"],
  "motion_keywords": ["motion keywords"],
  "avoid": ["things to avoid"]
}
```

- Put faces, logos, typography, product structure, character design details, and carefully composed focal shapes into `locked_elements` by default.

### 2. Build the Motion Logic

- Default to a single clear motion idea instead of many competing effects.
- Keep the camera fixed unless the user explicitly requests camera motion.
- Design the loop as a closed choreography: idle, initiation, expansion, peak, release, settle, reset.
- Break the loop into 6 to 8 phases. Use 7 phases by default.
- For tall full-body characters or dense annotation layouts, prefer 6 to 7 phases instead of forcing 8.
- Ensure the last phase reconnects to phase 1 without a visible snap or discontinuity.
- Create this internal structure:

```json
{
  "loop_length_seconds": 8,
  "camera": "locked",
  "loop_type": "seamless",
  "motion_concept": "one-sentence core motion idea",
  "phases": [
    {
      "index": 1,
      "time": "0.0-1.2s",
      "label": "phase label",
      "action": "what happens",
      "anchor": "what stays stable",
      "transition": "how it connects to the next phase"
    }
  ],
  "continuity_strategy": "how the final phase reconnects to the first phase",
  "avoid": ["unwanted motion or drift"]
}
```

- Read [references/board-spec.md](./references/board-spec.md) if the motion type, phase structure, or board composition is not obvious.

### 3. Choose Motion That Fits the Image

- Prefer motion that is already suggested by the image: breathing, drifting, swaying, parallax, ripple, orbit, blink, soft reveal, pulse, hover, or subtle rotation.
- Keep anchor elements stable so the board feels intentional rather than noisy.
- Treat seamless looping as a design constraint, not an afterthought.
- Avoid sudden cuts, scene swaps, heavy FX, random glow sweeps, or subject redesign unless the user explicitly asks for them.

### 4. Write the Concise Motion Note

- Summarize the motion idea in one short paragraph.
- Explain why the motion fits the image's style and subject.
- Call out the main moving elements, the locked elements, and the loop return logic.
- Keep the language concise and presentation-ready.

### 5. Produce the Motion Breakdown Board

- Generate one static board that explains the motion system at a glance.
- Keep the board professional, clean, and presentation-ready.
- Use one large reference panel and 6 to 8 numbered motion stages, or one large panel with layered ghosted positions plus supporting stage tiles.
- Add arrows, motion paths, ghost overlays, timing labels, and very short annotations.
- For the human review board, prefer white or very light high-contrast arrows so the motion direction reads clearly against saturated character art and colorful backgrounds.
- If the background is light, add a thin darker outline or soft shadow to the arrow before changing away from white.
- Match the board language to the user's language unless the user asks for bilingual output.
- Keep the subject visually consistent across all stages.
- In every stage panel, keep the full subject visible unless the user explicitly asks for close-ups or cropped framing.
- Treat head, hair ornaments, sleeves, hands, feet, tails, and long accessories as protected edges that must stay inside the panel.
- If the source image is a full-body or near full-body character, preserve full-body readability in the stage panels as well.
- If there is a conflict between larger figure scale and full subject visibility, reduce the figure scale first.
- Prefer moving arrows and labels into surrounding whitespace before allowing any character crop.
- For tall portrait characters, prefer a roomier two-row stage arrangement or taller stage tiles instead of dense shallow columns.
- Do not turn the board into a film storyboard, comic page, or ad key visual.

### 6. Generate the Final Board or Fallback Prompt

- If the current environment supports image generation or image editing, generate the final motion breakdown board.
- If the tool supports reference-image or image-edit workflows, use the uploaded image as the preservation anchor.
- If image generation is unavailable, output a full copy-ready prompt using [references/board-spec.md](./references/board-spec.md).
- If the generation tool cannot reliably preserve exact text or logo details, say so briefly and strengthen the preservation instruction in the prompt.
- If a first-pass board crops the subject in any stage, retry once with stronger framing language: `full body fully visible in every panel`, `no cropped limbs or hair`, `shrink figure to fit`, `keep 8 to 12 percent inner safe margin`.
- Treat the first board as the human review board. It may contain arrows, labels, numbers, stage frames, and a timeline for readability.
- In the human review board, white arrows are the preferred default unless they become unreadable against the local background.
- If the user later proceeds to Dreamina video generation, derive a second `clean handoff board` when possible: preserve only the subject poses, ghosted motion states, and broad motion direction, while removing arrows, labels, numbers, captions, borders, timelines, and collage-style layout cues.
- If a separate clean handoff board cannot be generated, keep using the annotated board but compensate with a stricter Dreamina prompt that explicitly forbids rendering board graphics into the final video.

### 7. Ask for Dreamina Membership

- Once the board is ready, pause and ask one short, closed question before any Dreamina submission.
- Use wording equivalent to: `如果继续生成视频，请先确认你是否是高级即梦会员？`
- If the user says no, or says they are not sure, stop after delivering the board and the motion plan.
- If the user says yes, continue directly into the Dreamina video workflow without asking a second `是否继续生成视频` question.
- Do not continue to Dreamina just because the user likes the board.
- Treat `高级即梦会员` as the required gate for the CLI video path.

### 8. Optional Dreamina Video Handoff

- Read [references/dreamina-video-workflow.md](./references/dreamina-video-workflow.md) before using Dreamina.
- On Windows, prefer a local `dreamina.exe` or `dreamina` command instead of `curl ... | bash`.
- Inspect `dreamina multimodal2video -h` and `dreamina query_result -h` before real execution when possible.
- Default video path: use `multimodal2video` with the source image first and the motion breakdown board second.
- When available, prefer `source image + clean handoff board` over `source image + annotated review board`.
- Match the video ratio to the source image unless the user specifies another ratio.
- Reuse the board's loop length. If the board is the default, use `8` seconds.
- Prefer `seedance2.0fast` when the user wants a practical default. Use `seedance2.0` or `_vip` variants only when the user explicitly prefers quality or resolution.
- Build a short, submission-ready Dreamina prompt that explicitly maps the two images: image 1 is the source subject, image 2 is the motion instruction image.
- Use wording equivalent to `图一角色严格按照图二的动作说明生成循环动效` when the user wants close adherence to the board.
- State that image 2 is an instruction reference only, not the final visual style or a collage to be rendered literally.
- If image 2 contains white arrows or other direction marks, tell Dreamina to read them only as motion direction cues and never render those marks into the final video.
- Explicitly forbid rendering arrows, numbers, labels, text, panel borders, timelines, stickers, or any board annotation graphics into the final video.
- Re-state the identity lock when consistency matters: same character, same proportions, same materials, same costume, same color palette, same background logic, same camera.
- Keep the video prompt short and action-first. Prefer 2 to 4 compact sentences over a long descriptive paragraph.
- If the first Dreamina result turns board graphics into visible video elements, retry once with a stronger negative clause and, when possible, swap in a cleaner handoff board.
- If the CLI still returns `current account is not maestro vip`, stop and tell the user that the server denied CLI generation even though they identified themselves as an advanced member.
- Submit the task, save the `submit_id`, poll for completion, then download the finished media.
- If available, use [scripts/submit_dreamina_video.ps1](./scripts/submit_dreamina_video.ps1) as the reusable wrapper.

## Final Response Format

- `Motion concept:` one short paragraph.
- `Key phases:` 6 to 8 numbered lines with time range and action.
- `Design note:` one compact paragraph or 3 to 5 short bullets.
- `Board output:` either the generated board image or a fenced prompt block ready to paste into an image generator.
- `Membership gate:` ask whether the user is an advanced Dreamina member; if yes, continue directly to video generation.
- `Dreamina prompt:` only after the user confirms; include the final short prompt string used for submission.
- `Video status:` only after the user confirms; include the chosen Dreamina route, `submit_id`, current state, and local download path when available.

## Quality Bar

- Keep the motion readable in one glance.
- Keep annotations short and useful.
- Preserve the original subject identity.
- Make the loop feel cyclical rather than merely sequential.
- Favor strong motion direction over flashy effects.
- Never skip the advanced-member gate.
- Do not let review-board graphics leak into the final video render.
