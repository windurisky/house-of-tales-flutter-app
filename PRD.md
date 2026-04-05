# House of Tales — Product Requirements Document

**Version:** 2.0
**Date:** 2026-04-05
**Status:** Draft

---

## 1. Product Overview

**House of Tales** is a premium children's storybook reader app (ages 2–10) with illustrated, bilingual stories (English + Bahasa Indonesia). Parents see a clean, premium interface; children experience magical, vibrant storytelling.

### 1.1 Stack

| Layer | Technology | Status |
|---|---|---|
| **Mobile** | Flutter (Dart) | Not started |
| **Backend** | Go 1.24 / Gin / MySQL 8 / Redis | Built (needs changes) |
| **Auth** | Clerk (Google SSO, JWT) | Built |
| **Design System** | Pencil (.pen) | Built |

---

## 2. Monetization — What's Changing

### 2.1 Current State (Backend as-built)

The backend currently implements a **per-story purchase** model:

| Feature | How It Works Today |
|---|---|
| **Story Tiers** | `free`, `premium` (1 coin), `tailored` (2 coins) |
| **Primary Payment** | Talecoins — buy coins via IAP, spend coins to buy individual stories |
| **Free Stories** | Unlocked by watching a rewarded ad (24h temporary access) |
| **Access Model** | Per-story: `owned` / `ad_unlocked` / `requires_purchase` / `requires_ad` |
| **Signup Bonus** | 2 Talecoins on first sync |

**Relevant backend files:**
- Access logic: `internal/service/access_service.go`
- Purchase logic: `internal/service/purchase_service.go`
- Talecoin logic: `internal/service/talecoin_service.go`
- Ad unlock logic: `internal/service/ad_unlock_service.go`
- Models: `internal/model/{story,purchase,talecoin,ad_unlock}.go`

### 2.2 New Model: Subscription-First

| Feature | New Behavior |
|---|---|
| **Primary Payment** | **Subscription** (monthly / yearly) |
| **Free Trial** | **3 days, no credit card required** |
| **Trial Access** | Full catalog, unlimited reading |
| **Post-Trial (No Sub)** | Read first **2 pages** only. Page 3 shows **top half** with **subscription CTA overlay** (frosted glass) on bottom half |
| **Story Tiers** | **Removed** — all stories are equal. Subscription unlocks everything |
| **Ad Unlocks** | **Removed** — no longer needed with subscription model |
| **Per-Story Purchase** | **Removed** — no more buying individual stories with Talecoins |

### 2.3 Talecoins — New Role (Secondary)

Talecoins shift from primary currency to a **secondary/social currency**:

| Use Case | Detail |
|---|---|
| **Subscribe via Talecoins** | Alternative to credit card — pay subscription with Talecoins (monthly cost in coins TBD) |
| **Gift Talecoins** | Send Talecoins to friends/family so they can subscribe |
| **Earn Talecoins** | Honest story reviews, referral rewards, achievements |
| **Buy Talecoins** | IAP bundles remain (5/12/25 coin packs) |
| **Signup Bonus** | Keep 2 Talecoins on signup |

**What Talecoins can NOT do anymore:**
- ~~Buy individual stories~~ (no more per-story purchase)
- ~~Unlock via ads~~ (no more ad unlock system)

---

## 3. Backend Changes Required

### 3.1 New: Subscription System

#### 3.1.1 Database — New `subscriptions` Table

