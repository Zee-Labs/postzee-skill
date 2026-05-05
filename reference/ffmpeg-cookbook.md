# ffmpeg Cookbook — Professional Video Composition

When the agent has shell access, ffmpeg unlocks professional-grade video composition: combining clips, adding transitions, mixing audio, normalizing loudness, converting aspect ratios, burning subtitles, applying effects.

**This is what separates "AI generated a clip" from "we produced a video."**

---

## Detect ffmpeg availability

Before any ffmpeg work, verify:

```bash
ffmpeg -version 2>/dev/null | head -n 1
# If empty/error, ffmpeg not available → use AI tools only

ffmpeg -filters 2>/dev/null | grep -E "(xfade|loudnorm|subtitles)"
# Verifies the filters we'll use exist
```

If unavailable, tell user: "Não tenho acesso a ffmpeg neste ambiente — vou produzir os clips individualmente e você combina externamente."

---

## Section 1 — Basic operations

### Trim / cut a clip

```bash
ffmpeg -ss 00:00:05 -i input.mp4 -t 00:00:10 -c copy output.mp4
# -ss = start time, -t = duration. -c copy = no re-encode (fast, lossless)

# For frame-accurate trimming (re-encode):
ffmpeg -ss 5 -i input.mp4 -t 10 -c:v libx264 -preset slow -crf 18 -c:a aac output.mp4
```

### Convert format / codec

```bash
# To H.264 + AAC (broadest compatibility)
ffmpeg -i input.mov -c:v libx264 -preset medium -crf 23 -c:a aac -b:a 192k output.mp4

# To VP9 + Opus (web-optimized)
ffmpeg -i input.mp4 -c:v libvp9 -crf 30 -c:a libopus output.webm

# CRF guide: 18 (visually lossless) → 23 (good) → 28 (web-acceptable) → 35 (low quality)
```

### Extract audio

```bash
ffmpeg -i input.mp4 -vn -c:a copy output.aac     # keep original codec
ffmpeg -i input.mp4 -vn -c:a libmp3lame -b:a 192k output.mp3
```

### Extract a single frame

```bash
ffmpeg -ss 00:00:03 -i input.mp4 -vframes 1 -q:v 2 thumbnail.jpg
# -q:v 2 = high quality JPEG. Use 1 for max.
```

### Get video info

```bash
ffprobe -v error -show_entries format=duration,size,bit_rate \
  -show_entries stream=codec_name,width,height,r_frame_rate \
  -of json input.mp4

# Quick duration:
ffprobe -v error -show_entries format=duration -of csv=p=0 input.mp4
```

---

## Section 2 — Concatenation (joining clips)

### Method 1: concat demuxer (when codecs match — fast, lossless)

```bash
# Create file list
cat > concat_list.txt << EOF
file 'scene1.mp4'
file 'scene2.mp4'
file 'scene3.mp4'
EOF

ffmpeg -f concat -safe 0 -i concat_list.txt -c copy output.mp4
```

**Use when:** all clips have identical codec, resolution, framerate.

### Method 2: concat filter (when codecs/resolutions differ — re-encodes)

```bash
ffmpeg -i scene1.mp4 -i scene2.mp4 -i scene3.mp4 \
  -filter_complex "[0:v][0:a][1:v][1:a][2:v][2:a]concat=n=3:v=1:a=1[outv][outa]" \
  -map "[outv]" -map "[outa]" \
  -c:v libx264 -preset medium -crf 20 -c:a aac -b:a 192k output.mp4
```

**Use when:** clips have different formats. Slower but always works.

### Method 3: pre-normalize then concat (recommended for AI clips)

AI-generated clips often have varying framerates / codecs. Normalize first:

```bash
# Normalize each clip to same spec
for clip in scene1.mp4 scene2.mp4 scene3.mp4; do
  ffmpeg -i "$clip" -vf "scale=1080:1920,fps=30" \
    -c:v libx264 -preset medium -crf 20 \
    -c:a aac -b:a 192k -ar 48000 \
    "norm_$clip"
done

# Then concat with method 1 (fast)
```

---

## Section 3 — Transitions (xfade)

xfade adds professional crossfade transitions between clips.

### Single transition

