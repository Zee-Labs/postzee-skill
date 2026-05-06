# Subtitle Workflows — Whisper to Trending Captions

Subtitles are non-negotiable in 2026. **85%+ of social video is watched muted.** This guide covers transcription with Whisper variants and burn-in styles that drive engagement.

---

## Workflow overview

```
1. EXTRACT AUDIO         → ffmpeg -i video.mp4 -vn audio.wav
2. TRANSCRIBE            → Whisper / WhisperX → SRT or word-level JSON
3. STYLE                 → Convert to ASS for advanced styles, or styled SRT
4. BURN-IN               → ffmpeg + subtitles= or ass= filter
5. EXPORT                → Platform-optimized
```

---

## Section 1 — Audio extraction

```bash
# Best quality WAV for transcription (16kHz mono is sufficient for Whisper)
ffmpeg -i video.mp4 -vn -acodec pcm_s16le -ar 16000 -ac 1 audio.wav

# Or compressed for upload to API
ffmpeg -i video.mp4 -vn -acodec libopus -b:a 64k audio.opus
```

---

## Section 2 — Transcription engines

### Whisper.cpp (local, fast, no GPU required)

```bash
# Install (Mac)
brew install whisper-cpp

# Download model (one-time)
# Models: tiny, base, small, medium, large-v3 (latest = best)
bash ./models/download-ggml-model.sh large-v3

# Transcribe with SRT output
whisper-cli -m models/ggml-large-v3.bin -f audio.wav -osrt -of captions

# Output: captions.srt
```

**Model size guide:**
- `tiny` (75MB) — fast, English-only viable, multilingual rough
- `base` (142MB) — fast, decent multilingual
- `small` (466MB) — good balance ⭐
- `medium` (1.5GB) — high quality
- `large-v3` (3GB) — **best quality**, slowest ⭐

**Speed (M2 Mac, 60s audio):**
- tiny: ~3s
- base: ~5s
- small: ~12s
- medium: ~30s
- large-v3: ~60s

### faster-whisper (Python, 4x faster than openai-whisper)

```bash
pip install faster-whisper

python -c "
from faster_whisper import WhisperModel

model = WhisperModel('large-v3', device='cpu', compute_type='int8')
segments, info = model.transcribe('audio.wav', beam_size=5, language='pt')

print(f'Language: {info.language} (prob: {info.language_probability})')
for s in segments:
    print(f'[{s.start:.2f}s -> {s.end:.2f}s] {s.text}')
"
```

### WhisperX (word-level timestamps — for trending caption styles)

```bash
pip install whisperx

# Word-level timestamps (essential for "highlighted word" style)
whisperx audio.wav --model large-v3 --output_format srt --output_format json \
  --align_model WAV2VEC2_ASR_LARGE_LV60K_960H \
  --language pt
```

WhisperX gives precise per-word timing, enabling these styles:
- Single-word captions (one word at a time)
- Karaoke (highlight current word)
- Type-on (words appear letter-by-letter)

### OpenAI Whisper API (cloud, simplest)

```bash
curl https://api.openai.com/v1/audio/transcriptions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: multipart/form-data" \
  -F file="@audio.wav" \
  -F model="whisper-1" \
  -F response_format="srt" \
  -F language="pt" \
  > captions.srt
```

Cost: $0.006/minute. Fast, no local install needed.

---

## Section 3 — Caption styles (2026 trending)

Pick based on platform and content type.

### Style 1 — Standard (broadcast-quality)

**Look:** white text, black outline, bottom of screen.
**Best for:** YouTube, LinkedIn, professional content.

```bash
ffmpeg -i video.mp4 -vf "subtitles=captions.srt:force_style='\
FontName=Inter,\
FontSize=28,\
PrimaryColour=&H00FFFFFF,\
OutlineColour=&H00000000,\
Outline=2,\
Shadow=1,\
Alignment=2,\
MarginV=60'" \
-c:a copy output.mp4
```