```sql
CREATE TABLE subscriptions (
    id                    CHAR(36) PRIMARY KEY,
    user_id               CHAR(36) NOT NULL UNIQUE,
    plan                  ENUM('monthly', 'yearly') DEFAULT NULL,
    status                ENUM('trial', 'active', 'expired', 'cancelled') NOT NULL DEFAULT 'trial',
    trial_started_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    trial_ends_at         TIMESTAMP NOT NULL,
    current_period_start  TIMESTAMP DEFAULT NULL,
    current_period_end    TIMESTAMP DEFAULT NULL,
    payment_method        ENUM('google_play', 'apple_iap', 'talecoins') DEFAULT NULL,
    store_transaction_id  VARCHAR(255) DEFAULT NULL,
    cancelled_at          TIMESTAMP DEFAULT NULL,
    created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### 3.1.2 New Model — `internal/model/subscription.go`

```go
type Subscription struct {
    ID                  string         `db:"id" json:"id"`
    UserID              string         `db:"user_id" json:"user_id"`
    Plan                sql.NullString `db:"plan" json:"plan,omitempty"`
    Status              string         `db:"status" json:"status"`
    TrialStartedAt      time.Time      `db:"trial_started_at" json:"trial_started_at"`
    TrialEndsAt         time.Time      `db:"trial_ends_at" json:"trial_ends_at"`
    CurrentPeriodStart  *time.Time     `db:"current_period_start" json:"current_period_start,omitempty"`
    CurrentPeriodEnd    *time.Time     `db:"current_period_end" json:"current_period_end,omitempty"`
    PaymentMethod       sql.NullString `db:"payment_method" json:"payment_method,omitempty"`
    StoreTransactionID  sql.NullString `db:"store_transaction_id" json:"-"`
    CancelledAt         *time.Time     `db:"cancelled_at" json:"cancelled_at,omitempty"`
    CreatedAt           time.Time      `db:"created_at" json:"created_at"`
    UpdatedAt           time.Time      `db:"updated_at" json:"updated_at"`
}
```

#### 3.1.3 New Endpoints — Subscription

| Method | Path | Purpose |
|---|---|---|
| `POST` | `/api/v1/subscriptions/start-trial` | Start 3-day free trial (auto on onboarding complete) |
| `GET` | `/api/v1/subscriptions/status` | Get current subscription status + expiry |
| `POST` | `/api/v1/subscriptions/subscribe` | Subscribe via IAP (Google Play / Apple) — PIN required |
| `POST` | `/api/v1/subscriptions/subscribe-with-talecoins` | Subscribe using Talecoins — PIN required |
| `POST` | `/api/v1/subscriptions/cancel` | Cancel subscription — PIN required |
| `POST` | `/api/v1/subscriptions/restore` | Restore IAP subscription (re-validate with store) |

#### 3.1.4 New Sentinel Errors

```go
var (
    ErrTrialAlreadyUsed      = errors.New("trial already used")
    ErrAlreadySubscribed     = errors.New("already has active subscription")
    ErrSubscriptionNotFound  = errors.New("no subscription found")
    ErrSubscriptionExpired   = errors.New("subscription has expired")
)
```

### 3.2 New: Talecoin Gifting

#### 3.2.1 Database — New `talecoin_gifts` Table

```sql
CREATE TABLE talecoin_gifts (
    id              CHAR(36) PRIMARY KEY,
    sender_id       CHAR(36) NOT NULL,
    recipient_email VARCHAR(255) NOT NULL,
    recipient_id    CHAR(36) DEFAULT NULL,
    amount          INT NOT NULL,
    message         VARCHAR(200) DEFAULT NULL,
    status          ENUM('pending', 'claimed', 'expired') DEFAULT 'pending',
    claimed_at      TIMESTAMP DEFAULT NULL,
    expires_at      TIMESTAMP NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (recipient_id) REFERENCES users(id) ON DELETE SET NULL
);
```

#### 3.2.2 New Endpoints — Gifting

| Method | Path | Purpose |
|---|---|---|
| `POST` | `/api/v1/talecoins/gift` | Send Talecoins to another user (by email) — PIN required |
| `GET` | `/api/v1/talecoins/gifts/sent` | List gifts I've sent |
| `GET` | `/api/v1/talecoins/gifts/received` | List gifts I've received |
| `POST` | `/api/v1/talecoins/gifts/:id/claim` | Claim a pending gift |

### 3.3 New: Talecoin Rewards

#### 3.3.1 New Endpoints — Rewards

| Method | Path | Purpose |
|---|---|---|
| `POST` | `/api/v1/talecoins/reward/review` | Earn Talecoins for an honest story review |
| `POST` | `/api/v1/talecoins/reward/referral` | Earn Talecoins when a referred user signs up |
| `GET` | `/api/v1/talecoins/rewards/history` | List earned rewards |

#### 3.3.2 Reward Amounts (Suggested)

| Action | Reward |
|---|---|
| Story review (first review per story) | 1 Talecoin |
| Referral (referred user completes onboarding) | 3 Talecoins |

### 3.4 Modified: Access Control

**Current** (`internal/service/access_service.go`): Checks per-story purchases + ad unlocks.

**New logic:**

```
CheckAccess(userID, storyID):
    1. Get user's subscription
    2. If subscription.status == "active" OR (status == "trial" AND trial_ends_at > NOW()):
         → return { status: "full_access" }
    3. Else (no subscription, trial expired, or cancelled):
         → return { status: "preview", preview_pages: 2 }
