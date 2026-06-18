# Motion Breakdown Board Spec

Read this file when the motion type is unclear, when the board layout needs more structure, or when a full image-generation prompt must be produced.

## Motion Archetype Hints

- Character or creature image: prefer breathing, blink, hair sway, cloth follow-through, hand or tail drift, weight shift, soft anticipation and settle.
- Product or object image: prefer hover, micro-rotation, parallax between layers, label emphasis, shadow pulse, soft reflection travel only if the material supports it.
- Poster or graphic image: prefer type offset, mask reveal, band sweep, pulse, orbiting accents, depth split, rhythmic oscillation.
- Environment or architecture image: prefer light travel, foliage sway, cloud drift, reflection shimmer, atmospheric layer drift.
- Food, drink, beauty, or liquid image: prefer condensation glint, vapor wisp, liquid wave, gentle orbit, bloom and settle.

Choose one dominant motion family and one supporting motion family. Avoid stacking many unrelated effects.

## Board Composition Rules

- Prefer a 16:9 landscape board unless a portrait source clearly needs a taller layout.
- For tall or full-body character art, prefer a roomier landscape board with taller stage tiles, or switch to a portrait-friendly board if that better preserves the full figure.
- Keep one large source/reference panel.
- Show 6 to 8 numbered motion stages.
- For tall portrait characters, prefer 6 to 7 stages unless the user explicitly wants denser breakdown coverage.
- Keep every stage figure fully inside its panel. No cropped head, hair, sleeves, hands, skirt hem, legs, feet, tail, or accessories.
- Preserve head-to-toe visibility for full-body reference characters unless the user explicitly requests close-up framing.
- Reserve an inner safe margin of roughly 8 to 12 percent around the subject in each stage panel.
- If space becomes tight, shrink the character before shrinking the safe margin.
- If arrows, labels, and callouts compete with the character, move the annotations outward first.
- Give the rightmost and bottom-most stage panels extra breathing room because they are the most likely to be clipped by dense layouts.
- Add arrows, motion paths, ghosted intermediate positions, timing tags, and compact callouts.
- Prefer white or very light arrows for the review board because they read more clearly as motion instruction graphics over saturated imagery.
- If a white arrow risks blending into a bright area, add a subtle darker outline, glow edge, or shadow instead of switching immediately to a saturated arrow color.
- Include a small `0s -> 8s -> 0s` loop timeline.
- Keep the visual language clean, neutral, and professional.
- Make the board look like a motion proposal sheet or animation breakdown board.
- Do not make it look like a movie storyboard, comic strip, or marketing poster.

## Annotation Rules

- Keep each phase label to 2 to 4 words.
- Keep each phase note to one short sentence.
- Use the same language as the user.
- Mark locked elements only when necessary to avoid confusion.
- Show return logic explicitly in the final phase.

## Copy-Ready Image Generation Prompt Template

Use the uploaded image as the reference anchor whenever the tool supports it. Keep the preservation language strong.

```text
Create a professional motion breakdown board / animation explainer board based on the supplied reference image.

Preserve the original subject, silhouette, proportions, composition, brand marks, visible text, costume, product geometry, illustration details, and overall visual identity. Do not redesign the subject.

Output one static presentation board, not a video frame sequence and not a poster.

Design an 8-second seamless loop with a locked camera and break it into {phase_count} key motion stages on a single board.

Board layout:
- one large reference panel
- {phase_count} smaller numbered stages
- white or very light arrows and motion paths
- ghosted overlays to show position changes
- concise callout labels
- timing labels for each phase
- a small 0s to 8s loop timeline

Framing constraints:
- every character instance must be fully visible head-to-toe inside its own panel
- no cropped limbs, hair, sleeves, accessories, or feet
- keep generous inner margins around the subject in each stage tile
- if needed, reduce figure scale to fit the panel cleanly
- prioritize subject completeness over dramatic zoom

Motion concept:
{motion_concept}

Movable elements:
{movable_elements}

Locked elements:
{locked_elements}

Motion keywords:
{motion_keywords}

Avoid:
{avoid}

Stage labels:
1. {phase_1_label} - {phase_1_action}
2. {phase_2_label} - {phase_2_action}
3. {phase_3_label} - {phase_3_action}
4. {phase_4_label} - {phase_4_action}
5. {phase_5_label} - {phase_5_action}
6. {phase_6_label} - {phase_6_action}
7. {phase_7_label} - {phase_7_action}

Visual direction:
clean professional motion design sheet, presentation-ready, precise graphic annotations, strong readability, polished layout, consistent subject across all stages, seamless loop logic visible from the last stage back to the first, full character visibility in all stage panels, balanced spacing, no edge clipping, white or very light motion arrows with subtle outline when needed for contrast

Do not add unrelated scenery, extra characters, cinematic explosions, random particles, unnecessary light streaks, or unrelated FX.
```

## Fallback Note

If the environment cannot generate images, return the filled prompt above in a fenced code block and add one short sentence telling the user to use the uploaded image as the reference image in their generator.