### Style 2 — TikTok / Reels (background box)

**Look:** white text on solid colored box, centered, large.
**Best for:** TikTok, Instagram Reels, Shorts.

```bash
ffmpeg -i video.mp4 -vf "subtitles=captions.srt:force_style='\
FontName=Arial Black,\
FontSize=42,\
PrimaryColour=&H00FFFFFF,\
BackColour=&H80000000,\
BorderStyle=4,\
Outline=10,\
Shadow=0,\
Alignment=2,\
MarginV=200'" \
-c:a copy output.mp4
```

`BorderStyle=4` adds a box. `Outline=10` is the box padding.

### Style 3 — Highlighted-word (most viral)

**Look:** all words white, current word bright (yellow/green/orange).
**Best for:** TikTok virality, dynamic content.
**Requires:** word-level timestamps from WhisperX → ASS conversion.

```python
# convert_to_ass.py
import json

def whisperx_to_ass(json_file, output_ass, highlight_color="&H0000FFFF&"):
    """Convert WhisperX word-level JSON to ASS with highlighted-word style."""
    with open(json_file) as f:
        data = json.load(f)
    
    header = f"""[Script Info]
ScriptType: v4.00+
PlayResX: 1080
PlayResY: 1920

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,Inter,48,&H00FFFFFF,&H00FFFFFF,&H00000000,&H00000000,1,0,0,0,100,100,0,0,1,3,0,2,40,40,200,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""
    
    events = []
    for segment in data['segments']:
        words = segment.get('words', [])
        for i, word in enumerate(words):
            start = format_time(word['start'])
            end = format_time(word['end'])
            
            # Build sentence with current word highlighted
            line = ""
            for j, w in enumerate(words):
                if j == i:
                    line += f"{{\\c{highlight_color}\\fs60}}{w['word']}{{\\r}} "
                else:
                    line += f"{w['word']} "
            
            events.append(f"Dialogue: 0,{start},{end},Default,,0,0,0,,{line.strip()}")
    
    with open(output_ass, 'w') as f:
        f.write(header)
        f.write('\n'.join(events))

def format_time(seconds):
    h = int(seconds // 3600)
    m = int((seconds % 3600) // 60)
    s = seconds % 60
    return f"{h}:{m:02d}:{s:05.2f}"

whisperx_to_ass('captions.json', 'captions.ass', highlight_color="&H0000FFFF&")
```

```bash
ffmpeg -i video.mp4 -vf "ass=captions.ass" -c:a copy output.mp4
```

### Style 4 — Single-word (one word at a time)

**Look:** ONE word fills the screen, swaps every word.
**Best for:** Hooks, high-energy content, MrBeast-style.
**Requires:** word-level timestamps.

```python
# single_word_ass.py
import json

def whisperx_to_single_word_ass(json_file, output_ass):
    with open(json_file) as f:
        data = json.load(f)
    
    header = """[Script Info]
ScriptType: v4.00+
PlayResX: 1080
PlayResY: 1920

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, OutlineColour, Outline, Shadow, Alignment, MarginV
Style: Big,Inter,120,&H00FFFFFF,&H00000000,4,2,5,0

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""
    events = []
    for segment in data['segments']:
        for word in segment.get('words', []):
            start = format_time(word['start'])
            end = format_time(word['end'])
            text = word['word'].strip().upper()  # uppercase for impact
            events.append(f"Dialogue: 0,{start},{end},Big,,0,0,0,,{text}")
    
    with open(output_ass, 'w') as f:
        f.write(header)
        f.write('\n'.join(events))

def format_time(seconds):
    h = int(seconds // 3600)
    m = int((seconds % 3600) // 60)
    s = seconds % 60
    return f"{h}:{m:02d}:{s:05.2f}"
```

### Style 5 — Karaoke (word-by-word with color sweep)

**Look:** sentence visible, color sweeps across as words are spoken.
**Best for:** Music videos, lyric videos, podcasts.