```

**New `AccessStatus` model:**

```go
type AccessStatus struct {
    Status       string        `json:"status"`        // "full_access" | "preview"
    PreviewPages int           `json:"preview_pages,omitempty"` // 2 (only when preview)
    TotalPages   int           `json:"total_pages,omitempty"`
    Subscription *Subscription `json:"subscription,omitempty"`
}
```

- `full_access` — subscribed or in trial, read everything
- `preview` — can read pages 1–2, page 3 shows half with paywall overlay

### 3.5 Modified: Story Pages Endpoint

`GET /api/v1/stories/:id/pages` — behavior changes:

| User State | Pages Returned |
|---|---|
| Subscribed / In Trial | All pages |
| No subscription | Pages 1–2 fully, page 3 with `is_preview: true` flag, pages 4+ omitted |

Response for non-subscriber:
```json
{
  "data": [
    { "page_number": 1, "text_en": "...", "illustration_url": "...", "is_preview": false },
    { "page_number": 2, "text_en": "...", "illustration_url": "...", "is_preview": false },
    { "page_number": 3, "text_en": "...", "illustration_url": "...", "is_preview": true }
  ],
  "meta": { "total_pages": 12, "is_gated": true }
}
```

### 3.6 Modified: `talecoin_transactions.type` Enum

```sql
ALTER TABLE talecoin_transactions MODIFY COLUMN type
    ENUM(
        'signup_bonus',
        'iap_purchase',
        'story_purchase',       -- kept for historical records
        'gift_sent',            -- NEW
        'gift_received',        -- NEW
        'review_reward',        -- NEW
        'referral_reward',      -- NEW
        'subscription_payment'  -- NEW (talecoin subscription)
    );
```

### 3.7 Modified: Child Profile

Add `avatar_id` to track which avatar the child selected:

```sql
ALTER TABLE child_profiles ADD COLUMN avatar_id VARCHAR(50) DEFAULT NULL AFTER gender;
```

Update `ChildProfile` model and `POST /children` + `PUT /children/:id` DTOs.

### 3.8 Deprecated (Keep Code, Stop Using)

These features remain in the codebase for historical data but are no longer actively used:

| Feature | Why Deprecated | What to Do |
|---|---|---|
| **Per-story purchases** (`POST /purchases`) | Subscription replaces per-story buying | Keep endpoint, return 410 Gone with migration message |
| **Ad unlocks** (`POST /ad-unlocks`) | Subscription replaces ad-gated access | Keep endpoint, return 410 Gone |
| **Story tiers** (`stories.tier`) | All stories equal under subscription | Keep column, ignore in access logic |
| **Story talecoin cost** (`stories.talecoin_cost`) | No more per-story pricing | Keep column, ignore in access logic |

### 3.9 New Files Summary

Following the existing architecture pattern (`handler → service → repository`):

| Layer | New Files |
|---|---|
| **Model** | `subscription.go`, `gift.go`, `reward.go` |
| **Repository** | `subscription_repository.go`, `gift_repository.go`, `reward_repository.go` |
| **Service** | `subscription_service.go`, `gift_service.go`, `reward_service.go` |
| **Handler** | `subscription_handler.go`, `gift_handler.go`, `reward_handler.go` |
| **DTO** | `subscription.go`, `gift.go`, `reward.go` |
| **Migration** | `008_create_subscriptions.{up,down}.sql`, `009_create_talecoin_gifts.{up,down}.sql`, `010_add_avatar_to_child_profiles.{up,down}.sql`, `011_add_transaction_types.{up,down}.sql` |
| **Modified** | `access_service.go` (subscription-based logic), `story_handler.go` (page gating) |

---

## 4. Mobile App — Flutter

### 4.1 Architecture (To Be Built)

| Concern | Choice |
|---|---|
| **State Management** | Riverpod (or Provider — TBD) |
| **Navigation** | GoRouter |
| **HTTP Client** | Dio (with Clerk token interceptor) |
| **Secure Storage** | flutter_secure_storage |
| **Fonts** | google_fonts (Fraunces + Nunito) |
| **Localization** | flutter_localizations + intl (EN + ID) |
| **IAP** | in_app_purchase (official Flutter plugin) |

### 4.2 Navigation Structure

```
App Launch
  │
  ├─ No Clerk Session → LoginScreen
  │
  └─ Has Session → Sync with Backend
       │
       ├─ No Child Profile → OnboardingFlow
       │    ├─ Step 1: ChildNameScreen
       │    ├─ Step 2: ChildBirthdayScreen
       │    ├─ Step 3: AvatarSelectScreen
       │    └─ Step 4: PinSetupScreen
       │         └─ On complete: start trial → MainTabs
       │
       └─ Has Child Profile → MainTabs
            ├─ Tab 1: Home (HomeScreen → CategoryScreen → BookDetailScreen → StoryReaderScreen)
            ├─ Tab 2: Explore (ExploreScreen → CategoryScreen → BookDetailScreen → StoryReaderScreen)
            ├─ Tab 3: Library (LibraryScreen → BookDetailScreen → StoryReaderScreen)
            └─ Tab 4: Profile (ProfileScreen → SubscriptionScreen / TalecoinStoreScreen / GiftScreen / SettingsScreen)