```bash
ffmpeg -i scene1.mp4 -i scene2.mp4 \
  -filter_complex "[0:v][1:v]xfade=transition=fade:duration=0.5:offset=4.5[v]; \
                   [0:a][1:a]acrossfade=d=0.5[a]" \
  -map "[v]" -map "[a]" \
  -c:v libx264 -crf 20 -c:a aac output.mp4
```

- `offset=4.5` = transition starts at 4.5s in scene1 (scene1 must be 5s for 0.5s overlap)
- `duration=0.5` = transition lasts 0.5s

### Available xfade transitions

```
fade           — classic crossfade
fadeblack      — fade through black
fadewhite      — fade through white
slideleft      — scene2 slides in from right
slideright     — scene2 slides in from left
slideup        — scene2 slides in from below
slidedown      — scene2 slides in from above
wipeleft       — wipe edge moves left to right
wiperight      — wipe edge moves right to left
circleopen     — circle expands from center
circleclose    — circle closes to center
zoomin         — zooms into next scene
hlslice        — horizontal slice
hrslice        — horizontal reverse slice
diagtl         — diagonal top-left
diagbr         — diagonal bottom-right
pixelize       — pixelated transition
radial         — radial wipe
```

**Transitions style guide:**
- Stories / lifestyle → `fade`, `slideleft`
- High-energy / TikTok → `pixelize`, `circleopen`
- Cinematic / dramatic → `fadeblack`, `radial`
- B2B / professional → `fade` (subtle)

### Multi-clip with transitions (chained)

```bash
# 3 clips: A (5s) + B (5s) + C (5s) with 0.5s xfade between each = ~13.5s output

ffmpeg -i A.mp4 -i B.mp4 -i C.mp4 \
  -filter_complex "
    [0:v][1:v]xfade=transition=fade:duration=0.5:offset=4.5[ab];
    [ab][2:v]xfade=transition=fade:duration=0.5:offset=9[v];
    [0:a][1:a]acrossfade=d=0.5[ab_a];
    [ab_a][2:a]acrossfade=d=0.5[a]
  " \
  -map "[v]" -map "[a]" \
  -c:v libx264 -crf 20 -c:a aac output.mp4
```

**Pattern:** offset for second xfade = first_clip_duration + second_clip_duration - 2*transition_duration.

For programmatic generation of N clips, use a script (see "Multi-clip script" below).

---

## Section 4 — Audio mixing

### Add background music

```bash
ffmpeg -i video.mp4 -i music.mp3 \
  -filter_complex "[1:a]volume=0.3[bg]; [0:a][bg]amix=inputs=2:duration=first[a]" \
  -map 0:v -map "[a]" -c:v copy -c:a aac output.mp4
```

- `volume=0.3` = music at 30%
- `duration=first` = output ends when video ends

### Background music with ducking (lowers under speech)

```bash
ffmpeg -i video.mp4 -i music.mp3 \
  -filter_complex "
    [1:a]volume=0.4[bg];
    [0:a][bg]sidechaincompress=threshold=0.05:ratio=8:attack=200:release=1000[a]
  " \
  -map 0:v -map "[a]" -c:v copy -c:a aac output.mp4
```

This lowers the music whenever speech is present (the threshold). Standard radio/podcast technique.

### Replace audio entirely (voiceover)

```bash
ffmpeg -i video.mp4 -i voiceover.mp3 \
  -map 0:v -map 1:a -c:v copy -c:a aac -shortest output.mp4
```

### Mix voiceover + music + ambient

```bash
ffmpeg -i video.mp4 -i voiceover.mp3 -i music.mp3 \
  -filter_complex "
    [1:a]volume=1.0[vo];
    [2:a]volume=0.25[bg];
    [0:a]volume=0.5[amb];
    [vo][bg][amb]amix=inputs=3:duration=first:dropout_transition=0[a]
  " \
  -map 0:v -map "[a]" -c:v copy -c:a aac output.mp4
```

### Loudness normalization (broadcast-ready)