```
Dialogue: 0,0:00:00.00,0:00:03.00,Default,,0,0,0,,{\k50}This {\k30}is {\k40}karaoke {\k60}style!
```

`{\k50}` = current word highlighted for 50 centiseconds (0.5s).

Generate from word-level timestamps where `\k` value = (word_end - word_start) × 100.

### Style 6 — Type-on (typewriter effect)

**Look:** words appear character-by-character as they're spoken.
**Best for:** Suspense, dramatic reveals.

```
Dialogue: 0,0:00:00.00,0:00:03.00,Default,,0,0,0,,{\t(0,500,\fscx100\fscy100)}T{\t(500,1000,\fscx100\fscy100)}y{\t(1000,1500,\fscx100\fscy100)}p{\t(1500,2000,\fscx100\fscy100)}e
```

Or simpler — incremental visibility per word using `\alpha` transparency animation.

### Style 7 — Two-line vertical (TikTok 2026 trend)

**Look:** 2 lines max, large, centered, bouncy emphasis on key words.

```
Style: Bouncy,Inter Black,52,&H00FFFFFF,&H00000000,4,2,2,200
```

With per-word `\fscx120\fscy120` scale up + back to 100 = bounce.

---

## Section 4 — End-to-end pipeline scripts

### Pipeline A: standard subtitles for any video

```bash
#!/bin/bash
# Usage: ./caption.sh input.mp4 output.mp4

INPUT=$1
OUTPUT=$2
LANG="${3:-pt}"

# 1. Extract audio
ffmpeg -y -i "$INPUT" -vn -acodec pcm_s16le -ar 16000 -ac 1 /tmp/audio.wav

# 2. Transcribe
whisper-cli -m ~/whisper-models/ggml-large-v3.bin \
  -f /tmp/audio.wav -l "$LANG" -osrt -of /tmp/captions

# 3. Burn subtitles
ffmpeg -y -i "$INPUT" -vf "subtitles=/tmp/captions.srt:force_style='\
FontName=Inter,FontSize=32,PrimaryColour=&H00FFFFFF,\
OutlineColour=&H00000000,BorderStyle=3,Outline=2,\
Alignment=2,MarginV=80'" \
-c:a copy "$OUTPUT"

# Cleanup
rm /tmp/audio.wav /tmp/captions.srt
```

### Pipeline B: highlighted-word style (viral TikTok)

```bash
#!/bin/bash
# Requires: whisperx + python + the convert_to_ass.py from above

INPUT=$1
OUTPUT=$2
LANG="${3:-pt}"

# 1. Extract audio
ffmpeg -y -i "$INPUT" -vn -ar 16000 -ac 1 /tmp/audio.wav

# 2. Transcribe with word-level timestamps
whisperx /tmp/audio.wav --model large-v3 \
  --output_dir /tmp \
  --output_format json \
  --language "$LANG" \
  --align_model WAV2VEC2_ASR_LARGE_LV60K_960H

# 3. Convert to highlighted-word ASS
python convert_to_ass.py /tmp/audio.json /tmp/captions.ass

# 4. Burn ASS subtitles
ffmpeg -y -i "$INPUT" -vf "ass=/tmp/captions.ass" -c:a copy "$OUTPUT"

rm /tmp/audio.wav /tmp/audio.json /tmp/captions.ass
```

---

## Section 5 — Caption text rules (regardless of style)

### Length per line/screen
- **TikTok/Reels:** 2-4 words per screen (single-word ideal for hooks)
- **YouTube/LinkedIn:** 5-8 words per line, 1-2 lines per screen
- **Reading speed:** ~21 chars/sec (CPS) is the standard. Don't exceed.

### Formatting
- **All caps for hooks** (first 3-5 words of video)
- **Mixed case for body** (easier to read in long content)
- **Bold key words** if technique allows (highlighted-word, type-on)
- **Numbers as digits** ("3" not "three") — bigger visual hit

