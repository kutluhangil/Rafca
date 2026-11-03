# FAZ 11 — Fiziksel-Dijital İkiz ve Ödünç Takipçisi (Physical-Digital Twin & Lending Tracker)

**Durum: KAPALI.**

## Kapsam ve Başarılanlar

1. **Fiziksel-Dijital İkiz (Physical-to-Digital Shelf Twin):**
   - `UserBooks.shelfPosition`: Taranan raftaki kitapların sol-sağ fiziksel sırasını (`SpineCandidate.bbox.left` sırası) 1-based pozisyon olarak veritabanına kalıcı kaydeder.
   - `review_controller.dart`: Eşleşen kitaplar kütüphaneye aktarılırken otomatik olarak fiziksel raf indeksini (`shelfPosition: i + 1`) atar.
   - Kütüphane sıralaması: `BookSortOption.shelfPositionAsc` seçeneği eklendi. Fiziksel raftaki dizilim dijital kütüphanede birebir yansıtılır.
   - Kitap kartları ve detay ekranında "Raf Sırası #N" rozeti gösterilir.

2. **Ödünç Takipçisi (Lending Tracker):**
   - Drift `BookLoans` tablosu: `id`, `userBookId`, `borrowerName`, `borrowerContact`, `loanedAt`, `dueDate`, `returnedAt`, `notes`, `pendingSync`.
   - SQLite migration (v2 -> v3): `onUpgrade` içinde `m.addColumn(userBooks, userBooks.shelfPosition)` ve `m.createTable(bookLoans)` otomatik uygulanır.
   - `LibraryRepository`:
     - `watchLibraryBooks`: `BookLoans` ile sol dış birleşim (`returnedAt.isNull()`) yapılarak `LibraryBook` nesnelerine aktif ödünç bilgisi sıfır ek sorgu ile iliştirilir.
     - `onLoanFilter`: "Ödünçtekiler" filtresi ile ödünçte olan kitaplar tek tıkla süzülür.
     - `loanBook`: Kitabı ödünç verir, `SyncEntity.loan` upsert kuyruğuna yazar.
     - `returnBook`: Kitabı iade alır (`returnedAt` güncellenir), sync kuyruğuna yazar.
     - `watchLoans`: Aktif veya tüm geçmiş ödünç kayıtlarını izler.
     - `clearAllData`: Kütüphane sıfırlanırken ödünç kayıtlarını da temizler.
   - `BookDetailScreen`:
     - Ödünç Takipçisi kartı (`_buildLoanCard`): Kitap kütüphanedeyse "ÖDÜNÇ VER" butonu ve modal diyaloğu (isim, iletişim, beklenen tarih, not).
     - Kitap ödünçteyse: Ödünç alan kişi, iletişim, veriliş tarihi, beklenen iade tarihi, not ve tek tıkla "İADE AL" aksiyonu.
   - `LibraryScreen`:
     - Sıralama menüsü: Eklenme Tarihi, Fiziksel Raf Sırası, Başlık (A-Z), Yazar (A-Z).
     - "Ödünçtekiler" filtre çipi.
     - Kitap kartlarında ödünçteki kitaplar için kişi ikonlu rozet ve raf sırası.

3. **Yerelleştirme (TR & EN):**
   - `app_tr.arb` ve `app_en.arb` dosyalarına tüm ödünç ve sıralama anahtarları eklendi.
   - `uppercaseForLocale` ile Türkçe İ/I kurallarına tam uyumluluk sağlandı.

4. **Testler ve Kalite:**
   - `app/test/features/library/book_loans_test.dart`: 5 yeni birim testi (fiziksel sıra, ödünç verme, filtreleme, iade alma, veri temizleme).
   - `app/test/features/library/library_screen_test.dart` & `book_detail_screen_test.dart`: UI etkileşim testleri.
   - Toplam 134/134 test yeşil (%100 başarı).
   - `flutter analyze`: 0 issue.
   - Performans bütçeleri ve sentetik benchmarklar eksiksiz doğrulandı.
