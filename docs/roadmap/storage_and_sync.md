# Depolama & Senkronizasyon Yol Haritası

## Gereksinimler
- Online/offline veri bütünlüğü, konflikt çözümü.
- Otomatik yedekleme / geri yükleme.
- Production veritabanı katmanı + migration stratejisi.
- Çoklu platform senkron API.

## Mimari Önerisi
1. **Veri Katmanı**
   - Sunucu: PostgreSQL + Hasura/Prisma ORM veya Nest/Drift backend.
   - Mobil/Web: `drift` (sqlite/sqlcipher) + `Hive` (cache) kombinasyonu.
   - Tenant bazlı partitioning (Postgres schemas).
2. **Sync Engine**
   - `SyncService`: çekirdek orchestrator.
   - `sync_tasks/` modülleri (session notes, appointments, billing vs.).
   - CRDT benzeri sürümleme (`vector clock`, `last-write-wins`, `operational transform`).
   - Conflict policy: user prompt + otomatik birleştirme.
3. **Backup & Restore**
   - Yerel incremental backup (encrypted) + cloud snapshot.
   - Admin panelinden geri yükleme.
4. **Migration Stratejisi**
   - Flutter tarafında `drift` migration dosyaları.
   - Backend için `db/migrations` (sqitch/liquibase/prisma migrate).
   - CI pipeline: migration lint + rollback testi.
5. **Data Access Layer**
   - Repository pattern: `SessionRepository`, `AppointmentRepository`, `BillingRepository`.
   - GraphQL/REST adapter abst.
6. **Queue & Retry**
   - `offline_queue` tabelası: pending ops (create/update/delete).
   - Exponential backoff + jitter.
   - Background isolate ile sync.
7. **Observability**
   - Sync metrics: latency, conflict count, last sync timestamp.
   - `PerformanceService` ile entegrasyon.

## Adım Planı
1. `lib/data/` klasörü altında offline DB setup.
2. Sync manifest (`assets/config/sync_manifest.json`).
3. Conflict resolver helper + unit test.
4. Backup scheduler (örn. `Workmanager`/`android_alarm_manager_plus`).
5. Admin/DevOps için migration scriptleri.
6. Monitoring dashboard + alert koşulları.

## Açık Sorular
- Production DB için hangi hosting (RDS, Supabase)?
- Offline storage boyutu limiti?
- Senkron sıklığı ve veri SLA'sı?
