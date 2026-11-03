# Faz 6 — Yakalama (A6 Capture)

**Durum: KAPALI.**

Kabul kriterleri:
- [x] Canlı kamera önizlemesi ve roll/pitch tesviye kapısı (±7° tolerans).
- [x] 300ms ivme penceresinde titreşim denetimi.
- [x] Manuel raf perspektif düzeltme (QuadEditor + 4-point bilinear inverse warp).
- [x] 4000px uzun kenar boyut sınırlama (capMaxDimension) ve kontrast iyileştirme.
- [x] 4 rotasyonda OCR (0°, 90°, 180°, 270°) ve koordinat geri eşleme.
- [x] Sırt kümeleme (spine_clustering entegrasyonu).
- [x] Sırt kırpımlarının kaydedilmesi (`spine/captures/`) ve dominant renk çıkarımı.
- [x] İşleniyor ekranı (Hero animasyonu, sıralı stroke-dash sırt overlay, mono log, progress).
- [x] Kamera izin ekranı (`CameraPermissionScreen`) ve izin akışı.
- [x] Web stub ve conditional import mimarisi (`UnsupportedError`).
- [x] Router ve HomeScreen entegrasyonu.
- [x] `flutter analyze` temiz (0 issue).
- [x] `flutter test` yeşil (68/68 test).

---

## Oluşturulan ve Düzenlenen Dosyalar

| Dosya | Açıklama |
|-------|----------|
| `app/lib/features/capture/state/capture_state.dart` | Sealed state sınıfları: `CaptureIdle`, `CapturePermissionRequired`, `CaptureCapturing`, `CaptureCropping`, `CaptureProcessing`, `CaptureDone`, `CaptureError` |
| `app/lib/features/capture/state/capture_notifier.dart` | Riverpod tabanlı capture akış yöneticisi, sensör toleransı ve izin kontrolü |
| `app/lib/features/capture/state/capture_notifier.g.dart` | Riverpod generator sözleşmesine uygun sağlayıcı tanımı |
| `app/lib/features/capture/preprocessing/preprocessor.dart` | 4 köşe bilinear warp, grayscale, CLAHE kontrast ve 4000px sınırlayıcı |
| `app/lib/features/capture/scan/ocr_engine.dart` | Conditional export (web stub vs native ML Kit) |
| `app/lib/features/capture/scan/ocr_engine_stub.dart` | Web platformu için `UnsupportedError` fırlatan stub |
| `app/lib/features/capture/scan/ocr_engine_native.dart` | `google_mlkit_text_recognition` ile 4 rotasyonlu native OCR ve unrotate dönüşümü |
| `app/lib/features/capture/scan/scan_controller.dart` | OCR + kümeleme + kırpım (`spine/captures/`) + modal renk çıkarım orkestratörü |
| `app/lib/features/capture/widgets/level_indicator.dart` | Roll & pitch su terazisi ve ibre göstergesi |
| `app/lib/features/capture/widgets/shutter_button.dart` | Tesviye kapısına duyarlı, animasyonlu deklanşör butonu |
| `app/lib/features/capture/widgets/quad_clipper.dart` | Etkileşimli 4 köşe sürükleme ve maskeleme editörü |
| `app/lib/features/capture/widgets/spine_overlay.dart` | Sıralı stroke-dash ve %8 brass dolgulu animasyonlu sırt kılavuzları |
| `app/lib/features/capture/screens/permission_screen.dart` | Nocturnal Archivist temalı kamera izin isteme ekranı |
| `app/lib/features/capture/screens/camera_screen.dart` | Canlı önizleme, hizalama kılavuzu, tesviye ve çekim ekranı |
| `app/lib/features/capture/screens/crop_screen.dart` | Çekilen kare üzerinde quad seçim ve warp ekranı |
| `app/lib/features/capture/screens/processing_screen.dart` | Hero animasyonlu, progress bar ve archival log içeren tarama ekranı |
| `app/lib/features/capture/capture.dart` | Barrel export dosyası |
| `app/lib/core/router/app_router.dart` | `/capture`, `/capture/crop`, `/capture/processing` rotaları |
| `app/lib/features/home/home_screen.dart` | "Raf Tara" butonu ve kamera FloatingActionButton |
| `app/android/app/src/main/AndroidManifest.xml` | Kamera izinleri ve donanım özellikleri |
| `app/ios/Runner/Info.plist` | `NSCameraUsageDescription` açıklaması |
| `app/test/features/capture/preprocessing_test.dart` | Boyutlandırma, gri tonlama ve warp testleri |
| `app/test/features/capture/capture_state_test.dart` | Tolerans, durum geçişleri ve sensör testleri |
| `app/test/features/capture/widgets_test.dart` | LevelIndicator, ShutterButton, QuadEditor, CameraPermissionScreen widget testleri |

---

## Önemli Kararlar ve Uygulama Notları

1. **Perspektif Dönüşümü:**
   `image` paketinde dahili 4-noktalı serbest homography bulunmadığı için ters bilinear eşleme (inverse bilinear mapping) saf Dart ile `CapturePreprocessor` içinde geliştirildi. Bu sayede harici C++/native kütüphanelere ihtiyaç duymadan platformdan bağımsız perspektif düzeltme elde edildi.

2. **Web / Cihaz Ayrımı:**
   CLAUDE.md prensiplerine tam sadık kalındı. Web derlemelerinde sessizce geri düşmek yerine `ocr_engine_stub.dart` ile `UnsupportedError` üretildi; masaüstü ve mobil derlemelerinde ise tam yerel yetenekler devreye girdi.

3. **Renk ve Animasyon Bütçesi:**
   Tüm animasyonlar `SpineMotion` sabitlerine bağlandı; hiçbir animasyon 400ms tavanını aşmadı ve reduce-motion açıkken her şey 120ms'ye indirgendi. Renkler doğrudan `DESIGN.md` token otoritesinden okundu.
