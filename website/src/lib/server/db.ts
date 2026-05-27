import mysql from 'mysql2/promise';
import { env } from '$env/dynamic/private';

// ─── Types ────────────────────────────────────────────────────────────────────

export interface Character {
	name: string;
	level: number;
	race: string;
	gender: 'Male' | 'Female';
	class: string;
	online: boolean;
}

export interface Account {
	username: string;
	characters: Character[];
}

// ─── Connection pool ──────────────────────────────────────────────────────────

function getPool() {
	return mysql.createPool({
		host: env.DB_HOST || 'localhost',
		port: Number(env.DB_PORT) || 3306,
		user: env.DB_USER,
		password: env.DB_PASSWORD,
		waitForConnections: true,
		connectionLimit: 5
	});
}

let _pool: ReturnType<typeof mysql.createPool> | undefined;
function pool() {
	return (_pool ??= getPool());
}

// ─── Game data ────────────────────────────────────────────────────────────────

const RACES: Record<number, string> = {
	1: 'Human',
	2: 'Orc',
	3: 'Dwarf',
	4: 'Night Elf',
	5: 'Undead',
	6: 'Tauren',
	7: 'Gnome',
	8: 'Troll',
	10: 'Blood Elf',
	11: 'Draenei'
};

const CLASSES: Record<number, string> = {
	1: 'Warrior',
	2: 'Paladin',
	3: 'Hunter',
	4: 'Rogue',
	5: 'Priest',
	6: 'Death Knight',
	7: 'Shaman',
	8: 'Mage',
	9: 'Warlock',
	11: 'Druid'
};

function mapRow(row: any): Character {
	return {
		name: row.name,
		level: Number(row.level),
		race: RACES[row.race] ?? `Race ${row.race}`,
		gender: row.gender === 0 ? 'Male' : 'Female',
		class: CLASSES[row.class] ?? `Class ${row.class}`,
		online: Boolean(row.online)
	};
}

// ─── Queries ──────────────────────────────────────────────────────────────────

/** Characters currently in-game, sorted by level desc. */
export async function getOnlineCharacters(): Promise<Character[]> {
	const [rows] = await pool().query(`
		SELECT c.name, c.level, c.race, c.gender, c.class, 1 AS online
		FROM acore_characters.characters c
		JOIN acore_auth.account a ON a.id = c.account
		LEFT JOIN acore_auth.account_access aa ON aa.id = a.id AND aa.RealmID = -1
		WHERE c.online = 1
		  AND (aa.gmlevel IS NULL OR aa.gmlevel = 0)
		  AND a.username NOT LIKE 'RNDBOT%'
		ORDER BY c.level DESC
	`);
	return (rows as any[]).map(mapRow);
}

/** All accounts with their characters, sorted by account name then level desc. */
export async function getRoster(): Promise<Account[]> {
	const [rows] = await pool().query(`
		SELECT a.username, c.name, c.level, c.race, c.gender, c.class, c.online
		FROM acore_auth.account a
		JOIN acore_characters.characters c ON c.account = a.id
		LEFT JOIN acore_auth.account_access aa ON aa.id = a.id AND aa.RealmID = -1
		WHERE (aa.gmlevel IS NULL OR aa.gmlevel = 0)
		  AND a.username NOT LIKE 'RNDBOT%'
		ORDER BY a.username, c.level DESC
	`);

	const byAccount = new Map<string, Account>();
	for (const row of rows as any[]) {
		if (!byAccount.has(row.username)) {
			byAccount.set(row.username, { username: row.username, characters: [] });
		}
		byAccount.get(row.username)!.characters.push(mapRow(row));
	}
	return [...byAccount.values()];
}