```bash
# Standard for social media: -14 LUFS (Spotify), -16 LUFS (TikTok), -20 (TV)
ffmpeg -i input.mp4 -af "loudnorm=I=-14:TP=-1.5:LRA=11" -c:v copy output.mp4

# Two-pass for accuracy:
ffmpeg -i input.mp4 -af "loudnorm=I=-14:TP=-1.5:LRA=11:print_format=json" -f null - 2>&1 | tail -n 12
# Use the measured values from above output:
ffmpeg -i input.mp4 -af "loudnorm=I=-14:TP=-1.5:LRA=11:measured_I=...:measured_LRA=...:measured_TP=...:measured_thresh=...:offset=...:linear=true" -c:v copy output.mp4
```

**LUFS targets by platform (2026):**
- TikTok / Instagram Reels / Shorts: `-14 LUFS`
- Spotify: `-14 LUFS`
- YouTube: `-14 LUFS`
- Broadcast TV: `-23 LUFS` (EBU R128)

### Fade in / out audio

```bash
# Fade in 1s at start, fade out 2s at end (assuming 30s clip)
ffmpeg -i input.mp4 -af "afade=in:st=0:d=1, afade=out:st=28:d=2" -c:v copy output.mp4
```

---

## Section 5 — Aspect ratio conversion

AI tools often output 16:9 but social platforms want 9:16, 1:1, or 4:5.

### 16:9 → 9:16 (vertical) with blurred background

The cinematic approach: original at center, blurred zoomed copy as background.

```bash
ffmpeg -i input.mp4 -filter_complex "
  [0:v]scale=1080:1920:force_original_aspect_ratio=increase,
       crop=1080:1920,boxblur=20:5[bg];
  [0:v]scale=1080:-1[fg];
  [bg][fg]overlay=(W-w)/2:(H-h)/2
" -c:a copy output_9x16.mp4
```

### 16:9 → 9:16 (vertical) center crop (loses sides)

```bash
ffmpeg -i input.mp4 -vf "crop=ih*9/16:ih,scale=1080:1920" -c:a copy output.mp4
```

### 16:9 → 1:1 (square) center crop

```bash
ffmpeg -i input.mp4 -vf "crop=ih:ih,scale=1080:1080" -c:a copy output.mp4
```

### 16:9 → 4:5 (portrait Instagram)

```bash
ffmpeg -i input.mp4 -vf "crop=ih*4/5:ih,scale=1080:1350" -c:a copy output.mp4
```

### 9:16 → 16:9 (vertical to landscape) with blurred background

```bash
ffmpeg -i vertical.mp4 -filter_complex "
  [0:v]scale=1920:1080:force_original_aspect_ratio=increase,
       crop=1920:1080,boxblur=30:5[bg];
  [0:v]scale=-1:1080[fg];
  [bg][fg]overlay=(W-w)/2:(H-h)/2
" -c:a copy output_16x9.mp4
```

### Letterbox / pillarbox (preserve original)

```bash
# 16:9 → 1:1 with black bars (top/bottom)
ffmpeg -i input.mp4 -vf "scale=1080:608,pad=1080:1080:0:236:black" -c:a copy output.mp4
```

---

## Section 6 — Effects

### Ken Burns effect (slow zoom + pan on still image)

```bash
ffmpeg -loop 1 -i image.jpg -t 5 -filter_complex "
  zoompan=z='min(zoom+0.0015,1.5)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=125:s=1080x1920
" -c:v libx264 -crf 20 -pix_fmt yuv420p output.mp4
```

- `0.0015` per frame = subtle zoom
- `d=125` = duration in frames (125 frames @ 25fps = 5s)
- `s=1080x1920` = output size

### Slow motion / speed up

```bash
# 2x slow motion (with audio pitch correction)
ffmpeg -i input.mp4 -filter_complex "[0:v]setpts=2.0*PTS[v]; [0:a]atempo=0.5[a]" \
  -map "[v]" -map "[a]" output.mp4

# 2x speed up
ffmpeg -i input.mp4 -filter_complex "[0:v]setpts=0.5*PTS[v]; [0:a]atempo=2.0[a]" \
  -map "[v]" -map "[a]" output.mp4

# atempo range: 0.5 to 100. For more extreme: chain like atempo=0.5,atempo=0.5
```

### Color grading

