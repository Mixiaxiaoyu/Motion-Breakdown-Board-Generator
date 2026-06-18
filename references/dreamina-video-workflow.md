# Dreamina Video Workflow

Read this file when the user wants video generation after approving the motion breakdown board and has confirmed that they are an advanced Dreamina member.

## Membership Gate

- Ask first whether the user is an `高级即梦会员`.
- If the user says no, stop after the motion board.
- If the user is unsure, stop and ask them to verify before attempting CLI generation.
- If the user says yes, move directly to the Dreamina submit flow without asking a second confirmation question.
- Treat this as a hard gate before any Dreamina video submission.
- If the CLI still returns `current account is not maestro vip`, stop and report that the backend denied CLI access.

## Credit Gate

- Treat Dreamina video generation as a paid action.
- Do not spend credits just because the user asked for a motion board.
- After the membership gate passes, the user's request to continue is enough to proceed.

## Command Choice

- Prefer `multimodal2video` for the handoff from still image plus motion breakdown board.
- Use the source image as the first `--image`.
- Use the motion breakdown board as the second `--image`.
- When possible, use a `clean handoff board` as the second image instead of the fully annotated review board.
- Use `image2video` only when there is no board and one main image is enough.
- Use `multiframe2video` for multi-scene stories, not for this skill's normal loop-preview flow.

## Windows Note

- On Windows, use `dreamina.exe` or a locally installed `dreamina` command.
- Do not rely on `curl -s ... | bash` unless the environment actually has `bash`.

## Default Dreamina Mapping

- `command`: `multimodal2video`
- `images`: source image first, board second
- `duration`: `8`
- `ratio`: match the source image; common values are `3:4`, `16:9`, or `9:16`
- `model_version`: default to `seedance2.0fast`
- `video_resolution`: omit unless the user explicitly wants a supported override

## Prompt Pattern

Keep the prompt short, explicit, and anchored to the two-image order.

Baseline wording:

```text
图一角色严格按照图二的动作说明生成 8 秒无缝循环动效。图一是角色原图，图二只是运动说明，不是最终画面风格；镜头固定，角色造型、比例、材质、表情、构图和配色必须与图一保持一致。如果图二里有白色箭头或其他指示线，只参考它们表达的动作方向，不生成箭头或指示线本身。只提取图二中的动作节奏、位移和回环逻辑，不要生成图二里的箭头、数字、文字、边框、时间轴、贴纸或任何说明图元素。最终视频只保留图一中的角色与原始场景，并自然回到第一帧。
```

Prompt rules:

- Tell Dreamina that image 1 is the source subject and image 2 is the motion instruction board.
- Prefer the stronger wording `严格按照图二的动作说明` when the user expects close board adherence.
- Say `镜头固定` when the board uses the default locked camera.
- Say `无缝循环` when the board is meant to loop cleanly.
- Re-state the protected identity traits if the subject is brand-sensitive.
- Say that image 2 is `动作说明` or `运动说明`, not a visual style target.
- If the board contains white arrows, say they are direction cues only and must not become rendered graphics in the output.
- Explicitly ban board artifacts in the final render: `不要生成图二里的箭头、数字、文字、边框、时间轴或任何说明图元素`.
- Avoid over-describing the board graphics themselves; the board is guidance, not a style target.
- Keep the prompt action-centric. Describe the motion logic, not the board layout.
- Prefer 2 to 4 compact sentences. Longer prompts are more likely to make the model literalize the board.

## Prompt Retry Rules

If the first video attempt shows arrows, labels, numbers, or panel graphics from the board:

- Retry once with a stronger negative clause:

```text
忽略图二中的所有说明图形，只参考其动作含义；如果图二里有白色箭头，只把它当作运动方向提示，不生成箭头本身。禁止把任何箭头、图标、数字、字母、文字、时间轴、边框、排版、贴纸或拼贴说明板生成到视频画面中。
```

- If character consistency also drifts, add a second lock sentence:

```text
角色必须与图一完全是同一个角色，不能变脸、变体型、变材质、变配色、变背景、变镜头。
```

- If available, replace the annotated review board with a cleaner handoff board before retrying.

## Clean Handoff Board Guidance

When generating a second image specifically for Dreamina handoff, prefer a simplified board that:

- keeps the subject poses and broad motion progression
- keeps ghosted motion states only when they help explain direction
- removes arrows, numbers, text, labels, timeline bars, borders, stage frames, and sticker-like decorations
- avoids dense collage presentation and favors a cleaner single-subject motion reference

The review board for humans and the handoff board for Dreamina do not need to be the same asset.

## Manual CLI Flow

1. Log in if needed:

```powershell
.\dreamina.exe login
```

2. Submit the video task:

```powershell
.\dreamina.exe multimodal2video `
  --image "C:\path\source.png" `
  --image "C:\path\motion-board-clean.png" `
  --prompt "图一角色严格按照图二的动作说明生成 8 秒无缝循环动效。图一是角色原图，图二只是运动说明，不是最终画面风格；镜头固定，角色造型、比例、材质、表情、构图和配色必须与图一保持一致。如果图二里有白色箭头或其他指示线，只参考它们表达的动作方向，不生成箭头或指示线本身。只提取图二中的动作节奏、位移和回环逻辑，不要生成图二里的箭头、数字、文字、边框、时间轴、贴纸或任何说明图元素。最终视频只保留图一中的角色与原始场景，并自然回到第一帧。" `
  --ratio "3:4" `
  --duration 8 `
  --model_version "seedance2.0fast" `
  --poll 20
```

3. Save the returned `submit_id`.

4. Poll and download:

```powershell
.\dreamina.exe query_result `
  --submit_id "YOUR_SUBMIT_ID" `
  --download_dir "C:\path\downloads"
```

## What Counts as Success

Treat the submission as successful only when:

- `submit_id` is present
- `gen_status` is `querying` or `success`

Treat the task as failed when:

- `gen_status` is `fail`
- `fail_reason` is present
- the CLI returns `AigcComplianceConfirmationRequired`

If the CLI asks for compliance confirmation, tell the user to finish that one-time web authorization first and then retry.

## Helper Script

Use [scripts/submit_dreamina_video.ps1](../scripts/submit_dreamina_video.ps1) when you want one reusable command that:

- assembles the `multimodal2video` submit call
- keeps source and board image order stable
- stores `submit_id`
- polls `query_result`
- downloads finished media to a local directory
