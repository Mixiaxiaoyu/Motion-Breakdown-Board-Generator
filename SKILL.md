---
name: motion-breakdown-board-generator
description: Analyze a user-provided image and turn it into a professional motion breakdown board / 动效运动说明图 rather than a rendered video, with an optional Dreamina（即梦） video handoff only after the user confirms they are an advanced Dreamina member. Use when the user uploads or references an image and asks to design motion, create a motion breakdown board, generate a loop animation plan, make a static animation explainer board, design an 8-second seamless loop, produce a motion proposal from a still image, or requests a flow such as “先出说明图再确认是不是高级会员”, “生成 motion breakdown board 后接即梦”, or “不是视频，是静态说明图”.
---

# Motion Breakdown Board Generator

Create a motion concept from a single still image and express it as one professional static board. Treat the first output as a design proposal image, not a video render, not a poster, and not a storyboard full of scene changes.

After the board is ready, optionally hand it off to Dreamina（即梦） for video generation, but only after the user confirms they are an advanced Dreamina member who can use the CLI video workflow.

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
  "subject": "主体描述",
  "visual_style": "视觉风格",
  "main_colors": ["主色"],
  "movable_elements": ["可运动元素"],
  "locked_elements": ["必须保持不变的元素"],
  "motion_keywords": ["动效关键词"],
  "avoid": ["禁止事项"]
}
```

- Put faces, logos, typography, product structure, character design details, and carefully composed focal shapes into `locked_elements` by default.

### 2. Build the Motion Logic

- Default to a single clear motion idea instead of many competing effects.
- Keep the camera fixed unless the user explicitly requests camera motion.
- Design the loop as a closed choreography: idle, initiation, expansion, peak, release, settle, reset.
- Break the loop into 6 to 8 phases. Use 7 phases by default.
- Ensure the last phase reconnects to phase 1 without a visible snap or discontinuity.
- Create this internal structure:

```json
{
  "loop_length_seconds": 8,
  "camera": "locked",
  "loop_type": "seamless",
  "motion_concept": "一句话动效核心",
  "phases": [
    {
      "index": 1,
      "time": "0.0-1.2s",
      "label": "阶段名",
      "action": "该阶段发生的运动",
      "anchor": "保持不动的元素",
      "transition": "如何自然接到下一阶段"
    }
  ],
  "continuity_strategy": "如何自然回到第一帧",
  "avoid": ["不应出现的变化"]
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
- Match the board language to the user's language unless the user asks for bilingual output.
- Keep the subject visually consistent across all stages.
- Do not turn the board into a film storyboard, comic page, or ad key visual.

### 6. Generate the Final Board or Fallback Prompt

- If the current environment supports image generation or image editing, generate the final motion breakdown board.
- If the tool supports reference-image or image-edit workflows, use the uploaded image as the preservation anchor.
- If image generation is unavailable, output a full copy-ready prompt using [references/board-spec.md](./references/board-spec.md).
- If the generation tool cannot reliably preserve exact text or logo details, say so briefly and strengthen the preservation instruction in the prompt.

### 7. Ask for Dreamina Membership

- Once the board is ready, pause and ask one short, closed question before any Dreamina submission.
- Use wording equivalent to: `如果继续生成视频，请先确认你是否是高级即梦会员？`
- If the user says no, or says they are not sure, stop after delivering the board and the motion plan.
- If the user says yes, continue directly into the Dreamina video workflow without asking a second “是否继续生成视频” question.
- Do not continue to Dreamina just because the user likes the board.
- Treat `高级即梦会员` as the required gate for the CLI video path.

### 8. Optional Dreamina Video Handoff

- Read [references/dreamina-video-workflow.md](./references/dreamina-video-workflow.md) before using Dreamina.
- On Windows, prefer a local `dreamina.exe` or `dreamina` command instead of `curl ... | bash`.
- Inspect `dreamina multimodal2video -h` and `dreamina query_result -h` before real execution when possible.
- Default video path: use `multimodal2video` with the source image first and the motion breakdown board second.
- Match the video ratio to the source image unless the user specifies another ratio.
- Reuse the board's loop length. If the board is the default, use `8` seconds.
- Prefer `seedance2.0fast` when the user wants a practical default. Use `seedance2.0` or `_vip` variants only when the user explicitly prefers quality or resolution.
- If the CLI still returns `current account is not maestro vip`, stop and tell the user that the server denied CLI generation even though they identified themselves as an advanced member.
- Submit the task, save the `submit_id`, poll for completion, then download the finished media.
- If available, use [scripts/submit_dreamina_video.ps1](./scripts/submit_dreamina_video.ps1) as the reusable wrapper.

## Final Response Format

- `Motion concept:` one short paragraph.
- `Key phases:` 6 to 8 numbered lines with time range and action.
- `Design note:` one compact paragraph or 3 to 5 short bullets.
- `Board output:` either the generated board image or a fenced prompt block ready to paste into an image generator.
- `Membership gate:` ask whether the user is an advanced Dreamina member; if yes, continue directly to video generation.
- `Video status:` only after the user confirms; include the chosen Dreamina route, `submit_id`, current state, and local download path when available.

## Quality Bar

- Keep the motion readable in one glance.
- Keep annotations short and useful.
- Preserve the original subject identity.
- Make the loop feel cyclical rather than merely sequential.
- Favor strong motion direction over flashy effects.
- Never skip the advanced-member gate.