```bash
# Boost saturation + contrast (TikTok-style pop)
ffmpeg -i input.mp4 -vf "eq=saturation=1.4:contrast=1.1:brightness=0.02" -c:a copy output.mp4

# Cinematic teal-orange
ffmpeg -i input.mp4 -vf "
  curves=preset=increase_contrast,
  colorbalance=rs=-0.1:bs=0.1:gs=0:rm=0:bm=-0.05:gm=0:rh=0.1:bh=-0.1
" -c:a copy output.mp4

# Black and white
ffmpeg -i input.mp4 -vf "hue=s=0" -c:a copy output.mp4

# Sepia
ffmpeg -i input.mp4 -vf "
  colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131
" -c:a copy output.mp4
```

### Picture-in-picture overlay

```bash
ffmpeg -i background.mp4 -i overlay.mp4 -filter_complex "
  [1:v]scale=480:-1[pip];
  [0:v][pip]overlay=W-w-20:20
" -c:a copy output.mp4
# PIP positioned 20px from top-right corner, 480px wide
```

### Watermark / logo overlay

```bash
ffmpeg -i input.mp4 -i logo.png -filter_complex "
  [1:v]scale=120:-1[wm];
  [0:v][wm]overlay=W-w-30:H-h-30:format=auto
" -c:a copy output.mp4
# Bottom-right corner, 30px margin
```

### Chroma key (green screen removal)

```bash
ffmpeg -i bg.mp4 -i greenscreen.mp4 -filter_complex "
  [1:v]chromakey=0x00ff00:0.1:0.2[ckout];
  [0:v][ckout]overlay
" output.mp4
# 0x00ff00 = green color, 0.1 = similarity, 0.2 = blend
```

### Reverse playback

```bash
ffmpeg -i input.mp4 -vf reverse -af areverse output.mp4
```

### Boomerang (forward + reverse)

```bash
ffmpeg -i input.mp4 -filter_complex "
  [0:v]split[a][b];
  [b]reverse[r];
  [a][r]concat
" -an output.mp4
```

---

## Section 7 — Subtitles

(See `subtitle-workflows.md` for full Whisper integration.)

### Burn SRT subtitles

```bash
ffmpeg -i video.mp4 -vf "subtitles=captions.srt:force_style='FontName=Arial,FontSize=28,PrimaryColour=&H00FFFFFF,OutlineColour=&H00000000,Outline=2,Alignment=2'" \
  -c:a copy output.mp4
```

**force_style options (ASS format colors are BBGGRR not RGBA):**
- `FontName=Inter` (must be installed)
- `FontSize=28` (in pixels)
- `PrimaryColour=&H00FFFFFF&` (white)
- `OutlineColour=&H00000000&` (black outline)
- `BackColour=&H80000000&` (semi-transparent black bg)
- `BorderStyle=3` (with background box) or `1` (outline only)
- `Outline=2` (outline thickness)
- `Shadow=1`
- `Alignment=2` (bottom-center) — keypad numbering

### Burn ASS subtitles (full karaoke styling)

```bash
ffmpeg -i video.mp4 -vf "ass=captions.ass" -c:a copy output.mp4
```

ASS format supports per-word highlighting, animations, multi-color — the gold standard for trending captions.

### Soft subtitles (toggle-able, not burned)

```bash
ffmpeg -i video.mp4 -i captions.srt -c:v copy -c:a copy -c:s mov_text \
  -metadata:s:s:0 language=por output.mp4
```

---

## Section 8 — Platform-optimized export

### Instagram Reels / TikTok / Shorts (9:16, 1080×1920, 30fps)

```bash
ffmpeg -i input.mp4 -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black,fps=30" \
  -c:v libx264 -preset slow -crf 21 -profile:v high -level 4.0 \
  -c:a aac -b:a 192k -ar 48000 \
  -movflags +faststart \
  -af "loudnorm=I=-14:TP=-1.5:LRA=11" \
  output_reels.mp4
```

### Instagram Feed (1:1 or 4:5, 1080×1080 or 1080×1350)

```bash
ffmpeg -i input.mp4 -vf "scale=1080:1080:force_original_aspect_ratio=decrease,pad=1080:1080:(ow-iw)/2:(oh-ih)/2:black,fps=30" \
  -c:v libx264 -preset slow -crf 22 \
  -c:a aac -b:a 192k \
  -movflags +faststart \
  output_feed.mp4
```

### YouTube (16:9, 1080p, 30fps)

