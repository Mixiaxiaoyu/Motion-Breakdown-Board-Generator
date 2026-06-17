# Dreamina Video Workflow

Read this file when the user wants video generation after approving the motion breakdown board and has confirmed that they are an advanced Dreamina member.

## Membership Gate

- Ask first whether the user is a `高级即梦会员`.
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

Keep the prompt short, explicit, and anchored to the two-image order:

```text
图一角色按照图二 motion breakdown board 的说明生成 8 秒无缝循环动效，镜头固定，保持角色造型、表情、构图和配色一致。主体做轻微呼吸式弹跳，配件与发梢或卷卷做柔软延迟跟随，整体自然回到第一帧。
```

Prompt rules:

- Tell Dreamina that image 1 is the source subject and image 2 is the motion instruction board.
- Say `镜头固定` when the board uses the default locked camera.
- Say `无缝循环` when the board is meant to loop cleanly.
- Re-state the protected identity traits if the subject is brand-sensitive.
- Avoid over-describing the board graphics themselves; the board is guidance, not a style target.

## Manual CLI Flow

1. Log in if needed:

```powershell
.\dreamina.exe login
```

2. Submit the video task:

```powershell
.\dreamina.exe multimodal2video `
  --image "C:\path\source.png" `
  --image "C:\path\motion-board.png" `
  --prompt "图一角色按照图二 motion breakdown board 的说明生成 8 秒无缝循环动效，镜头固定，保持角色造型、表情和配色一致。" `
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