### Punctuation
- Drop periods (cleaner look on social)
- Keep question marks and exclamations (carry emotion)
- Use ellipsis `...` for natural pauses

### Position (vertical video 9:16)
- **Bottom-third** but above platform UI (~MarginV=200 for 1920px height)
- **Center-screen** for impact-oriented styles (single-word)
- **NEVER** in top 15% (cropped on some apps)

---

## Section 6 — Multilingual handling

### Same video, multiple languages

```bash
# 1. Transcribe original (e.g., PT)
whisper-cli -m models/large-v3.bin -f audio.wav -l pt -osrt -of captions_pt

# 2. Translate to other languages with Whisper's translate task (always to English)
whisper-cli -m models/large-v3.bin -f audio.wav -l pt --translate -osrt -of captions_en

# 3. For other languages, use a translation API (DeepL, GPT-4, etc.) on captions_pt

# 4. Soft-subtitle them all into a single MP4
ffmpeg -i video.mp4 -i captions_pt.srt -i captions_en.srt -i captions_es.srt \
  -map 0 -map 1 -map 2 -map 3 \
  -c:v copy -c:a copy -c:s mov_text \
  -metadata:s:s:0 language=por \
  -metadata:s:s:1 language=eng \
  -metadata:s:s:2 language=spa \
  output_multi.mp4
```

### Burn-in for one language only

For social, you typically burn the dominant language. Generate one MP4 per market:

```bash
for lang in pt en es fr; do
  ffmpeg -i video.mp4 -vf "subtitles=captions_${lang}.srt" \
    -c:a copy "output_${lang}.mp4"
done
```

---

## Section 7 — Quality control

### Detect transcription errors

After Whisper:

```bash
# Confidence threshold — re-process low-confidence segments manually
whisperx audio.wav --output_format json --print_progress

# Open captions.json and check segments[].avg_logprob
# < -1.0 = likely error, review/edit manually
```

### Manual editing tools

- **Subtitle Edit** (Windows/Mac/Linux): visual SRT/ASS editor
- **OmegaT**: open-source CAT tool for translations
- **Aegisub**: gold standard for ASS karaoke editing

### Validate before burn-in

```bash
# Preview captions overlaid (without permanent burn)
ffplay -vf "subtitles=captions.srt" video.mp4
```

---

## Section 8 — Common errors and fixes

| Issue | Fix |
|-------|-----|
| Captions out of sync | Whisper's `--word_timestamps` + WhisperX alignment |
| Text overflows screen | Reduce FontSize or break lines manually |
| Wrong language detected | Pass `--language pt` explicitly |
| Code-switched content (PT+EN mix) | Use `large-v3` and don't force language |
| Profanity / brand-unsafe words | Post-process SRT with regex replacement |
| Character names mis-transcribed | Use Whisper's `--initial_prompt "Lucas, Postzee, Zee Labs"` |
| Karaoke timing off | Verify ASS `\k` values = centiseconds, not seconds |
| Subtitles unreadable on busy backgrounds | Add `BorderStyle=4` (box) or stronger outline |

---

## Quick reference

| Tool | Speed | Quality | Word timestamps | Cost |
|------|-------|---------|-----------------|------|
| whisper-cli (large-v3) | Slow | Best | Segment only | Free (local) |
| faster-whisper (large-v3) | Fast | Best | Segment only | Free (local) |
| WhisperX | Slow | Best | **Word-level** ⭐ | Free (local) |
| OpenAI Whisper API | Very fast | Best | No | $0.006/min |

| Style | Engine needed | Use case |
|-------|--------------|----------|
| Standard SRT | Any Whisper | Pro content |
| Background box | Any Whisper | TikTok/Reels |
| Highlighted-word | WhisperX | Viral content |
| Single-word | WhisperX | Hooks, MrBeast-style |
| Karaoke | WhisperX | Lyric videos |
| Type-on | WhisperX | Dramatic |
