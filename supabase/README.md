# شوف TV — باك-إند Supabase

## ⚡ دليل التثبيت والنشر

هذا الدليل يشرح خطوات نشر الباك-إند الكامل لتطبيق شوف TV.

---

### 📋 المتطلبات

1. تثبيت **Supabase CLI**:
   ```bash
   npm install -g supabase
   ```
2. رابط مشروعك: `https://gypchbvcqooeloymonsk.supabase.co`

---

### 🚀 خطوات النشر

#### الخطوة 1: تشغيل ملفات SQL

افتح **لوحة تحكم Supabase** ← **SQL Editor** وشغّل كل ملف **بالترتيب**:

| الترتيب | الملف | الوظيفة |
|---------|-------|---------|
| 1 | `001_schema.sql` | إنشاء 11 جدول |
| 2 | `002_indexes.sql` | فهارس الأداء |
| 3 | `003_rls.sql` | سياسات الأمان (RLS) |
| 4 | `004_realtime.sql` | الاشتراكات المباشرة |
| 5 | `005_seed.sql` | البيانات التجريبية |

> [!IMPORTANT]
> شغّلهم **بالترتيب** (001 ← 005). كل ملف يعتمد على اللي قبله.

#### الخطوة 2: تأكد من الجداول

بعد التشغيل، روح **Table Editor** في اللوحة. المفروض تشوف:

```
profiles, user_preferences, leagues, teams, matches,
match_events, match_lineups, standings, player_stats,
news, streaming_servers
```

#### الخطوة 3: نشر Edge Functions (اختياري)

لو تبي تستخدم الـ Edge Functions المحسّنة:

```bash
cd flutter_ui1

supabase login
supabase link --project-ref gypchbvcqooeloymonsk

supabase functions deploy get-league-details
supabase functions deploy get-match-details
supabase functions deploy update-live-match
```

> [!NOTE]
> الـ Edge Functions **اختيارية**. الـ `SupabaseService` فيه استعلامات مباشرة بديلة لكل البيانات.

#### الخطوة 4: تفعيل Realtime (تحقق)

روح **Database → Replication** في اللوحة. تأكد إن هذي الجداول مفعّل فيها Realtime:
- ✅ `matches`
- ✅ `standings`
- ✅ `match_events`

---

### 📂 هيكل المشروع

```
supabase/
├── migrations/
│   ├── 001_schema.sql          ← 11 جدول
│   ├── 002_indexes.sql         ← فهارس الأداء
│   ├── 003_rls.sql             ← سياسات الأمان
│   ├── 004_realtime.sql        ← الاشتراكات المباشرة
│   └── 005_seed.sql            ← بيانات تجريبية
└── functions/
    ├── get-league-details/
    │   └── index.ts            ← ترتيب + هدافين + صانعي أهداف
    ├── get-match-details/
    │   └── index.ts            ← مباراة + أحداث + بثوث
    └── update-live-match/
        └── index.ts            ← تحديث مباشر (أدمن)

lib/
└── services/
    └── supabase_service.dart   ← طبقة API في Flutter
```

---

### 🔌 كيف Flutter يستدعي كل Endpoint

```dart
import 'services/supabase_service.dart';

final api = SupabaseService.instance;

// ── الدوريات (شاشة اختيار الدوري) ──
final leagues = await api.getLeagues();

// ── تفاصيل الدوري (4 تابات) ──
final details = await api.getLeagueDetails('league-uuid');
// details['standings']     → الترتيب
// details['top_scorers']   → الهدافين
// details['top_assists']   → صانعي الأهداف
// details['recent_matches'] → آخر المباريات

// ── مباريات اليوم ──
final matches = await api.getMatchesByDate(DateTime.now());

// ── المباريات المباشرة ──
final live = await api.getLiveMatches();

// ── تفاصيل المباراة ──
final matchData = await api.getMatchDetails('match-uuid');
// matchData['match']   → معلومات المباراة
// matchData['events']  → الأحداث
// matchData['lineups'] → التشكيلة
// matchData['streams'] → السيرفرات

// ── سيرفرات البث ──
final servers = await api.getMatchStreams('match-uuid');

// ── الأخبار (مع تقسيم الصفحات) ──
final news = await api.getNews(limit: 20, offset: 0);
final breaking = await api.getNews(category: 'عاجل');

// ── إعدادات المستخدم ──
await api.updateUserPreferences({
  'theme_mode': 'dark',
  'match_sorting': 'favorite',
  'font_scale_details': 1.1,
});

// ── المفضلة ──
await api.toggleFavoriteTeam('team-uuid');
await api.toggleFavoriteLeague('league-uuid');

// ── البث المباشر (تحديث النتيجة لحظياً) ──
final channel = api.subscribeToMatch('match-uuid', (data) {
  print('النتيجة: ${data['home_score']} - ${data['away_score']}');
  print('الدقيقة: ${data['minute']}');
});

// إلغاء الاشتراك
await api.unsubscribe(channel);
```

---

### 📊 أمثلة ردود API

**`getMatchDetails()`:**
```json
{
  "match": {
    "id": "c100...",
    "status": "live",
    "home_score": 2,
    "away_score": 1,
    "minute": 82,
    "venue": "استاد الملك فهد الدولي",
    "home_team": { "name": "الهلال", "logo_url": "..." },
    "away_team": { "name": "النصر", "logo_url": "..." },
    "leagues": { "name": "دوري روشن السعودي" }
  },
  "events": [
    { "minute": 23, "event_type": "goal", "player_name": "ميتروفيتش" },
    { "minute": 45, "event_type": "goal", "player_name": "كريستيانو رونالدو" },
    { "minute": 67, "event_type": "goal", "player_name": "مالكوم" }
  ],
  "streams": [
    { "name": "سيرفر أساسي (Full HD)", "url": "...", "quality": "1080p", "priority": 1 },
    { "name": "سيرفر احتياطي 1 (HD)", "url": "...", "quality": "720p", "priority": 2 }
  ]
}
```

**`getLeagueDetails()`:**
```json
{
  "standings": [
    { "position": 1, "points": 60, "teams": { "name": "الهلال" }, "form": ["W","W","D","W","W"] },
    { "position": 2, "points": 55, "teams": { "name": "النصر" } }
  ],
  "top_scorers": [
    { "player_name": "ميتروفيتش", "goals": 18, "teams": { "name": "الهلال" } },
    { "player_name": "كريستيانو رونالدو", "goals": 16, "teams": { "name": "النصر" } }
  ],
  "top_assists": [
    { "player_name": "مالكوم", "assists": 12, "teams": { "name": "الهلال" } }
  ],
  "recent_matches": [...]
}
```

---

### 🧠 استراتيجية التخزين المؤقت (Cache)

| البيانات | مدة الكاش | السبب |
|----------|-----------|-------|
| الدوريات | 24 ساعة | نادراً تتغير |
| الترتيب | 60 ثانية | يتحدث بعد المباريات |
| المباريات المباشرة | 30 ثانية | بيانات لحظية |
| الأخبار | 5 دقائق | تحديث معتدل |
| السيرفرات | 10 ثواني | لازم تكون حالية |

---

### 🔐 ملاحظات الأمان

- كل **عمليات الكتابة** محصورة بـ `service_role` (الباك-إند فقط)
- **سيرفرات البث** تحتاج تسجيل دخول للقراءة
- **بيانات المستخدم** معزولة لكل مستخدم عبر RLS
- **جداول المحتوى** (دوريات، فرق، أخبار) قراءة عامة
- مفتاح **anon key** آمن للتوزيع — RLS يحمي كل البيانات
