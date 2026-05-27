# Plan: Port wow-map companion website to AzerothCore (WotLK)

## Context

The existing `~/projects/wow-map` site was built for a cMaNGOS Classic server. The user wants the same companion website for their AzerothCore WotLK 3.3.5a private server. The database schema is similar but not identical, WotLK adds new races/classes/continents, and the DB names/credentials differ.

The existing project is **highly reusable** — all UI components, routing, and structure can be carried over. The work is mostly DB query updates and WotLK-specific data changes.

---

## Approach: Copy and adapt existing wow-map project

### 1. New project: `~/projects/wotlk-map`

Copy `~/projects/wow-map` as a starting point, then adapt it. Do not modify the original.

```bash
cp -r ~/projects/wow-map ~/projects/wotlk-map
```

---

### 2. Database — create a read-only web user on the server

```sql
-- Run on root@azerothcore
CREATE USER 'web'@'%' IDENTIFIED BY 'webpassword';
GRANT SELECT ON acore_characters.* TO 'web'@'%';
GRANT SELECT ON acore_auth.* TO 'web'@'%';
GRANT SELECT ON acore_world.* TO 'web'@'%';
FLUSH PRIVILEGES;
```

---

### 3. Update `.env`

**File:** `~/projects/wotlk-map/.env`

```env
DB_HOST=azerothcore
DB_PORT=3306
DB_USER=web
DB_PASSWORD=webpassword
DB_NAME=acore_characters
GAME_SERVER=azerothcore
GAME_PORT=8085
PUBLIC_DOWNLOAD_LINK=<link if any>
```

---

### 4. Update `db.ts` — AzerothCore schema differences

**File:** `~/projects/wotlk-map/src/lib/server/db.ts`

All DB names updated: `classiccharacters` → `acore_characters`, `classicrealmd` → `acore_auth`, `classicmangos` → `acore_world`.

Key query changes:

| Feature | cMaNGOS | AzerothCore |
|---|---|---|
| Auction table | `auction` | `auctionhouse` |
| Auction item join | `auction.itemguidlow` → `item` | `auctionhouse.itemguid` → `item_instance.guid` → `item_instance.itemEntry` → `item_template.entry` |
| GM filter | `account.gmlevel = 0` (inline column) | LEFT JOIN `account_access aa ON aa.id = a.id AND aa.RealmID = -1` then `(aa.gmlevel IS NULL OR aa.gmlevel = 0)` |
| Bot filter | `username NOT LIKE 'RNDBOT%'` | Same (or omit — friends-only server has no bots) |

**Updated auction query (conceptual):**
```sql
SELECT
  ah.id, ah.buyoutprice, ah.startbid, ah.lastbid, ah.time,
  it.name AS itemName, ii.count AS itemCount,
  c.name AS ownerName, a.username AS ownerAccount
FROM acore_characters.auctionhouse ah
JOIN acore_characters.item_instance ii ON ii.guid = ah.itemguid
JOIN acore_world.item_template it ON it.entry = ii.itemEntry
JOIN acore_characters.characters c ON c.guid = ah.itemowner
JOIN acore_auth.account a ON a.id = c.account
```

---

### 5. Update race/class data for WotLK

**File:** `~/projects/wotlk-map/src/lib/server/db.ts` (or a constants file)

WotLK adds Blood Elf (10), Draenei (11), and Death Knight (class 6). The race/class texture mappings and icon sets need updating.

- Add race IDs 10 (Blood Elf) and 11 (Draenei) to race mapping
- Add class ID 6 (Death Knight) to class mapping
- Update `static/races/` and `static/classes/` with WotLK assets (DK icon, BE/Draenei portraits)
- Update `race-texture.png` sprite sheet and `race-texture-mapping.json` for the new races

---

### 6. Update world map for WotLK continents

**File:** `~/projects/wotlk-map/src/lib/components/DeckGLMap.svelte`

WotLK has 4 continents (vs 2 in Classic):

| Map ID | Name |
|---|---|
| 0 | Eastern Kingdoms |
| 1 | Kalimdor |
| 530 | Outland |
| 571 | Northrend |

- Reuse existing EK/Kalimdor tile images from wow-map (copy `static/tiles/` as-is)
- Show EK and Kalimdor on the map; players on Outland (530) or Northrend (571) get a "player is in Outland/Northrend — map not available" indicator in the sidebar instead of a map pin
- Continent selector only shows EK and Kalimdor for now; Outland/Northrend can be added later once tiles are extracted

---

### 7. Update home page server rules

**File:** `~/projects/wotlk-map/src/routes/+page.svelte`

Update the displayed server rules to match actual rates on this server:
- 1.5× XP from kills, 3× from quests
- 2× drop rates (Normal/Uncommon/Rare/Epic)
- 2× boss group loot (dungeon gear)
- 10× reputation gain
- Double talent points
- All races/classes via mod-arac
- AoE looting via mod-aoe-loot
- Autobalanced difficulty

---

### 8. Deployment

Deploy to `root@azerothcore` alongside the game server, or a separate host.

```dockerfile
# Dockerfile is already present — update NODE_ENV, PORT as needed
```

Run as a systemd service or Docker container on the same VM, exposed on a chosen port (e.g. 3000). Optionally add to nginx/caddy for a domain.

---

## Files to modify

| File | Change |
|---|---|
| `.env` | New DB host, names, credentials |
| `src/lib/server/db.ts` | All queries updated for AzerothCore schema |
| `src/lib/components/DeckGLMap.svelte` | Add Outland/Northrend continent support |
| `src/routes/+page.svelte` | Update server rules display |
| `static/races/` | Add Blood Elf, Draenei portraits |
| `static/classes/` | Add Death Knight icon |
| `race-texture.png` + `race-texture-mapping.json` | Add WotLK races to sprite sheet |

## Files reused as-is (no changes needed)

- `src/lib/components/ServerStatus.svelte`
- `src/lib/components/PlayerCard.svelte`
- `src/lib/components/PlayerIcon.svelte`
- `src/lib/formatters.ts`
- `src/routes/players/`, `src/routes/stats/`, `src/routes/auctions/` (structure identical)
- `svelte.config.js`, `vite.config.ts`, `tsconfig.json`
- `Dockerfile`
- `package.json` (no new dependencies needed)

---

## Verification

1. `npm run dev` — site loads, no TS errors
2. Home page shows correct server status and online players
3. Map page shows player positions on EK/Kalimdor
4. Players page lists all accounts/characters
5. Stats page shows leaderboards
6. Auctions page lists active auction house items
7. No GM or bot accounts appear in public views
8. Death Knights / Blood Elves / Draenei display correctly with proper icons