```

### 4.3 Screen Inventory

#### Authentication

| Screen | Description |
|---|---|
| **LoginScreen** | Google SSO via Clerk. Warm, branded splash with "Sign in with Google" button |

#### Onboarding (4 Steps)

| Screen | Input | Validation | Notes |
|---|---|---|---|
| **ChildNameScreen** | Text field | Required, 1–50 chars | "What's your little one's name?" |
| **ChildBirthdayScreen** | Year + Month scroll pickers | Year + month required | Used for age-based recommendations |
| **AvatarSelectScreen** | Grid of animal avatars | Must select one | Each avatar has boy/girl variant — **soft gender determination** without explicitly asking. E.g., fox with bow = girl, fox with bandana = boy |
| **PinSetupScreen** | 4-digit PIN pad | Enter + confirm must match | "Set a Parent PIN" — bcrypt hashed server-side |

On completion: `POST /children` → `POST /users/pin` → `POST /subscriptions/start-trial` → Home

#### Main App

| Screen | Tab | Description |
|---|---|---|
| **HomeScreen** | Home | Greeting ("Hi {name}!"), continue reading card, recommended stories, category chips |
| **ExploreScreen** | Explore | Browse by category (animals, adventure, magic, calming), featured collections |
| **LibraryScreen** | Library | Reading history, bookmarked stories |
| **ProfileScreen** | Profile | Child info, subscription status, Talecoins balance, language, PIN, sign out |

#### Story Flow

| Screen | Description |
|---|---|
| **CategoryScreen** | Filtered story list by category, paginated infinite scroll |
| **BookDetailScreen** | Cover illustration, title, synopsis, age range, read time, rating. CTA: "Start Reading" (subscribed) or "Subscribe to Read" (not subscribed) |
| **StoryReaderScreen** | Full-screen horizontal page reader. Pages 1–2 always readable. Page 3+: if not subscribed, show top half with frosted glass subscription overlay |

#### Subscription & Payment

| Screen | Description |
|---|---|
| **SubscriptionScreen** | Monthly/yearly plan cards, trial info, "Subscribe" CTA, "Pay with Talecoins" option, restore purchase link |
| **TalecoinStoreScreen** | Buy Talecoin bundles (5/12/25), transaction history |
| **GiftTalecoinsScreen** | Send Talecoins to a friend/family by email, add a message |

#### Search

| Screen | Description |
|---|---|
| **SearchScreen** | Search input with debounce, recent searches, results grid |

### 4.4 Subscription Paywall UX

When a non-subscribed user (trial expired) reaches **page 3** of any story:

```
┌──────────────────────────────────┐
│                                  │
│   [Page 3 illustration]         │
│                                  │
│   "The little fox crept          │
│    through the moonlit           │
│    garden, where flowers..."     │  ← Top half visible, text fades out
│                                  │
│ ┄┄┄┄┄┄ gradient fade ┄┄┄┄┄┄┄┄┄ │
│ ┌──────────────────────────────┐ │
│ │                              │ │
│ │   ✨ Keep the Magic Going!   │ │  ← Frosted glass / blur overlay
│ │                              │ │
│ │   Subscribe to unlock all    │ │
│ │   stories for {child_name}.  │ │
│ │                              │ │
│ │   ┌────────────────────────┐ │ │
│ │   │    Subscribe Now       │ │ │  ← color-brand-orange CTA
│ │   └────────────────────────┘ │ │
│ │                              │ │
│ │   Restore Purchase           │ │  ← text link
│ │                              │ │
│ └──────────────────────────────┘ │
└──────────────────────────────────┘
```

- Page 3 illustration shows fully
- Page 3 text shows top portion, fades out with a gradient
- Bottom half: frosted glass overlay with subscription CTA
- Tapping "Subscribe Now" → navigates to SubscriptionScreen
- Swiping to page 4+ is blocked entirely

---

## 5. Onboarding — Avatar & Gender

### 5.1 Avatar Grid

8 animal characters, each with 2 visual variants:

| Animal | Boy Variant | Girl Variant |
|---|---|---|
| Fox | Bandana, adventurer outfit | Bow, flower crown |
| Bunny | Explorer hat | Ribbon ears |
| Lion | Crown, cape | Tiara, necklace |
| Bear | Scarf, backpack | Hair bow, dress |
| Unicorn | Star marking | Heart marking |
| Cat | Collar, bowtie | Bell, bow |
| Dog | Bandana | Flower collar |
| Panda | Baseball cap | Hair clips |

### 5.2 Gender Flow

1. User sees all 8 animals as a grid (no gender labels visible)
2. Tapping an animal shows two variants side-by-side (no "boy"/"girl" labels — just visual style)
3. User picks the variant they like
4. The selected variant determines `gender` field sent to `POST /children`
5. A "Skip" link at the bottom sets `gender` to `null` (no preference)

This avoids explicitly asking "is your child a boy or a girl?" while still enabling gender-based story recommendations.

---

## 6. Access Control — New Logic

### 6.1 Decision Tree

```
User requests story pages
  │
  ├─ Has active subscription (status = 'active')
  │    └─ Return ALL pages → full_access
  │
  ├─ In trial (status = 'trial' AND trial_ends_at > NOW())
  │    └─ Return ALL pages → full_access
  │
  └─ No subscription / trial expired / cancelled
       │
       ├─ Pages 1–2: Return fully (is_preview: false)
       ├─ Page 3: Return with is_preview: true (client renders top-half + overlay)
       └─ Pages 4+: NOT returned at all
