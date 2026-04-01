# AI Audio Generation Services

> AI-powered music and SFX generation for Pendulum of Despair.
> Researched March 2026. This space changes rapidly — verify all
> pricing, licensing, and capabilities before committing.

## Quick Recommendation

For a SNES-style JRPG targeting authentic 16-bit sound:

- **Best AI music approach:** AIVA (Pro) for composition frameworks
  exported as MIDI, then rendered through SNES soundfonts for authentic
  retro sound. Clear copyright ownership.
- **Best AI SFX approach:** ElevenLabs Sound Effects v2 for complex
  sounds, then post-process with bitcrusher for retro character.
  jsfxr/ChipTone for simple retro blips (not AI, but faster and free).
- **Prototyping/mood exploration:** Suno v5 for quick full-track demos
  to establish mood before final production.

---

## 1. AI Music Generation

### Tier 1: Production-Ready

#### AIVA (aiva.ai) — Best for Game Soundtracks

| Aspect | Details |
|--------|---------|
| **Pricing** | Free (3 downloads/mo, non-commercial) / Standard: EUR 15/mo (15 downloads, social platform use) / **Pro: EUR 49/mo** (300 downloads, full copyright ownership) |
| **Copyright** | **Pro plan: you own full copyright.** Standard: AIVA owns copyright. Free: non-commercial only. |
| **Output formats** | MP3, MIDI, WAV (Pro gets all formats) |
| **Max duration** | 5.5 minutes per track (Pro) |
| **SNES/retro style** | Not directly — orchestral/cinematic focus. But MIDI export lets you render through SNES soundfonts for authentic retro sound. |
| **Looping** | MIDI export means you can edit loop points in a DAW |
| **Game music focus** | Explicitly markets to game developers. Emotional, score-like compositions. |
| **Risk level** | LOW — trained on licensed/public domain data. Clearest copyright model. |

**Why AIVA for this project:** The MIDI export workflow is the killer
feature. Generate a composition in AIVA, export MIDI, load into a DAW
with SNES soundfonts, render as OGG. You get AI-speed composition with
authentic 16-bit instrument sound. No copyright concerns on Pro plan.

#### Suno (suno.com) — Best for Full Track Generation

| Aspect | Details |
|--------|---------|
| **Pricing** | Free (50 credits/day, ~10 songs, non-commercial) / **Pro: $10/mo** (2,500 credits, ~500 songs) / Premier: $30/mo (10,000 credits) |
| **Copyright** | Pro/Premier: commercial use rights, you own output. Free: Suno owns it. Output "may not be eligible for copyright protection." |
| **Model** | v5 (late 2025) — significant quality leap in arrangement and genre accuracy |
| **SNES/retro style** | Can attempt with specific prompts. Results vary — tends toward modern production quality. |
| **Looping** | No native loop support. Must post-process. |
| **Risk level** | MEDIUM — Warner settled (partnership formed). Copyright litigation largely resolved but AI-generated works may not be copyrightable. |

**Prompt strategy for SNES style:** "SNES RPG battle theme, 16-bit
synthesizer, no vocals, fast tempo 140bpm, heroic melody, chiptune
instruments, retro game soundtrack." Cherry-pick from many generations.

#### ElevenLabs Sound Effects v2 — Best for SFX

| Aspect | Details |
|--------|---------|
| **Pricing** | Free tier available / Paid plans for commercial use |
| **Quality** | Current leader — rated indistinguishable from recorded foley in blind tests |
| **Features** | Up to 30 seconds, 48kHz, **seamless looping**, improved prompt adherence |
| **Retro SFX** | Can generate retro-styled sounds with prompting. Post-process for authentic chiptune. |
| **Commercial license** | Included in paid plans. Clear terms. |
| **Game integration** | Layer partnership for direct game studio integration |
| **Risk level** | LOW — clear commercial terms, no copyright litigation. |

**Best for:** Complex/environmental SFX (spell effects, ambient sounds,
boss phase transitions). For simple retro blips, jsfxr is faster and free.

### Tier 2: Supplementary

#### Soundraw (soundraw.io)

| Aspect | Details |
|--------|---------|
| **Pricing** | ~$17/mo subscription |
| **Customization** | Slider-based: mood, tempo, instruments, section editing |
| **SNES style** | Limited. More modern pop/electronic/ambient. |
| **Commercial license** | Included in subscription |
| **Best for** | Background/ambient music where you need precise mood control |

#### Stable Audio 3.0 (Stability AI)

| Aspect | Details |
|--------|---------|
| **Pricing** | Free tier / Paid for commercial |
| **Features** | Up to 180 seconds (longest generation). Open-source base model. |
| **SNES style** | Via prompting. Better for atmospheric than structured compositions. |
| **Commercial license** | Paid tier. Open model can be self-hosted. |
| **Best for** | Ambient soundscapes and atmospheric audio beds. Can fine-tune on custom libraries. |

#### Meta MusicGen (open source)

| Aspect | Details |
|--------|---------|
| **Pricing** | Free (self-hosted) |
| **Features** | Melody-conditioned generation (feed it a melody, it builds around it) |
| **SNES style** | Variable via prompting |
| **Commercial license** | Check model variant (some CC-BY-NC, some commercial) |
| **Best for** | Self-hosted generation with no ongoing costs or API dependency |

### Tier 3: Not Recommended for This Project

| Service | Why Not |
|---------|---------|
| Udio | Downloads disabled during 2025-2026 licensing transition. Check current status. |
| Google MusicFX | Not licensed for commercial use. Research tool only. |
| Mubert | Real-time generative ambient. Wrong tool for composed JRPG soundtrack. |
| Boomy | Social media focused. Not for game soundtracks. |

