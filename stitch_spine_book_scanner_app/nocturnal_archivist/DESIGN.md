---
name: Nocturnal Archivist
colors:
  surface: '#151311'
  surface-dim: '#151311'
  surface-bright: '#3c3936'
  surface-container-lowest: '#100e0c'
  surface-container-low: '#1d1b19'
  surface-container: '#221f1d'
  surface-container-high: '#2c2927'
  surface-container-highest: '#373432'
  on-surface: '#e8e1dd'
  on-surface-variant: '#d3c4b2'
  inverse-surface: '#e8e1dd'
  inverse-on-surface: '#33302d'
  outline: '#9c8f7e'
  outline-variant: '#4f4537'
  surface-tint: '#f5bd62'
  primary: '#f5bd62'
  on-primary: '#432c00'
  primary-container: '#c9963f'
  on-primary-container: '#4b3100'
  inverse-primary: '#7f5700'
  secondary: '#add0a7'
  on-secondary: '#19371a'
  secondary-container: '#304e2e'
  on-secondary-container: '#9cbe96'
  tertiary: '#ffb785'
  on-tertiary: '#502400'
  tertiary-container: '#de8b4e'
  on-tertiary-container: '#582900'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdeae'
  primary-fixed-dim: '#f5bd62'
  on-primary-fixed: '#281900'
  on-primary-fixed-variant: '#604100'
  secondary-fixed: '#c8ecc1'
  secondary-fixed-dim: '#add0a7'
  on-secondary-fixed: '#042107'
  on-secondary-fixed-variant: '#304e2e'
  tertiary-fixed: '#ffdcc6'
  tertiary-fixed-dim: '#ffb785'
  on-tertiary-fixed: '#301400'
  on-tertiary-fixed-variant: '#723700'
  background: '#151311'
  on-background: '#e8e1dd'
  surface-variant: '#373432'
typography:
  display-lg:
    fontFamily: Literata
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Literata
    fontSize: 32px
    fontWeight: '500'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Literata
    fontSize: 24px
    fontWeight: '500'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  metadata-caps:
    fontFamily: IBM Plex Mono
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.1em
  label-mono:
    fontFamily: IBM Plex Mono
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 12px
  base: 16px
  lg: 24px
  xl: 32px
  xxl: 48px
---

## Brand & Style
The design system embodies the atmosphere of a quiet, private library at midnight. It rejects the sterility of typical utility apps in favor of a tactile, literary experience. The aesthetic is a blend of **Modern Minimalism** and **Tactile Skeuomorphism**, focusing on the physical qualities of paper, ink, and wood. 

The UI should feel authoritative yet intimate, using deep blacks and parchment tones to evoke a sense of heritage. Interaction design mimics the deliberate movement of handling physical volumes—animations are slow, weighted, and precise. This is an archival tool for the bibliophile, prioritizing the dignity of the physical book over digital convenience.

## Colors
The palette is rooted in a "Noir Bibliophile" aesthetic. The dark mode is the primary experience, utilizing a rich `#12100E` (Obsidian Ink) background that allows the brass accents to glow. 

The **Accent Brass** (`#C9963F`) is reserved for primary actions and focused states, reminiscent of gold-leaf lettering on a leather spine. Semantic colors (Success, Warning, Danger) are desaturated and earthy to maintain the sophisticated mood without breaking the immersive environment. Hairline borders in `#3A332A` provide structural definition without the need for aggressive shadows.

## Typography
The typography system uses a high-contrast pairing to distinguish between narrative content and technical data. 

- **Display & Headings:** Uses a premium serif (Literata) to echo the printed word. Weights are kept at 500 or 700 with tight tracking for an editorial feel.
- **UI & Body:** Inter provides a clean, functional counterpoint for navigational elements and long-form descriptions.
- **Archival Metadata:** IBM Plex Mono is used for all machine-read data, confidence scores, and ISBN numbers. This font must always be uppercase and letterspaced when used in status badges to signify "system output."

## Layout & Spacing
This design system follows a rigid 4px baseline grid to ensure mathematical precision in an otherwise organic-feeling aesthetic. 

The layout is **Fluid-Fixed**; on mobile, it uses a 24px outer margin for a spacious, gallery-like feel. On desktop, content is centered within a 1200px container. Elements should prioritize vertical stacking to mimic the arrangement of books on a shelf. Significant breathing room (32px+) is encouraged between distinct content sections to maintain the "quiet library" atmosphere.

## Elevation & Depth
Depth is achieved through **Luminance Layering** rather than traditional shadows.
- **Base Level:** `#12100E` (The void/background).
- **Surface Level:** `#1C1916` (Interactive containers/cards).
- **Raised Level:** `#262119` (Modals and active sheets).

To define boundaries, use **1px Hairline Borders** (`#3A332A`). For "Raised" elements, apply a 1px inner stroke (glow) of 10% opacity white on the top edge to simulate light hitting the top of a book or shelf. Shadows, if used, must be ultra-diffused and tinted with the background hue—never pure black.

## Shapes
The shape language is sophisticated and varied, avoiding the "bubbly" look of consumer apps. 
- **Cards & Containers:** 14px radius provides a modern yet structured feel.
- **Sheets & Overlays:** 24px radius on top corners only, creating a "folder" or "binding" look when emerging from the bottom.
- **Buttons:** 12px radius ensures they feel distinct from cards but remain tactile.
- **Chips:** Always fully pill-shaped (999px) to contrast against the harder edges of the card system.

## Components

### The Shelf Strip (Signature)
A horizontal component containing vertical bars of varying widths and colors. This acts as a visual index of the captured shelf. Clicking a bar scrolls the library to that specific volume.

### Confidence Badges
Monospace labels (e.g., `MATCHED`) accompanied by a 3px solid vertical bar on the left edge.
- **MATCHED:** Success green bar.
- **REVIEW:** Warning brass bar.
- **UNKNOWN:** Danger red bar.

### Buttons
- **Primary:** Brass background (`#C9963F`) with `#12100E` text. No shadow.
- **Secondary:** Transparent background with a hairline border (`#3A332A`) and brass text.

### Input Fields
Minimalist design. No background fill. A 1px bottom border that thickens and changes to Brass on focus. Labels use the `metadata-caps` style above the field.

### Cards
Surface-colored (`#1C1916`) with 14px corners. The "book spine" image should be flush to the left, with the title and metadata in the Literata/Inter stack to the right. Apply a very subtle inner glow on the top-left edge to mimic paper thickness.