```

### 6.2 What Happens to Existing Features

| Old Feature | Decision | Reason |
|---|---|---|
| `stories.tier` column | **Keep, ignore** | Historical data. All stories treated equally under subscription |
| `stories.talecoin_cost` column | **Keep, ignore** | No longer used for per-story pricing |
| `purchases` table | **Keep, read-only** | Users who bought stories pre-migration keep permanent access. Access check: if user has a purchase record for a story, grant `full_access` regardless of subscription |
| `ad_unlocks` table | **Keep, read-only** | No new ad unlocks created. Existing active unlocks honored until they expire |
| `POST /purchases` endpoint | **Deprecate** | Return `410 Gone` with message: "Per-story purchases are no longer available. Please subscribe." |
| `POST /ad-unlocks` endpoint | **Deprecate** | Return `410 Gone` with message: "Ad unlocks are no longer available. Please subscribe." |

### 6.3 Updated Access Check (Pseudocode)

```
CheckAccess(userID, storyID):
    // 1. Legacy: honor existing purchases
    if hasPurchase(userID, storyID):
        return full_access
    
    // 2. Legacy: honor active ad unlocks (until they expire)
    if hasActiveAdUnlock(userID, storyID):
        return full_access
    
    // 3. Subscription check
    sub = getSubscription(userID)
    if sub != nil AND (sub.status == "active" OR (sub.status == "trial" AND sub.trial_ends_at > now)):
        return full_access
    
    // 4. No access
    return preview (pages 1-2 + half of page 3)