---

## 2. AI SFX Generation

| Service | Quality | Retro SFX | Commercial | Best For |
|---------|---------|-----------|------------|----------|
| **ElevenLabs SFX v2** | Excellent (leader) | Via prompting + post-process | Yes (paid) | Complex sounds, ambient, looping |
| **Stable Audio 3.0** | Good | Via prompting | Yes (paid) | Long ambient (180s max), atmospheric |
| **Meta AudioCraft** | Decent | Via prompting | Check variant | Self-hosted, no per-generation cost |

**For authentic retro SFX:** AI generation + bitcrusher post-processing
in Audacity. Or skip AI entirely and use jsfxr/ChipTone (faster, free,
purpose-built for retro game SFX).

---

## 3. Recommended Workflows for Pendulum of Despair

### Workflow A: AI-Assisted Composition (Recommended)

```
AIVA (Pro, EUR 49/mo)
  → Generate compositions matching music.md track descriptions
  → Export as MIDI
  → Load MIDI in DAW (LMMS, OpenMPT) with SNES soundfonts
  → Render as OGG Vorbis
  → Post-process: compression, EQ for SNES character
  → Result: AI-composed, authentically SNES-sounding tracks
```

**Cost:** ~EUR 49/mo during production. Cancel when soundtrack complete.
**Copyright:** Full ownership on Pro plan.
**Authenticity:** High — SNES soundfonts provide the actual instrument
sounds from the hardware.

### Workflow B: Direct AI Generation (Fast Prototyping)

```
Suno v5 (Pro, $10/mo)
  → Generate tracks with detailed SNES/JRPG prompts
  → Cherry-pick best results from many generations
  → Post-process: bitcrush, downsample for retro character
  → Edit loop points in Audacity
  → Result: Quick, varied, but less authentically retro
```

**Cost:** $10/mo. Very high output volume (500 tracks/mo).
**Copyright:** Commercial use rights but output may not be copyrightable.
**Authenticity:** Medium — sounds more like "retro-inspired modern" than
authentic SNES.

### Workflow C: Hybrid (Best Quality)

```
Phase 1: Suno for mood exploration ($10/mo)
  → Generate 10-20 variations per track in music.md
  → Identify which compositions "feel right"

Phase 2: AIVA for refined composition (EUR 49/mo)
  → Use Suno favorites as reference mood
  → Generate structured MIDI compositions in AIVA
  → Export MIDI

Phase 3: Human finishing
  → Load MIDI in DAW with SNES soundfonts
  → Adjust instrumentation to match music.md faction palettes
  → Set loop points
  → Render OGG, post-process
```

### Workflow D: SFX Pipeline

```
Simple retro SFX (UI, pickups, blips):
  → jsfxr / ChipTone (free, instant, purpose-built)
  → Export WAV, convert to OGG

Complex SFX (spells, ambient, boss events):
  → ElevenLabs SFX v2 (paid plan)
  → Prompt: "retro 16-bit [description], short and punchy"
  → Post-process: bitcrush in Audacity for SNES character
  → Convert to OGG

Environmental/narrative SFX:
  → ElevenLabs or Stable Audio for ambient loops
  → Match to biome descriptions in audio.md Section 2.1
```

---

## 4. Key Considerations

### Copyright & Legal

- **Safest:** AIVA Pro (explicit copyright ownership, trained on
  licensed data)
- **Acceptable:** Suno Pro/Premier (commercial rights, lawsuits
  settled with Warner partnership), ElevenLabs (clear terms)
- **Risky:** Udio (licensing transition ongoing), free tier of any
  service (no commercial rights)
- **AI-generated works may not be copyrightable** in many jurisdictions.
  This means competitors could legally copy your AI soundtrack. For a
  unique game identity, consider AI-composed + human-finished.

### Quality for a Shipped Indie Game

- **Good enough today:** AIVA + SNES soundfonts (Workflow A), Suno v5
  with heavy curation (Workflow B)
- **Best quality:** Hybrid workflow (C) — AI speed + human finishing
- **Honest assessment:** For "FF6/Chrono Trigger quality" soundtracks,
  pure AI generation will likely disappoint. AI-assisted human
  composition or AI + significant curation is the realistic path.

### Looping Audio

No AI service produces seamless game loops natively. You must:
- Generate longer tracks and find natural loop points
- Use audio editing to create seamless loops
- Or use MIDI output (AIVA) and create loops in a DAW

### Budget Estimate

| Approach | Monthly Cost | Duration | Total |
|----------|-------------|----------|-------|
| AIVA Pro only | EUR 49 | 2-3 months | EUR 100-150 |
| Suno Pro only | $10 | 1-2 months | $10-20 |
| Hybrid (Suno + AIVA) | ~$60 | 2-3 months | $120-180 |
| ElevenLabs for SFX | ~$10-30 | 1 month | $10-30 |
| jsfxr + ChipTone for SFX | Free | N/A | $0 |

Sources:
- [Suno Pricing](https://suno.com/pricing)
- [AIVA Review 2026](https://singify.fineshare.com/blog/ai-music-apps/aiva)
- [Best AI Music Generators 2026](https://jam.com/resources/best-ai-music-generators-2026)
- [ElevenLabs Sound Effects](https://elevenlabs.io/sound-effects)
- [AI Sound Effects Guide 2026](https://www.aimagicx.com/blog/ai-sound-effects-generation-foley-guide-2026)
- [itch.io 16-bit Music](https://itch.io/game-assets/tag-16-bit/tag-music)
- [itch.io Chiptune Assets](https://itch.io/game-assets/tag-chiptune)
