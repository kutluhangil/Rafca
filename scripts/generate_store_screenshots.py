#!/usr/bin/env python3
"""
Rafça Store Screenshots Generator
Generates pixel-perfect 1080x2400 App Store &amp; Google Play marketing screenshots
plus 1024x500 Feature Graphic following SCREENSHOTS_SPEC.md and Nocturnal Archivist design tokens.
"""

import os
import subprocess

OUTPUT_DIR = "/Volumes/ProjectClaude/Rafca/docs/store/screenshots"

def run_rsvg(svg_path, png_path, width=1080, height=2400):
    cmd = ["/opt/homebrew/bin/rsvg-convert", "-w", str(width), "-h", str(height), svg_path, "-o", png_path]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print(f"Error converting {svg_path}: {res.stderr}")
    else:
        print(f"Generated: {png_path} ({width}x{height})")

def svg_header(w=1080, h=2400):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">
  <defs>
    <radialGradient id="bgGlow" cx="50%" cy="30%" r="70%">
      <stop offset="0%" stop-color="#1E1914"/>
      <stop offset="50%" stop-color="#14110E"/>
      <stop offset="100%" stop-color="#0A0807"/>
    </radialGradient>
    <linearGradient id="brassGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#F3DCA2"/>
      <stop offset="50%" stop-color="#C9963F"/>
      <stop offset="100%" stop-color="#8F6218"/>
    </linearGradient>
    <linearGradient id="cardGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#221E19"/>
      <stop offset="100%" stop-color="#161310"/>
    </linearGradient>
    <filter id="softGlow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="8" result="blur"/>
      <feComposite in="SourceGraphic" in2="blur" operator="over"/>
    </filter>
    <filter id="dropShadow" x="-10%" y="-10%" width="120%" height="120%">
      <feDropShadow dx="0" dy="16" stdDeviation="24" flood-color="#000000" flood-opacity="0.8"/>
    </filter>
    <style>
      .banner-title {{ font-family: 'Literata', Georgia, serif; font-size: 52px; font-weight: 600; fill: #F3DCA2; text-anchor: middle; letter-spacing: -0.5px; }}
      .banner-sub {{ font-family: 'Inter', system-ui, sans-serif; font-size: 28px; font-weight: 400; fill: #A39E96; text-anchor: middle; }}
      .mono-label {{ font-family: 'IBM Plex Mono', Courier, monospace; font-size: 20px; letter-spacing: 2px; fill: #C9963F; text-transform: uppercase; }}
      .app-title {{ font-family: 'Literata', Georgia, serif; font-size: 38px; font-weight: 600; fill: #ECE6DE; }}
      .book-title {{ font-family: 'Literata', Georgia, serif; font-size: 30px; font-weight: 600; fill: #ECE6DE; }}
      .book-author {{ font-family: 'Inter', system-ui, sans-serif; font-size: 22px; fill: #A39E96; }}
      .badge-text {{ font-family: 'IBM Plex Mono', Courier, monospace; font-size: 18px; font-weight: 600; }}
    </style>
  </defs>

  <!-- Deep Obsidian Background -->
  <rect width="{w}" height="{h}" fill="url(#bgGlow)"/>
'''

def phone_frame_wrapper(inner_content, device_y=420):
    # Generates a sleek dark phone mockup container (width 900, height 1840)
    return f'''
  <!-- Device Mockup Container -->
  <g transform="translate(90, {device_y})" filter="url(#dropShadow)">
    <!-- Phone Outer Bezel -->
    <rect width="900" height="1840" rx="64" fill="#0E0C0A" stroke="#C9963F" stroke-width="3" stroke-opacity="0.4"/>
    <rect x="8" y="8" width="884" height="1824" rx="56" fill="#15120E"/>
    
    <!-- Dynamic Island / Speaker notch -->
    <rect x="360" y="24" width="180" height="36" rx="18" fill="#000000"/>
    <circle cx="510" cy="42" r="6" fill="#1C1916"/>

    <!-- Screen Inner Content (Clipped to display) -->
    <g transform="translate(24, 76)">
      {inner_content}
    </g>
  </g>
'''

# -------------------------------------------------------------
# SCREEN 1: HomeScreen
# -------------------------------------------------------------
def make_screen1(lang="tr"):
    t_title = "Tüm Kitaplığınız Parmaklarınızın Ucunda" if lang == "tr" else "Your Entire Library in One Place"
    t_sub = "Nocturnal Archivist zarafetiyle arşivleyin" if lang == "tr" else "Archived with midnight elegance"
    lib_title = "Kütüphane" if lang == "tr" else "Library"
    search_txt = "Kütüphanenizde arayın..." if lang == "tr" else "Search in your library..."
    tab_all = "Tümü" if lang == "tr" else "All"
    vol_txt = "48 CİLT / 4 RAF" if lang == "tr" else "48 VOLUMES / 4 SHELVES"

    inner = f'''
      <!-- App Header -->
      <text x="30" y="60" class="mono-label">{vol_txt}</text>
      <text x="30" y="115" class="app-title">{lib_title}</text>
      <circle cx="810" cy="95" r="28" fill="#241F1A" stroke="#C9963F" stroke-width="1.5"/>
      <path d="M 802 95 L 818 95 M 810 87 L 810 103" stroke="#F3DCA2" stroke-width="2.5" stroke-linecap="round"/>

      <!-- Search Box -->
      <rect x="25" y="150" width="802" height="72" rx="16" fill="#1E1A16" stroke="#C9963F" stroke-width="1" stroke-opacity="0.25"/>
      <circle cx="65" cy="186" r="12" fill="none" stroke="#C9963F" stroke-width="2"/>
      <line x1="74" y1="195" x2="85" y2="206" stroke="#C9963F" stroke-width="2.5" stroke-linecap="round"/>
      <text x="110" y="194" font-family="Inter" font-size="22" fill="#756F68">{search_txt}</text>

      <!-- Shelf Tabs -->
      <g transform="translate(25, 255)">
        <rect x="0" y="0" width="130" height="52" rx="12" fill="#C9963F"/>
        <text x="65" y="34" font-family="Inter" font-size="20" font-weight="600" fill="#12100E" text-anchor="middle">{tab_all}</text>

        <rect x="145" y="0" width="160" height="52" rx="12" fill="#1E1A16" stroke="#C9963F" stroke-width="1" stroke-opacity="0.2"/>
        <text x="225" y="34" font-family="Inter" font-size="20" fill="#A39E96" text-anchor="middle">Felsefe</text>

        <rect x="320" y="0" width="170" height="52" rx="12" fill="#1E1A16" stroke="#C9963F" stroke-width="1" stroke-opacity="0.2"/>
        <text x="405" y="34" font-family="Inter" font-size="20" fill="#A39E96" text-anchor="middle">Klasikler</text>

        <rect x="505" y="0" width="170" height="52" rx="12" fill="#1E1A16" stroke="#C9963F" stroke-width="1" stroke-opacity="0.2"/>
        <text x="590" y="34" font-family="Inter" font-size="20" fill="#A39E96" text-anchor="middle">Bilimkurgu</text>
      </g>

      <!-- Shelf Strip Divider -->
      <g transform="translate(25, 340)">
        <rect width="802" height="12" rx="4" fill="url(#brassGrad)"/>
        <rect y="12" width="802" height="4" fill="#000000" fill-opacity="0.6"/>
      </g>

      <!-- Book Cards Grid (4 Featured Books) -->
      <!-- Card 1 -->
      <g transform="translate(25, 385)">
        <rect width="802" height="260" rx="20" fill="url(#cardGrad)" stroke="#C9963F" stroke-width="1.5" stroke-opacity="0.3"/>
        <!-- Spine Crop View -->
        <rect x="24" y="20" width="46" height="220" rx="6" fill="#6B1D28" stroke="#8C2D19" stroke-width="1.5"/>
        <line x1="47" y1="36" x2="47" y2="224" stroke="#C9963F" stroke-width="1.5" stroke-opacity="0.5"/>
        <!-- Info -->
        <text x="96" y="70" class="book-title">Suç ve Ceza</text>
        <text x="96" y="110" class="book-author">Fyodor Dostoyevski &#8226; İletişim Yayınları</text>
        <!-- Match Badge -->
        <rect x="96" y="145" width="150" height="40" rx="8" fill="#152B1E" stroke="#2D6A4F" stroke-width="1.5"/>
        <text x="171" y="171" class="badge-text" fill="#52B788" text-anchor="middle">%98 EŞLEŞTİ</text>
        <text x="96" y="222" font-family="IBM Plex Mono" font-size="18" fill="#C9963F">RAF 1 &#8226; KORİDOR KİTAPLIĞI</text>
      </g>

      <!-- Card 2 -->
      <g transform="translate(25, 675)">
        <rect width="802" height="260" rx="20" fill="url(#cardGrad)" stroke="#C9963F" stroke-width="1.5" stroke-opacity="0.3"/>
        <rect x="24" y="20" width="50" height="220" rx="6" fill="#24211D" stroke="#C9963F" stroke-width="2"/>
        <line x1="49" y1="36" x2="49" y2="224" stroke="#F3DCA2" stroke-width="2"/>
        <text x="100" y="70" class="book-title">Saatleri Ayarlama Enstitüsü</text>
        <text x="100" y="110" class="book-author">Ahmet Hamdi Tanpınar &#8226; Dergâh</text>
        <rect x="100" y="145" width="150" height="40" rx="8" fill="#152B1E" stroke="#2D6A4F" stroke-width="1.5"/>
        <text x="175" y="171" class="badge-text" fill="#52B788" text-anchor="middle">%99 EŞLEŞTİ</text>
        <text x="100" y="222" font-family="IBM Plex Mono" font-size="18" fill="#C9963F">RAF 1 &#8226; TÜRK KLASİKLERİ</text>
      </g>

      <!-- Card 3 -->
      <g transform="translate(25, 965)">
        <rect width="802" height="260" rx="20" fill="url(#cardGrad)" stroke="#C9963F" stroke-width="1.5" stroke-opacity="0.3"/>
        <rect x="24" y="20" width="44" height="220" rx="6" fill="#1C3829" stroke="#2D5A3C" stroke-width="1.5"/>
        <text x="96" y="70" class="book-title">Dune</text>
        <text x="96" y="110" class="book-author">Frank Herbert &#8226; İthaki Yayınları</text>
        <rect x="96" y="145" width="150" height="40" rx="8" fill="#152B1E" stroke="#2D6A4F" stroke-width="1.5"/>
        <text x="171" y="171" class="badge-text" fill="#52B788" text-anchor="middle">%96 EŞLEŞTİ</text>
        <text x="96" y="222" font-family="IBM Plex Mono" font-size="18" fill="#C9963F">RAF 3 &#8226; BİLİMKURGU</text>
      </g>

      <!-- Card 4 -->
      <g transform="translate(25, 1255)">
        <rect width="802" height="260" rx="20" fill="url(#cardGrad)" stroke="#C9963F" stroke-width="1.5" stroke-opacity="0.3"/>
        <rect x="24" y="20" width="46" height="220" rx="6" fill="#18233C" stroke="#2A3D66" stroke-width="1.5"/>
        <text x="96" y="70" class="book-title">Beyaz Kale</text>
        <text x="96" y="110" class="book-author">Orhan Pamuk &#8226; Yapı Kredi Yayınları</text>
        <rect x="96" y="145" width="150" height="40" rx="8" fill="#152B1E" stroke="#2D6A4F" stroke-width="1.5"/>
        <text x="171" y="171" class="badge-text" fill="#52B788" text-anchor="middle">%95 EŞLEŞTİ</text>
        <text x="96" y="222" font-family="IBM Plex Mono" font-size="18" fill="#C9963F">RAF 2 &#8226; ÇAĞDAŞ EDEBİYAT</text>
      </g>
    '''

    return f'''{svg_header()}
  <!-- Marketing Banner -->
  <g transform="translate(540, 180)">
    <text y="0" class="banner-title">{t_title}</text>
    <text y="64" class="banner-sub">{t_sub}</text>
  </g>

  {phone_frame_wrapper(inner)}
</svg>'''

# -------------------------------------------------------------
# SCREEN 2: CameraScreen &amp; Level Indicator
# -------------------------------------------------------------
def make_screen2(lang="tr"):
    t_title = "Tek Deklanşörle Tüm Rafı Tarayın" if lang == "tr" else "Scan Whole Shelves at Once"
    t_sub = "Hassas açı tesviyesi ve otomatik kadrajlama" if lang == "tr" else "Precise roll &amp; pitch guidance"
    badge_level = "±0.3° DÜZEYDE • HAZIR" if lang == "tr" else "±0.3° LEVEL • READY"
    hint_txt = "Rafı yatay kılavuz çizgileriyle hizalayın" if lang == "tr" else "Align shelf with horizontal guides"

    inner = f'''
      <!-- Camera Viewport Background (Shelf Simulation) -->
      <rect width="852" height="1720" rx="40" fill="#110E0C"/>

      <!-- Simulated Physical Books on Shelf -->
      <g transform="translate(40, 420)">
        <!-- Books Spines -->
        <rect x="0" y="80" width="60" height="580" fill="#5A1820" stroke="#7A222C" stroke-width="2"/>
        <rect x="66" y="30" width="75" height="630" fill="#1C3829" stroke="#2D5A3C" stroke-width="2"/>
        <rect x="147" y="110" width="55" height="550" fill="#7A4B1A" stroke="#9A6024" stroke-width="2"/>
        <rect x="208" y="0" width="85" height="660" fill="#1E1B17" stroke="#C9963F" stroke-width="2"/>
        <line x1="250" y1="40" x2="250" y2="620" stroke="#F3DCA2" stroke-width="2"/>
        <rect x="300" y="60" width="70" height="600" fill="#192A4A" stroke="#2B4372" stroke-width="2"/>
        <rect x="376" y="140" width="55" height="520" fill="#4A1E34" stroke="#682D4B" stroke-width="2"/>
        <rect x="437" y="20" width="80" height="640" fill="#2E4A3E" stroke="#426857" stroke-width="2"/>
        <rect x="523" y="90" width="65" height="570" fill="#6B321D" stroke="#8A4228" stroke-width="2"/>
        <rect x="594" y="40" width="75" height="620" fill="#1C2430" stroke="#2E3C4E" stroke-width="2"/>
        <rect x="675" y="100" width="60" height="560" fill="#4E3B1C" stroke="#6C5329" stroke-width="2"/>

        <!-- Wooden Shelf Base -->
        <rect x="-20" y="660" width="810" height="40" fill="#2B1A0E" stroke="#C9963F" stroke-width="1.5"/>
      </g>

      <!-- Viewfinder Overlay &amp; Framing Brackets -->
      <!-- Top-left -->
      <path d="M 60 360 L 60 300 L 120 300" fill="none" stroke="#F3DCA2" stroke-width="4" stroke-linecap="round"/>
      <!-- Top-right -->
      <path d="M 792 360 L 792 300 L 732 300" fill="none" stroke="#F3DCA2" stroke-width="4" stroke-linecap="round"/>
      <!-- Bottom-left -->
      <path d="M 60 1140 L 60 1200 L 120 1200" fill="none" stroke="#F3DCA2" stroke-width="4" stroke-linecap="round"/>
      <!-- Bottom-right -->
      <path d="M 792 1140 L 792 1200 L 732 1200" fill="none" stroke="#F3DCA2" stroke-width="4" stroke-linecap="round"/>

      <!-- Center Shelf Guide Wire -->
      <line x1="60" y1="750" x2="792" y2="750" stroke="#C9963F" stroke-width="2" stroke-dasharray="8,6" stroke-opacity="0.7"/>

      <!-- Level Indicator Badge (Active Green) -->
      <g transform="translate(426, 210)">
        <rect x="-190" y="-30" width="380" height="60" rx="30" fill="#132A1C" stroke="#52B788" stroke-width="2" filter="url(#softGlow)"/>
        <!-- Artificial Horizon Line -->
        <circle cx="-130" cy="0" r="14" fill="#52B788"/>
        <line x1="-138" y1="0" x2="-122" y2="0" stroke="#12100E" stroke-width="3"/>
        <text x="20" y="8" font-family="IBM Plex Mono" font-size="20" font-weight="600" fill="#52B788" text-anchor="middle">{badge_level}</text>
      </g>

      <!-- Helper Hint -->
      <text x="426" y="1280" font-family="Inter" font-size="22" fill="#ECE6DE" text-anchor="middle" filter="url(#dropShadow)">{hint_txt}</text>

      <!-- Camera Bottom Controls -->
      <g transform="translate(426, 1540)">
        <!-- Outer Glowing Shutter Ring -->
        <circle cx="0" cy="0" r="62" fill="none" stroke="#C9963F" stroke-width="4"/>
        <circle cx="0" cy="0" r="50" fill="#ECE6DE"/>
        <circle cx="0" cy="0" r="44" fill="#C9963F"/>

        <!-- Flash Button -->
        <circle cx="-230" cy="0" r="34" fill="#1E1A16" stroke="#C9963F" stroke-width="1.5" stroke-opacity="0.4"/>
        <path d="M -230 -16 L -238 2 L -228 2 L -234 16 L -222 -2 L -232 -2 Z" fill="#F3DCA2"/>

        <!-- Gallery / Import Button -->
        <circle cx="230" cy="0" r="34" fill="#1E1A16" stroke="#C9963F" stroke-width="1.5" stroke-opacity="0.4"/>
        <rect x="214" y="-14" width="32" height="28" rx="4" fill="none" stroke="#F3DCA2" stroke-width="2.5"/>
        <circle cx="224" cy="-4" r="3" fill="#F3DCA2"/>
      </g>
    '''

    return f'''{svg_header()}
  <g transform="translate(540, 180)">
    <text y="0" class="banner-title">{t_title}</text>
    <text y="64" class="banner-sub">{t_sub}</text>
  </g>

  {phone_frame_wrapper(inner)}
</svg>'''

# -------------------------------------------------------------
# SCREEN 3: CropScreen (Quad Perspective Homography)
# -------------------------------------------------------------
def make_screen3(lang="tr"):
    t_title = "Milimetrik Perspektif Düzeltme" if lang == "tr" else "Perspective Warp &amp; Alignment"
    t_sub = "Köşeleri raf kenarlarına zahmetsizce oturtun" if lang == "tr" else "Effortlessly map shelf boundaries"
    btn_txt = "DÜZLEŞTİR VE AYRIŞTIR" if lang == "tr" else "WARP &amp; SEGMENT SPINES"
    mode_txt = "4-NOKTALI RAF SINIR KILAVUZU" if lang == "tr" else "4-POINT SHELF BOUNDARY MAPPING"

    inner = f'''
      <!-- Top Bar -->
      <text x="30" y="60" class="mono-label">{mode_txt}</text>
      <text x="30" y="115" class="app-title">Perspektif Ayarı</text>

      <!-- Shelf Image in Quad View -->
      <g transform="translate(25, 170)">
        <rect width="802" height="1260" rx="20" fill="#161310" stroke="#C9963F" stroke-width="1.5" stroke-opacity="0.3"/>

        <!-- Skewed Perspective Shelf Representation -->
        <polygon points="60,180 740,110 770,1050 30,1140" fill="#201C17"/>

        <!-- Drawn Perspective Grid Quadrilateral (The 4 Warp Pins) -->
        <polygon points="60,180 740,110 770,1050 30,1140" fill="none" stroke="#C9963F" stroke-width="3" stroke-dasharray="10,6"/>

        <!-- Internal guide cross lines -->
        <line x1="60" y1="180" x2="770" y2="1050" stroke="#C9963F" stroke-width="1.5" stroke-opacity="0.3"/>
        <line x1="740" y1="110" x2="30" y2="1140" stroke="#C9963F" stroke-width="1.5" stroke-opacity="0.3"/>

        <!-- 4 Golden Anchor Handles -->
        <!-- P1: Top-Left -->
        <circle cx="60" cy="180" r="22" fill="#12100E" stroke="#F3DCA2" stroke-width="4"/>
        <circle cx="60" cy="180" r="8" fill="#C9963F"/>

        <!-- P2: Top-Right (With Loupe Active!) -->
        <circle cx="740" cy="110" r="22" fill="#12100E" stroke="#F3DCA2" stroke-width="4"/>
        <circle cx="740" cy="110" r="8" fill="#C9963F"/>

        <!-- Floating Magnifier Loupe over Top-Right Pin -->
        <g transform="translate(620, -30)" filter="url(#dropShadow)">
          <circle cx="0" cy="0" r="90" fill="#1C1814" stroke="#F3DCA2" stroke-width="4"/>
          <!-- Zoomed Grid -->
          <line x1="-70" y1="0" x2="70" y2="0" stroke="#52B788" stroke-width="2"/>
          <line x1="0" y1="-70" x2="0" y2="70" stroke="#52B788" stroke-width="2"/>
          <circle cx="0" cy="0" r="6" fill="#F3DCA2"/>
          <!-- Connector needle -->
          <path d="M 40 60 L 120 140" stroke="#F3DCA2" stroke-width="3"/>
        </g>

        <!-- P3: Bottom-Right -->
        <circle cx="770" cy="1050" r="22" fill="#12100E" stroke="#F3DCA2" stroke-width="4"/>
        <circle cx="770" cy="1050" r="8" fill="#C9963F"/>

        <!-- P4: Bottom-Left -->
        <circle cx="30" cy="1140" r="22" fill="#12100E" stroke="#F3DCA2" stroke-width="4"/>
        <circle cx="30" cy="1140" r="8" fill="#C9963F"/>
      </g>

      <!-- Primary Action Button -->
      <g transform="translate(25, 1500)">
        <rect width="802" height="96" rx="24" fill="url(#brassGrad)" filter="url(#softGlow)"/>
        <text x="401" y="60" font-family="IBM Plex Mono" font-size="26" font-weight="600" fill="#12100E" text-anchor="middle" letter-spacing="1.5">{btn_txt}</text>
      </g>
    '''

    return f'''{svg_header()}
  <g transform="translate(540, 180)">
    <text y="0" class="banner-title">{t_title}</text>
    <text y="64" class="banner-sub">{t_sub}</text>
  </g>

  {phone_frame_wrapper(inner)}
</svg>'''

# -------------------------------------------------------------
# SCREEN 4: ScanResultsScreen (Spine Segmentation &amp; Matching)
# -------------------------------------------------------------
def make_screen4(lang="tr"):
    t_title = "Anında Sırt Ayrıştırma &amp; Eşleştirme" if lang == "tr" else "Instant Spine Segmentation"
    t_sub = "Yüksek doğruluklu yerel katalog entegrasyonu" if lang == "tr" else "High-confidence catalogue matching"
    stat_txt = "14 SIRTTAN 12'Sİ EŞLEŞTİRİLDİ" if lang == "tr" else "12 OF 14 SPINES MATCHED"
    save_btn = "KÜTÜPHANEYE KAYDET (14 CİLT)" if lang == "tr" else "SAVE TO LIBRARY (14 VOLUMES)"

    inner = f'''
      <text x="30" y="60" class="mono-label">{stat_txt}</text>
      <text x="30" y="115" class="app-title">Tarama Sonuçları</text>

      <!-- Segmented Spines Visual Ribbon -->
      <g transform="translate(25, 160)">
        <rect width="802" height="640" rx="20" fill="#161310" stroke="#C9963F" stroke-width="1.5" stroke-opacity="0.3"/>

        <!-- Detected Spines with Bounding Boxes -->
        <!-- Spine 1: Matched -->
        <rect x="40" y="50" width="85" height="520" rx="8" fill="#6B1D28" stroke="#52B788" stroke-width="3"/>
        <rect x="40" y="50" width="85" height="36" rx="4" fill="#152B1E"/>
        <text x="82" y="74" font-family="IBM Plex Mono" font-size="16" fill="#52B788" text-anchor="middle">%98</text>

        <!-- Spine 2: Matched -->
        <rect x="145" y="30" width="95" height="540" rx="8" fill="#24211D" stroke="#52B788" stroke-width="3"/>
        <rect x="145" y="30" width="95" height="36" rx="4" fill="#152B1E"/>
        <text x="192" y="54" font-family="IBM Plex Mono" font-size="16" fill="#52B788" text-anchor="middle">%99</text>

        <!-- Spine 3: Needs Review (Amber) -->
        <rect x="260" y="80" width="80" height="490" rx="8" fill="#5A3A1A" stroke="#E59866" stroke-width="3" stroke-dasharray="6,4"/>
        <rect x="260" y="80" width="80" height="36" rx="4" fill="#3D2614"/>
        <text x="300" y="104" font-family="IBM Plex Mono" font-size="16" fill="#F8C471" text-anchor="middle">İNCELE</text>

        <!-- Spine 4: Matched -->
        <rect x="360" y="40" width="90" height="530" rx="8" fill="#1C3829" stroke="#52B788" stroke-width="3"/>
        <rect x="360" y="40" width="90" height="36" rx="4" fill="#152B1E"/>
        <text x="405" y="64" font-family="IBM Plex Mono" font-size="16" fill="#52B788" text-anchor="middle">%96</text>

        <!-- Spine 5: Matched -->
        <rect x="470" y="60" width="85" height="510" rx="8" fill="#18233C" stroke="#52B788" stroke-width="3"/>
        <rect x="470" y="60" width="85" height="36" rx="4" fill="#152B1E"/>
        <text x="512" y="84" font-family="IBM Plex Mono" font-size="16" fill="#52B788" text-anchor="middle">%95</text>

        <!-- Spine 6: Matched -->
        <rect x="575" y="30" width="90" height="540" rx="8" fill="#8C3A27" stroke="#52B788" stroke-width="3"/>
        <rect x="575" y="30" width="90" height="36" rx="4" fill="#152B1E"/>
        <text x="620" y="54" font-family="IBM Plex Mono" font-size="16" fill="#52B788" text-anchor="middle">%94</text>
      </g>

      <!-- Detection List Item Cards -->
      <g transform="translate(25, 830)">
        <!-- List Item 1 -->
        <rect width="802" height="190" rx="16" fill="url(#cardGrad)" stroke="#C9963F" stroke-width="1" stroke-opacity="0.3"/>
        <text x="30" y="55" class="book-title">Kürk Mantolu Madonna</text>
        <text x="30" y="95" class="book-author">Sabahattin Ali &#8226; Yapı Kredi Yayınları</text>
        <rect x="30" y="125" width="160" height="38" rx="8" fill="#152B1E" stroke="#2D6A4F" stroke-width="1.5"/>
        <text x="110" y="150" class="badge-text" fill="#52B788" text-anchor="middle">%99 EŞLEŞTİ</text>

        <!-- List Item 2 (Needs review card) -->
        <g transform="translate(0, 210)">
          <rect width="802" height="190" rx="16" fill="url(#cardGrad)" stroke="#E59866" stroke-width="1.5"/>
          <text x="30" y="55" class="book-title">Yabancı (L'Étranger)</text>
          <text x="30" y="95" class="book-author">Albert Camus &#8226; Can Yayınları (Öneri)</text>
          <rect x="30" y="125" width="220" height="38" rx="8" fill="#3D2614" stroke="#E59866" stroke-width="1.5"/>
          <text x="140" y="150" class="badge-text" fill="#F8C471" text-anchor="middle">BASKIYI ONAYLA</text>
        </g>

        <!-- List Item 3 -->
        <g transform="translate(0, 420)">
          <rect width="802" height="190" rx="16" fill="url(#cardGrad)" stroke="#C9963F" stroke-width="1" stroke-opacity="0.3"/>
          <text x="30" y="55" class="book-title">Tutunamayanlar</text>
          <text x="30" y="95" class="book-author">Oğuz Atay &#8226; İletişim Yayınları</text>
          <rect x="30" y="125" width="160" height="38" rx="8" fill="#152B1E" stroke="#2D6A4F" stroke-width="1.5"/>
          <text x="110" y="150" class="badge-text" fill="#52B788" text-anchor="middle">%97 EŞLEŞTİ</text>
        </g>
      </g>

      <!-- Bottom Save Action -->
      <g transform="translate(25, 1510)">
        <rect width="802" height="96" rx="24" fill="url(#brassGrad)" filter="url(#softGlow)"/>
        <text x="401" y="60" font-family="IBM Plex Mono" font-size="24" font-weight="600" fill="#12100E" text-anchor="middle" letter-spacing="1.5">{save_btn}</text>
      </g>
    '''

    return f'''{svg_header()}
  <g transform="translate(540, 180)">
    <text y="0" class="banner-title">{t_title}</text>
    <text y="64" class="banner-sub">{t_sub}</text>
  </g>

  {phone_frame_wrapper(inner)}
</svg>'''

# -------------------------------------------------------------
# SCREEN 5: BookDetailScreen (Proof of Capture &amp; Spine Crop)
# -------------------------------------------------------------
def make_screen5(lang="tr"):
    t_title = "Proof of Capture — Rafınızın Somut İzi" if lang == "tr" else "Proof of Capture From Your Shelf"
    t_sub = "Fiziksel sırt kırpımı ve renk paleti daima sizinle" if lang == "tr" else "Original spine crop preserved locally"
    poc_label = "FİZİKSEL SIRT İZİ • PROOF OF CAPTURE" if lang == "tr" else "PHYSICAL SPINE • PROOF OF CAPTURE"

    inner = f'''
      <!-- Back / Share header -->
      <path d="M 40 70 L 25 85 L 40 100" fill="none" stroke="#C9963F" stroke-width="3" stroke-linecap="round"/>
      <circle cx="810" cy="85" r="26" fill="#1E1A16" stroke="#C9963F" stroke-width="1.5"/>
      <path d="M 802 85 L 818 85 M 810 77 L 810 93" stroke="#F3DCA2" stroke-width="2"/>

      <!-- Main Showcase: The Physical Spine Crop vs Metadata -->
      <g transform="translate(25, 140)">
        <!-- Vertical Spine Crop Display -->
        <rect x="30" y="30" width="160" height="740" rx="16" fill="#24211D" stroke="#C9963F" stroke-width="3" filter="url(#dropShadow)"/>
        <!-- Spine Title in gold -->
        <text x="110" y="380" font-family="Literata" font-size="26" fill="#F3DCA2" transform="rotate(-90, 110, 380)" text-anchor="middle" letter-spacing="4">SAATLERİ AYARLAMA ENSTİTÜSÜ</text>
        <circle cx="110" cy="80" r="10" fill="#C9963F"/>
        <rect x="90" y="680" width="40" height="60" rx="4" fill="#C9963F" fill-opacity="0.3"/>

        <!-- Metadata Column alongside Spine -->
        <g transform="translate(225, 40)">
          <text x="0" y="30" class="mono-label">{poc_label}</text>
          <text x="0" y="90" font-family="Literata" font-size="36" font-weight="600" fill="#ECE6DE">Saatleri Ayarlama</text>
          <text x="0" y="135" font-family="Literata" font-size="36" font-weight="600" fill="#ECE6DE">Enstitüsü</text>
          <text x="0" y="185" class="book-author">Ahmet Hamdi Tanpınar</text>

          <!-- Palette Swatches (Extracted from spine) -->
          <text x="0" y="260" class="mono-label">ÇIKARILAN RENK PALETİ</text>
          <g transform="translate(0, 280)">
            <rect x="0" y="0" width="56" height="56" rx="10" fill="#24211D" stroke="#C9963F" stroke-width="1.5"/>
            <rect x="66" y="0" width="56" height="56" rx="10" fill="#C9963F"/>
            <rect x="132" y="0" width="56" height="56" rx="10" fill="#F3DCA2"/>
            <rect x="198" y="0" width="56" height="56" rx="10" fill="#6B1D28"/>
            <rect x="264" y="0" width="56" height="56" rx="10" fill="#1C3829"/>
          </g>

          <!-- Meta Table -->
          <g transform="translate(0, 390)">
            <text x="0" y="24" font-family="IBM Plex Mono" font-size="18" fill="#756F68">YAYINEVİ</text>
            <text x="0" y="56" font-family="Inter" font-size="22" fill="#ECE6DE">Dergâh Yayınları</text>

            <text x="0" y="110" font-family="IBM Plex Mono" font-size="18" fill="#756F68">BASIM / ISBN</text>
            <text x="0" y="142" font-family="IBM Plex Mono" font-size="20" fill="#C9963F">978-975-995-584-7</text>

            <text x="0" y="196" font-family="IBM Plex Mono" font-size="18" fill="#756F68">RAF KONUMU</text>
            <text x="0" y="228" font-family="Inter" font-size="22" fill="#ECE6DE">Koridor &#8226; Raf 1 &#8226; Cilt 4</text>
          </g>
        </g>
      </g>

      <!-- Archival Notes Section -->
      <g transform="translate(25, 960)">
        <rect width="802" height="280" rx="20" fill="url(#cardGrad)" stroke="#C9963F" stroke-width="1" stroke-opacity="0.3"/>
        <text x="30" y="55" class="mono-label">OKUMA NOTU VE ARŞİV BİLGİSİ</text>
        <text x="30" y="105" font-family="Literata" font-size="24" font-style="italic" fill="#ECE6DE">"Doğu ile Batı arasında bocalayan Türk modernleşmesinin başyapıtı."</text>
        <text x="30" y="160" font-family="Inter" font-size="20" fill="#A39E96">Durum: Okundu &#8226; Eklenme: 3 Kasım 2026 &#8226; Yerel SQLite Drift ID #104</text>
      </g>
    '''

    return f'''{svg_header()}
  <g transform="translate(540, 180)">
    <text y="0" class="banner-title">{t_title}</text>
    <text y="64" class="banner-sub">{t_sub}</text>
  </g>

  {phone_frame_wrapper(inner)}
</svg>'''

# -------------------------------------------------------------
# SCREEN 6: ShareCard (Artistic Collection Export)
# -------------------------------------------------------------
def make_screen6(lang="tr"):
    t_title = "Koleksiyonunuzu Sanatsal Olarak Paylaşın" if lang == "tr" else "Share Your Curated Collection"
    t_sub = "Tek tıkla hikaye veya yüksek çözünürlüklü kart" if lang == "tr" else "Export artistic archival cards"
    share_action = "GÖRSELİ KAYDET" if lang == "tr" else "SAVE IMAGE"
    story_action = "HİKAYEDE PAYLAŞ" if lang == "tr" else "SHARE TO STORY"

    inner = f'''
      <!-- Top Title -->
      <text x="30" y="60" class="mono-label">ARŞİV KARTI PAYLAŞIMI</text>
      <text x="30" y="115" class="app-title">Koleksiyon Kartı</text>

      <!-- Exact ShareCard Rendering (Centered) -->
      <g transform="translate(45, 180)" filter="url(#dropShadow)">
        <!-- Card Background -->
        <rect width="760" height="1140" rx="32" fill="#1C1814" stroke="#C9963F" stroke-width="3"/>
        <rect x="18" y="18" width="724" height="1104" rx="24" fill="none" stroke="#C9963F" stroke-width="1" stroke-opacity="0.3" stroke-dasharray="6,4"/>

        <!-- Top Monogram Star -->
        <g transform="translate(380, 80)">
          <path d="M 0 -18 L 5 -5 L 18 0 L 5 5 L 0 18 L -5 5 L -18 0 L -5 -5 Z" fill="#F3DCA2"/>
        </g>

        <!-- Subtitle and Title -->
        <text x="380" y="160" class="mono-label" text-anchor="middle">FELSEFE VE EDEBİYAT KİTAPLIĞI</text>
        <text x="380" y="240" font-family="Literata" font-size="52" font-weight="600" fill="#F3DCA2" text-anchor="middle">Sonbahar Koleksiyonu</text>
        <text x="380" y="300" font-family="Inter" font-size="28" fill="#A39E96" text-anchor="middle">Kutluhan Gül Kütüphanesi</text>

        <!-- Dynamic Mini Shelf Strip -->
        <g transform="translate(90, 360)">
          <rect width="580" height="240" rx="16" fill="#14110E" stroke="#C9963F" stroke-width="1.5" stroke-opacity="0.4"/>
          <!-- 8 Colored Spine strips -->
          <rect x="30" y="30" width="45" height="180" rx="4" fill="#6B1D28"/>
          <rect x="85" y="10" width="60" height="200" rx="4" fill="#C9963F"/>
          <rect x="155" y="40" width="45" height="170" rx="4" fill="#1C3829"/>
          <rect x="210" y="20" width="55" height="190" rx="4" fill="#18233C"/>
          <rect x="275" y="35" width="50" height="175" rx="4" fill="#8C3A27"/>
          <rect x="335" y="15" width="65" height="195" rx="4" fill="#4A1E34"/>
          <rect x="410" y="45" width="45" height="165" rx="4" fill="#52B788"/>
          <rect x="465" y="25" width="55" height="185" rx="4" fill="#2E3C4E"/>

          <!-- Shelf bar under books -->
          <rect x="15" y="210" width="550" height="8" rx="2" fill="url(#brassGrad)"/>
        </g>

        <!-- Stats Big Count -->
        <text x="380" y="700" font-family="Literata" font-size="72" font-weight="600" fill="#F3DCA2" text-anchor="middle">48</text>
        <text x="380" y="745" class="mono-label" text-anchor="middle">CİLT ARŞİVLENDİ</text>

        <!-- Category Tags -->
        <g transform="translate(380, 830)">
          <text x="0" y="0" font-family="IBM Plex Mono" font-size="22" fill="#C9963F" text-anchor="middle" letter-spacing="2">KLASİKLER &#8226; FELSEFE &#8226; ŞİİR</text>
        </g>

        <!-- Watermark / Footer -->
        <g transform="translate(380, 990)">
          <text x="0" y="0" font-family="IBM Plex Mono" font-size="20" fill="#756F68" text-anchor="middle" letter-spacing="3">RAFÇA &#8226; NOCTURNAL ARCHIVIST</text>
          <text x="0" y="35" font-family="Inter" font-size="16" fill="#55504A" text-anchor="middle">KASIM 2026 &#8226; YEREL ARŞİV</text>
        </g>
      </g>

      <!-- Bottom Actions -->
      <g transform="translate(45, 1480)">
        <rect width="360" height="90" rx="20" fill="#1E1A16" stroke="#C9963F" stroke-width="2"/>
        <text x="180" y="55" font-family="IBM Plex Mono" font-size="20" font-weight="600" fill="#F3DCA2" text-anchor="middle">{story_action}</text>

        <rect x="400" y="0" width="360" height="90" rx="20" fill="url(#brassGrad)" filter="url(#softGlow)"/>
        <text x="580" y="55" font-family="IBM Plex Mono" font-size="20" font-weight="600" fill="#12100E" text-anchor="middle">{share_action}</text>
      </g>
    '''

    return f'''{svg_header()}
  <g transform="translate(540, 180)">
    <text y="0" class="banner-title">{t_title}</text>
    <text y="64" class="banner-sub">{t_sub}</text>
  </g>

  {phone_frame_wrapper(inner)}
</svg>'''

# -------------------------------------------------------------
# GOOGLE PLAY FEATURE GRAPHIC (1024 x 500)
# -------------------------------------------------------------
def make_feature_graphic(lang="tr"):
    tagline = "Fiziksel kitaplığınızı tek fotoğrafla dijitalleştirin." if lang == "tr" else "Digitize your physical library from a single shelf photo."
    badge = "NOCTURNAL ARCHIVIST • YEREL ÖNCELİKLİ" if lang == "tr" else "NOCTURNAL ARCHIVIST • LOCAL-FIRST"

    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 500" width="1024" height="500">
  <defs>
    <radialGradient id="fgBg" cx="40%" cy="50%" r="75%">
      <stop offset="0%" stop-color="#241E18"/>
      <stop offset="60%" stop-color="#14110E"/>
      <stop offset="100%" stop-color="#080706"/>
    </radialGradient>
    <linearGradient id="brassG" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#F3DCA2"/>
      <stop offset="50%" stop-color="#C9963F"/>
      <stop offset="100%" stop-color="#8F6218"/>
    </linearGradient>
    <filter id="fGlow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="10" result="b"/>
      <feComposite in="SourceGraphic" in2="b" operator="over"/>
    </filter>
  </defs>

  <rect width="1024" height="500" fill="url(#fgBg)"/>

  <!-- Archival Gilded Borders -->
  <rect x="24" y="24" width="976" height="452" rx="16" fill="none" stroke="#C9963F" stroke-width="1.5" stroke-opacity="0.3"/>
  <rect x="36" y="36" width="952" height="428" rx="12" fill="none" stroke="#C9963F" stroke-width="1" stroke-opacity="0.15" stroke-dasharray="6,4"/>

  <!-- Left: Logo &amp; Branding -->
  <g transform="translate(80, 140)">
    <!-- Star icon -->
    <path d="M 0 -14 L 3 -3 L 14 0 L 3 3 L 0 14 L -3 3 L -14 0 L -3 -3 Z" fill="#F3DCA2"/>
    <text x="30" y="6" font-family="IBM Plex Mono" font-size="16" letter-spacing="3" fill="#C9963F">{badge}</text>
    <text x="0" y="80" font-family="Literata" font-size="72" font-weight="600" fill="#F3DCA2" filter="url(#fGlow)">Rafça</text>
    <text x="0" y="140" font-family="Inter" font-size="22" fill="#ECE6DE">{tagline}</text>
    <text x="0" y="185" font-family="IBM Plex Mono" font-size="16" fill="#A39E96">OFFLINE-FIRST &#8226; ML KIT OCR &#8226; ZERO ADS &#8226; 100% PRIVATE</text>
  </g>

  <!-- Right: Archival Bookshelf Motif -->
  <g transform="translate(720, 110)">
    <rect x="0" y="60" width="34" height="220" rx="4" fill="#6B1D28" stroke="#8C2D19" stroke-width="1.5"/>
    <rect x="42" y="20" width="42" height="260" rx="4" fill="#24211D" stroke="#C9963F" stroke-width="2"/>
    <line x1="63" y1="40" x2="63" y2="260" stroke="#F3DCA2" stroke-width="2"/>
    <rect x="92" y="80" width="36" height="200" rx="4" fill="#1C3829" stroke="#2D5A3C" stroke-width="1.5"/>
    <rect x="136" y="40" width="38" height="240" rx="4" fill="#18233C" stroke="#2A3D66" stroke-width="1.5"/>
    <g transform="translate(182, 90) rotate(8)">
      <rect x="0" y="0" width="34" height="190" rx="4" fill="#8C3A27" stroke="#B84E34" stroke-width="1.5"/>
    </g>
    <!-- Shelf base -->
    <rect x="-20" y="280" width="280" height="12" rx="3" fill="url(#brassG)"/>
  </g>
</svg>'''

def main():
    generators = [
        ("01_home_screen", make_screen1),
        ("02_camera_level", make_screen2),
        ("03_perspective_crop", make_screen3),
        ("04_scan_results", make_screen4),
        ("05_book_detail", make_screen5),
        ("06_share_card", make_screen6),
    ]

    for lang in ["tr", "en"]:
        target_dir = os.path.join(OUTPUT_DIR, lang)
        os.makedirs(target_dir, exist_ok=True)

        for name, gen_fn in generators:
            svg_content = gen_fn(lang=lang)
            svg_path = os.path.join(target_dir, f"{name}.svg")
            png_path = os.path.join(target_dir, f"{name}.png")

            with open(svg_path, "w", encoding="utf-8") as f:
                f.write(svg_content)

            run_rsvg(svg_path, png_path, width=1080, height=2400)

        # Feature Graphic
        fg_svg = make_feature_graphic(lang=lang)
        fg_svg_path = os.path.join(target_dir, "feature_graphic.svg")
        fg_png_path = os.path.join(target_dir, "feature_graphic.png")
        with open(fg_svg_path, "w", encoding="utf-8") as f:
            f.write(fg_svg)
        run_rsvg(fg_svg_path, fg_png_path, width=1024, height=500)

    print("All store screenshots generated successfully!")

if __name__ == "__main__":
    main()
