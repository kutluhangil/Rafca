# Faz 3 — Veri (A3)

**Durum: KAPALI.** Kabul kriteri geçildi: RLS testi 17/17, başka kullanıcının
satırı hiçbir sorguda dönmüyor.

Sahip olunan yol: `/supabase/**`. Blueprint'in Faz 3 tanımı Drift yerel şemasını
da bu faza veriyor, o yüzden `app/lib/core/database/**` de bu fazda dolduruldu
(kullanıcı onayı, 2026-08-27).

## Sunucu şeması

| Dosya | İçerik |
|-------|--------|
| `supabase/config.toml` | Yerel stack; anonim giriş açık, `extra_search_path` içinde `extensions` |
| `migrations/20260827090000_extensions.sql` | `pg_trgm`, `unaccent`, `spine_unaccent`, `spine_join_authors` |
| `migrations/20260827090100_books_index.sql` | Katalog, trigram + FTS + ISBN indeksleri, salt-okuma RLS |
| `migrations/20260827090200_user_data.sql` | `profiles`, `shelves`, `user_books`, `scans`; komut başına ayrı policy; yeni kullanıcıda profil trigger'ı |
| `tests/rls_test.sql` | pgTAP, 17 assertion |
| `harness/supabase_shim.sql` | Docker'sız çalıştırmak için `auth` şeması ve rolleri |
| `harness/run_tests.sh` | Sıfırdan veritabanı → shim → migration'lar → testler |

### Blueprint §6.1'de düzeltilen iki şey

`unaccent(text)` sözlüğünü çağrı anında çözdüğü için yalnızca STABLE; Postgres
onu generated column'a sokmuyor. Sözlüğü sabitleyen iki argümanlı IMMUTABLE
forma sarıldı (`spine_unaccent`). Yan fayda: varsayılan unaccent kuralları
`İ → I` ve `ı → i` katlıyor, yani §8.2'nin Türkçe I/İ özel durumu `lower()`
çağrılmadan önce zaten çözülmüş oluyor. Sıra bu yüzden önemli — önce unaccent,
sonra lower.

`array_to_string` da aynı sebeple STABLE (eleman tipinin çıktı fonksiyonu genel
halde immutable değil). `text[]` için bu geçerli olmadığından argüman tipini
daraltan `spine_join_authors` yazıldı.

### Kapsam dışı iki ekleme

- `user_books` üzerinde `book_id is not null or manual_title is not null`
  check'i. İkisi de boşsa kart render edilemez; bu bir durum değil, yukarıda
  bir hatadır.
- `books_index` üzerinde `anon`/`authenticated` için insert/update/delete
  revoke. Yazma policy'si zaten yok; yetkiyi de almak, sonradan yanlışlıkla
  eklenmiş bir `for all` policy'nin bile yazamamasını sağlıyor.

## Yerel şema (Drift)

`CatalogBooks`, `Shelves`, `UserBooks`, `Scans`, `SyncQueueEntries` +
`SyncQueueDao`. `schemaVersion` 1 → 2, `beforeOpen`'da `PRAGMA foreign_keys = ON`.

Sunucuda karşılığı olmayan iki alan var: `capture_path` (raf fotoğrafı ve sırt
kırpımı cihazda kalır, §5) ve `pending_sync`.

**`user_id` yerelde yok — bilinçli.** İlk kullanıcı hesap açılmadan tarama
yapar; anonim giriş bile ağ ister. Insert anında ortada bir kimlik yoktur, o
yüzden satır sunucuya çıkarken `auth.uid()` damgalanır.

**Kuyruk payload değil operasyon saklar.** Aynı satır tekrar sıraya girerse tek
kayda iner (`unique(entity, row_id)`), ve drainer push ederken satırın güncel
halini okur — sonradan düzenlenmiş bir satır için bayat snapshot gönderilmez.
`pending_sync` bayrağı ile kuyruk kaydı `SyncQueueDao` içinde aynı transaction'da
yazılır; ekranın gördüğü "senkronlanmadı" ile drainer'ın iş listesi ayrışamaz.

## Doğrulama

```
make db-start
make db-test      # 17/17
cd app && flutter analyze && flutter test   # temiz, 58/58
```

Docker Desktop bu makinede çalışmıyor: VM diski `/Volumes/PixelVault` üzerinde
ve o birim %100 dolu (147 MiB boş), containerd metadata yazamayıp
`input/output error` veriyor. `supabase start` bu yüzden koşulamadı.

Bunun yerine migration'lar ve pgTAP suite'i düz bir PostgreSQL 17 sunucusunda
koşacak hale getirildi (`supabase/harness/`). Shim yalnızca platformun sağladığı
yüzeyi taklit eder — `auth` şeması, `auth.uid()`, `anon`/`authenticated`
rolleri — ve `auth.uid()` platformdaki tanımın birebir aynısıdır; test edilen
şey policy'lerin kendisi olduğu için burada gevşetmek bütün suite'i anlamsız
kılardı. `supabase db reset` yalnızca `migrations/` ve `seed.sql` okuduğundan
shim gerçek projeye asla uygulanmaz.

Yan fayda: suite artık Docker gerektirmiyor, CI'da da koşabilir.