```bash
ffmpeg -i input.mp4 -vf "scale=1920:1080,fps=30" \
  -c:v libx264 -preset slow -crf 20 -profile:v high -level 4.2 \
  -c:a aac -b:a 384k -ar 48000 \
  -movflags +faststart \
  -af "loudnorm=I=-14:TP=-1:LRA=11" \
  output_yt.mp4
```

### LinkedIn (1:1 or 16:9, max 200MB)

```bash
ffmpeg -i input.mp4 -vf "scale=1080:1080:force_original_aspect_ratio=decrease,pad=1080:1080:(ow-iw)/2:(oh-ih)/2:black,fps=30" \
  -c:v libx264 -preset slow -crf 23 \
  -c:a aac -b:a 128k \
  -movflags +faststart \
  output_li.mp4
```

### X / Twitter (16:9 or 1:1, max 2:20 duration, 512MB)

```bash
ffmpeg -i input.mp4 -vf "scale=1280:720,fps=30" \
  -c:v libx264 -preset medium -crf 23 \
  -c:a aac -b:a 128k \
  -movflags +faststart \
  output_x.mp4
```

---

## Section 9 — Multi-clip script (programmatic)

For chaining 4+ AI-generated clips with transitions:

```bash
#!/bin/bash
# Usage: ./compose.sh clip1.mp4 clip2.mp4 clip3.mp4 ... output.mp4

CLIPS=("$@")
OUTPUT="${CLIPS[-1]}"
unset 'CLIPS[${#CLIPS[@]}-1]'

XFADE_DURATION=0.5
TRANSITION="fade"

# Get duration of each clip
DURATIONS=()
for clip in "${CLIPS[@]}"; do
  d=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$clip")
  DURATIONS+=("$d")
done

# Build filter_complex chain
INPUTS=""
FILTER=""
for i in "${!CLIPS[@]}"; do
  INPUTS+="-i ${CLIPS[$i]} "
done

# Calculate cumulative offsets
PREV_TAG="[0:v]"
PREV_AUDIO_TAG="[0:a]"
CUMULATIVE_OFFSET=0

for ((i=1; i<${#CLIPS[@]}; i++)); do
  PREV_DUR=${DURATIONS[$((i-1))]}
  CUMULATIVE_OFFSET=$(echo "$CUMULATIVE_OFFSET + $PREV_DUR - $XFADE_DURATION" | bc -l)
  
  TAG_OUT="[v$i]"
  AUDIO_OUT="[a$i]"
  
  FILTER+="${PREV_TAG}[${i}:v]xfade=transition=${TRANSITION}:duration=${XFADE_DURATION}:offset=${CUMULATIVE_OFFSET}${TAG_OUT};"
  FILTER+="${PREV_AUDIO_TAG}[${i}:a]acrossfade=d=${XFADE_DURATION}${AUDIO_OUT};"
  
  PREV_TAG="${TAG_OUT}"
  PREV_AUDIO_TAG="${AUDIO_OUT}"
done

# Strip trailing semicolon
FILTER="${FILTER%;}"
FINAL_V="${PREV_TAG}"
FINAL_A="${PREV_AUDIO_TAG}"

ffmpeg $INPUTS -filter_complex "$FILTER" \
  -map "$FINAL_V" -map "$FINAL_A" \
  -c:v libx264 -preset medium -crf 20 \
  -c:a aac -b:a 192k \
  "$OUTPUT"
```

---

## Section 10 — Common composition recipes

### Recipe: 3-scene story with intro + transitions + bg music + subtitles