```

---

## 7. Talecoin Economy — Updated

### 7.1 How Talecoins Flow

```
EARN                              SPEND
─────                             ─────
Signup bonus (2)          ───→    Subscribe via Talecoins
IAP purchase (5/12/25)    ───→    Gift to friend/family
Story review reward (1)
Referral reward (3)
Receive gift from others
```

### 7.2 Subscribe with Talecoins

- Monthly subscription cost in Talecoins: **TBD** (e.g., 10 Talecoins/month)
- Requires PIN verification
- Creates subscription with `payment_method: 'talecoins'`
- Deducts Talecoins from balance
- Does NOT auto-renew — user must manually re-subscribe each month (no surprise charges)

### 7.3 Gifting Flow

1. Sender taps "Gift Talecoins" in Profile → GiftTalecoinsScreen
2. Enters recipient's email + amount + optional message
3. PIN verification
4. Backend: deducts from sender, creates `talecoin_gifts` record with status `pending`
5. If recipient has an account: gift is auto-claimed, credited immediately
6. If recipient has no account: gift stays `pending`, claimed when they sign up (matched by email)
7. Unclaimed gifts expire after 30 days

### 7.4 Rewards

| Trigger | Reward | Constraints |
|---|---|---|
| Story review | 1 Talecoin | Max 1 reward per story. Review must be ≥ 20 chars |
| Referral | 3 Talecoins (both parties) | Referrer + referee each get 3. Referee must complete onboarding |

---

## 8. Implementation Priority

### Phase 1 — Core MVP (Backend + Mobile)

**Backend:**
1. Migration: `subscriptions` table + `avatar_id` on `child_profiles`
2. Subscription service: `start-trial`, `status`
3. Modified access service: subscription-based logic (with legacy purchase/ad-unlock fallback)
4. Modified story pages endpoint: page gating for non-subscribers
5. Modified child profile: accept `avatar_id`

**Mobile:**
1. Flutter project setup (architecture, theme from design tokens, navigation)
2. Clerk auth integration (login screen)
3. Onboarding flow (4 steps: name → birthday → avatar → PIN)
4. Auto-start trial on onboarding complete
5. Home screen (greeting, recommended stories, categories)
6. Story reader with subscription paywall (page 3 gate)
7. Bottom tab navigation (Home, Explore, Library, Profile)

### Phase 2 — Subscription & Payment

**Backend:**
8. Subscription: `subscribe` (IAP validation), `cancel`, `restore`
9. Subscription: `subscribe-with-talecoins`
10. Deprecate purchase + ad-unlock endpoints (410 Gone)

**Mobile:**
11. Subscription plans screen
12. IAP integration (Google Play / Apple)
13. Subscribe with Talecoins flow
14. Restore purchase flow
15. Subscription status in profile

### Phase 3 — Full Experience

**Mobile:**
16. Explore screen (categories, featured)
17. Library screen (reading history)
18. Search screen
19. Book detail screen
20. Category screen (paginated)
21. Profile/Settings screen
22. Talecoin store screen (IAP bundles)

### Phase 4 — Talecoins Social

**Backend:**
23. Gifting service + endpoints
24. Reward service + endpoints (reviews, referrals)
25. New transaction types migration

**Mobile:**
26. Gift Talecoins screen
27. Story review flow (with Talecoin reward)
28. Referral system (share link, track signups)
29. Rewards history

### Phase 5 — Polish

30. Dark mode (design tokens already support adding modes)
31. Push notifications (trial expiring, new stories, gift received)
32. Offline reading (download stories)
33. Animations & micro-interactions
34. Reading progress sync across devices

---

## 9. Security & Compliance

### 9.1 Parental Controls

- **4-digit PIN** required for: subscribing, cancelling subscription, buying Talecoins, sending gifts, changing settings
- PIN is bcrypt-hashed server-side (cost 10), never stored on device
- No credit card required for trial (reduces friction)

### 9.2 COPPA Compliance

- Minimal child PII: name, birth month/year, avatar selection only
- No PII logging outside debug mode
- No third-party analytics on child-facing screens
- Data deletion available via account settings
- Parental consent implied via PIN gate

### 9.3 Payment Security

- IAP receipts validated server-side only (never trust client)
- Talecoin balance changes are atomic (database-level debit check)
- Transaction ledger is append-only (immutable audit trail)
- All payment actions require PIN

---

## 10. Design System

Fully built in `/house-of-tales-mobile.pen`:

- **52+ design tokens** — colors, typography, spacing, radius, shadows, opacity
- **27 reusable components** — NavBar, TabBar, Input, Search, Badges (5), Toggle (2), Avatar (4), Progress (2), Chips (2), Rating, Snackbar (3), BottomSheet, EmptyState, Skeleton (2)
- **1 designed screen** — Onboarding Welcome
- **Fonts** — Fraunces (serif headings) + Nunito (sans-serif body)
- **Palette** — Warm off-white (#FDFBF7), Mint green (#A8E6CF), Sunny orange (#FF8B3D), Dark teal (#1A3C40)

---

## 11. Success Metrics

| Metric | Target |
|---|---|
| Trial → Subscription Conversion | > 15% |
| Day 7 Retention | > 40% |
| Average Reading Session | > 8 min |
| Stories Read / Week (subscribed) | > 3 |
| Talecoin Gift Adoption | > 5% of users gift within 30 days |
| App Store Rating | > 4.5 |