```bash
# Step 1: normalize all scenes
for s in scene1 scene2 scene3; do
  ffmpeg -i "${s}.mp4" -vf "scale=1080:1920,fps=30" \
    -c:v libx264 -preset medium -crf 20 \
    -c:a aac -b:a 192k -ar 48000 \
    "norm_${s}.mp4"
done

# Step 2: chain with crossfades (assume each is 5s)
ffmpeg -i norm_scene1.mp4 -i norm_scene2.mp4 -i norm_scene3.mp4 \
  -filter_complex "
    [0:v][1:v]xfade=transition=fade:duration=0.5:offset=4.5[ab];
    [ab][2:v]xfade=transition=fade:duration=0.5:offset=9[v];
    [0:a][1:a]acrossfade=d=0.5[ab_a];
    [ab_a][2:a]acrossfade=d=0.5[a]
  " \
  -map "[v]" -map "[a]" \
  -c:v libx264 -crf 20 -c:a aac \
  combined.mp4

# Step 3: add bg music with ducking
ffmpeg -i combined.mp4 -i music.mp3 \
  -filter_complex "
    [1:a]volume=0.4[bg];
    [0:a][bg]sidechaincompress=threshold=0.05:ratio=8:attack=200:release=1000[a]
  " \
  -map 0:v -map "[a]" -c:v copy -c:a aac \
  with_music.mp4

# Step 4: burn subtitles
ffmpeg -i with_music.mp4 \
  -vf "subtitles=captions.srt:force_style='FontName=Inter,FontSize=32,PrimaryColour=&H00FFFFFF,OutlineColour=&H00000000,BorderStyle=3,Outline=2,Alignment=2,MarginV=80'" \
  -c:a copy \
  final.mp4

# Step 5: loudness normalize
ffmpeg -i final.mp4 -af "loudnorm=I=-14:TP=-1.5:LRA=11" -c:v copy output.mp4
```

### Recipe: vertical Reel from 16:9 source

```bash
ffmpeg -i source_16x9.mp4 -filter_complex "
  [0:v]scale=1080:1920:force_original_aspect_ratio=increase,
       crop=1080:1920,boxblur=20:5[bg];
  [0:v]scale=1080:-1[fg];
  [bg][fg]overlay=(W-w)/2:(H-h)/2,fps=30
" -c:v libx264 -crf 21 -preset slow -c:a aac -b:a 192k -movflags +faststart reel.mp4
```

### Recipe: cinematic intro (logo reveal + tagline)

```bash
# 3s logo with Ken Burns + text overlay
ffmpeg -loop 1 -i logo.png -t 3 -filter_complex "
  zoompan=z='min(zoom+0.001,1.2)':d=90:s=1920x1080,
  drawtext=text='Your Tagline Here':fontfile=/path/to/Inter-Bold.ttf:fontsize=64:fontcolor=white:x=(w-text_w)/2:y=h-200:enable='between(t,1,3)'
" -c:v libx264 -crf 18 -pix_fmt yuv420p -an intro.mp4
```

---

## Common errors and fixes

### "Stream specifier ':a' in filtergraph description matches no streams"
→ The clip has no audio. Use `-an` flag or generate silent audio:
```bash
ffmpeg -i video.mp4 -f lavfi -i anullsrc -shortest -c:v copy -c:a aac with_audio.mp4
```

### "non-monotonic DTS in output stream"
→ Add `-fflags +genpts` after `-i` flags.

### "Different framerates between clips"
→ Pre-normalize all to same fps with `-vf fps=30`.

### "Audio sync drift after concat"
→ Use `-async 1` or pre-resample audio: `-ar 48000`.

### "filter_complex syntax error"
→ Don't use newlines inside the filter string in some shell setups. Single-line it or escape properly.

---

## Performance tips

- **`-preset ultrafast`** during testing, **`-preset slow`** for final
- **`-crf 23`** is web standard, lower = better quality + bigger file
- **`-movflags +faststart`** moves metadata to file start → instant playback in browsers
- **Hardware encoders**: `h264_videotoolbox` (Mac), `h264_nvenc` (NVIDIA), `h264_qsv` (Intel) — 5-10x faster, slight quality loss

---

## Quick reference card

| Task | Command core |
|------|-------------|
| Concat | `ffmpeg -f concat -safe 0 -i list.txt -c copy out.mp4` |
| Crossfade | `xfade=transition=fade:duration=0.5:offset=N` |
| Vertical from 16:9 | `crop=ih*9/16:ih,scale=1080:1920` |
| Add music | `amix=inputs=2:duration=first` |
| Duck music | `sidechaincompress=threshold=0.05:ratio=8` |
| Normalize loudness | `loudnorm=I=-14:TP=-1.5:LRA=11` |
| Burn SRT | `subtitles=cap.srt:force_style='...'` |
| Slow motion 2x | `setpts=2.0*PTS, atempo=0.5` |
| Ken Burns | `zoompan=z='min(zoom+0.0015,1.5)':d=125` |
