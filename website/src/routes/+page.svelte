<script lang="ts">
	interface Character {
		name: string;
		level: number;
		race: string;
		gender: 'Male' | 'Female';
		class: string;
		online: boolean;
	}

	interface Account {
		username: string;
		characters: Character[];
	}

	let { data }: { data: { online: Character[]; roster: Account[] } } = $props();

	const CLASS_COLORS: Record<string, string> = {
		Warrior: '#C79C6E',
		Paladin: '#F58CBA',
		Hunter: '#ABD473',
		Rogue: '#FFF569',
		Priest: '#CECECE',
		'Death Knight': '#C41F3B',
		Shaman: '#0070DE',
		Mage: '#69CCF0',
		Warlock: '#9482C9',
		Druid: '#FF7D0A'
	};

	function classColor(cls: string) {
		return CLASS_COLORS[cls] ?? '#9ca3af';
	}

	function racePortraitUrl(race: string, gender: string) {
		return `/races/${race.toLowerCase().replace(/\s+/g, '')}-${gender.toLowerCase()}.jpg`;
	}

	function classIconUrl(cls: string) {
		return `/classes/${cls.toLowerCase().replace(/\s+/g, '')}.jpg`;
	}

	function onImgError(e: Event) {
		const img = e.currentTarget as HTMLImageElement;
		img.style.display = 'none';
		const fallback = img.nextElementSibling as HTMLElement;
		if (fallback) fallback.style.removeProperty('display');
	}
</script>

<!-- ── Online Now ─────────────────────────────────────────────────── -->
<section class="px-6 pt-8 pb-4 max-w-7xl mx-auto">
	<div class="flex items-center gap-3 mb-6">
		<span class="relative flex h-3 w-3">
			<span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
			<span class="relative inline-flex rounded-full h-3 w-3 bg-green-500"></span>
		</span>
		<h2 class="medievalsharp-regular text-2xl text-amber-500 dark:text-amber-400">Online Now</h2>
		{#if data.online.length > 0}
			<span class="text-xs font-mono bg-green-900/40 text-green-400 border border-green-800/60 px-2 py-0.5 rounded-full">
				{data.online.length}
			</span>
		{/if}
	</div>

	{#if data.online.length === 0}
		<div class="flex flex-col items-center justify-center py-14 text-gray-500">
			<svg class="w-10 h-10 mb-3 opacity-30" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" d="M12 3v1m0 16v1M4.22 4.22l.7.7m13.66 13.66.7.7M1 12h1m20 0h1M4.22 19.78l.7-.7M18.36 5.64l.7-.7" />
				<circle cx="12" cy="12" r="4" stroke-linecap="round"/>
			</svg>
			<p class="text-base italic">The tavern is quiet...</p>
			<p class="text-sm mt-1 opacity-70">No adventurers are currently online.</p>
		</div>
	{:else}
		<div class="flex flex-wrap gap-3">
			{#each data.online as char}
				<div class="flex items-center gap-3 bg-gray-800/70 border border-gray-700 hover:border-amber-700/40 rounded-lg px-4 py-3 min-w-52 transition-colors duration-150">
					<!-- Portrait with online dot -->
					<div class="relative shrink-0">
						<img
							src={racePortraitUrl(char.race, char.gender)}
							alt={char.race}
							class="w-12 h-12 rounded-full object-cover object-top border-2 border-gray-600"
							onerror={onImgError}
						/>
						<div
							style="display:none; background-color:{classColor(char.class)}33; color:{classColor(char.class)}"
							class="w-12 h-12 rounded-full border-2 border-gray-600 flex items-center justify-center font-bold text-lg"
						>
							{char.name[0]}
						</div>
						<span class="absolute bottom-0 right-0 w-3 h-3 rounded-full bg-green-500 border-2 border-gray-800 dark:border-gray-900"></span>
					</div>
					<!-- Info -->
					<div>
						<div class="font-semibold text-gray-100 text-base leading-snug">{char.name}</div>
						<div class="text-xs text-gray-400 mt-0.5">Level {char.level} · {char.race}</div>
						<div class="text-xs font-medium mt-0.5" style="color:{classColor(char.class)}">{char.class}</div>
					</div>
				</div>
			{/each}
		</div>
	{/if}
</section>

<!-- ── Divider ────────────────────────────────────────────────────── -->
<div class="max-w-7xl mx-auto px-6 py-2">
	<div class="border-t border-gray-700/60"></div>
</div>

<!-- ── Server Features ────────────────────────────────────────────── -->
<section class="px-6 pt-4 pb-4 max-w-7xl mx-auto">
	<div class="flex items-center gap-3 mb-6">
		<h2 class="medievalsharp-regular text-2xl text-amber-500 dark:text-amber-400">Server Features</h2>
	</div>

	<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">

		<div class="bg-gray-800/60 border border-gray-700 rounded-lg px-4 py-3.5 flex gap-3">
			<span class="text-2xl shrink-0 mt-0.5">⚔️</span>
			<div>
				<div class="text-sm font-semibold text-gray-100 mb-0.5">Boosted XP</div>
				<div class="text-xs text-gray-400">Quests give 3× the normal XP. Killing monsters gives 1.5×. Level at your own pace without the grind.</div>
			</div>
		</div>

		<div class="bg-gray-800/60 border border-gray-700 rounded-lg px-4 py-3.5 flex gap-3">
			<span class="text-2xl shrink-0 mt-0.5">😴</span>
			<div>
				<div class="text-sm font-semibold text-gray-100 mb-0.5">Always Rested</div>
				<div class="text-xs text-gray-400">Rested XP builds so fast you'll always have the bonus while playing. You'll also accumulate it twice as fast while logged out.</div>
			</div>
		</div>

		<div class="bg-gray-800/60 border border-gray-700 rounded-lg px-4 py-3.5 flex gap-3">
			<span class="text-2xl shrink-0 mt-0.5">✨</span>
			<div>
				<div class="text-sm font-semibold text-gray-100 mb-0.5">Double Talent Points</div>
				<div class="text-xs text-gray-400">You earn twice as many talent points as normal, letting you fill out your talent trees faster and more freely.</div>
			</div>
		</div>

		<div class="bg-gray-800/60 border border-gray-700 rounded-lg px-4 py-3.5 flex gap-3">
			<span class="text-2xl shrink-0 mt-0.5">🎁</span>
			<div>
				<div class="text-sm font-semibold text-gray-100 mb-0.5">Increased Drop Rates</div>
				<div class="text-xs text-gray-400">Common, Uncommon, Rare and Epic items all drop at 2× the normal rate. More loot, less frustration.</div>
			</div>
		</div>

		<div class="bg-gray-800/60 border border-gray-700 rounded-lg px-4 py-3.5 flex gap-3">
			<span class="text-2xl shrink-0 mt-0.5">🏅</span>
			<div>
				<div class="text-sm font-semibold text-gray-100 mb-0.5">10× Reputation</div>
				<div class="text-xs text-gray-400">Faction reputation is earned at 10 times the normal rate. Unlock faction rewards and mounts much sooner.</div>
			</div>
		</div>

		<div class="bg-gray-800/60 border border-gray-700 rounded-lg px-4 py-3.5 flex gap-3">
			<span class="text-2xl shrink-0 mt-0.5">🦅</span>
			<div>
				<div class="text-sm font-semibold text-gray-100 mb-0.5">Faster Flight Paths</div>
				<div class="text-xs text-gray-400">Taxis fly at twice the normal speed. Getting around the world is quicker without skipping the scenery.</div>
			</div>
		</div>

		<div class="bg-gray-800/60 border border-gray-700 rounded-lg px-4 py-3.5 flex gap-3">
			<span class="text-2xl shrink-0 mt-0.5">🗺️</span>
			<div>
				<div class="text-sm font-semibold text-gray-100 mb-0.5">Shared Flight Paths</div>
				<div class="text-xs text-gray-400">Discovering a flight point on one character automatically unlocks it on all your other characters too.</div>
			</div>
		</div>

		<div class="bg-gray-800/60 border border-gray-700 rounded-lg px-4 py-3.5 flex gap-3">
			<span class="text-2xl shrink-0 mt-0.5">📬</span>
			<div>
				<div class="text-sm font-semibold text-gray-100 mb-0.5">Instant Mail</div>
				<div class="text-xs text-gray-400">Mail between characters arrives in about a minute. Send gold and items to your alts without the wait.</div>
			</div>
		</div>

		<div class="bg-gray-800/60 border border-gray-700 rounded-lg px-4 py-3.5 flex gap-3">
			<span class="text-2xl shrink-0 mt-0.5">📈</span>
			<div>
				<div class="text-sm font-semibold text-gray-100 mb-0.5">Alt Level Boost</div>
				<div class="text-xs text-gray-400">Talk to any innkeeper to boost an alt character up to within 5 levels of your highest character. Great for trying new classes.</div>
			</div>
		</div>

		<div class="bg-gray-800/60 border border-gray-700 rounded-lg px-4 py-3.5 flex gap-3">
			<span class="text-2xl shrink-0 mt-0.5">⚖️</span>
			<div>
				<div class="text-sm font-semibold text-gray-100 mb-0.5">Scaled Difficulty</div>
				<div class="text-xs text-gray-400">Dungeons and encounters automatically scale to the size of your group, so solo play and small groups remain challenging and rewarding.</div>
			</div>
		</div>

		<div class="bg-gray-800/60 border border-gray-700 rounded-lg px-4 py-3.5 flex gap-3">
			<span class="text-2xl shrink-0 mt-0.5">🧬</span>
			<div>
				<div class="text-sm font-semibold text-gray-100 mb-0.5">Any Race, Any Class</div>
				<div class="text-xs text-gray-400">Want a Gnome Druid or a Human Shaman? Any race and class combination is available, beyond the normal restrictions.</div>
			</div>
		</div>

	</div>
</section>

<!-- ── Divider ────────────────────────────────────────────────────── -->
<div class="max-w-7xl mx-auto px-6 py-2">
	<div class="border-t border-gray-700/60"></div>
</div>

<!-- ── Roster ─────────────────────────────────────────────────────── -->
<section class="px-6 pt-4 pb-12 max-w-7xl mx-auto">
	<div class="flex items-center gap-3 mb-6">
		<h2 class="medievalsharp-regular text-2xl text-amber-500 dark:text-amber-400">Roster</h2>
		<span class="text-xs font-mono bg-amber-900/30 text-amber-500 border border-amber-800/40 px-2 py-0.5 rounded-full">
			{data.roster.length}
		</span>
	</div>

	<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
		{#each data.roster as account}
			<div class="bg-gray-800/60 border border-gray-700 rounded-lg overflow-hidden">
				<!-- Account header -->
				<div class="px-4 py-2.5 bg-gray-900/50 border-b border-gray-700 flex items-center gap-2">
					<svg class="w-3.5 h-3.5 text-amber-600 shrink-0" fill="currentColor" viewBox="0 0 20 20">
						<path d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" />
					</svg>
					<span class="medievalsharp-regular text-amber-400 text-sm tracking-wide truncate">{account.username}</span>
				</div>

				<!-- Characters list -->
				<ul class="divide-y divide-gray-700/40">
					{#each account.characters as char}
						<li
							class="flex items-center gap-2.5 px-3 py-2 transition-colors duration-100"
							class:bg-green-950={char.online}
							class:bg-opacity-30={char.online}
						>
							<!-- Class icon -->
							<div class="relative shrink-0 w-7 h-7">
								<img
									src={classIconUrl(char.class)}
									alt={char.class}
									class="w-7 h-7 rounded object-cover"
									onerror={onImgError}
								/>
								<div
									style="display:none; color:{classColor(char.class)}"
									class="w-7 h-7 rounded flex items-center justify-center text-xs font-bold bg-gray-700"
								>
									{char.class[0]}
								</div>
							</div>

							<!-- Name + class -->
							<div class="flex-1 min-w-0">
								<div class="flex items-center gap-1.5">
									<span class="text-sm text-gray-200 truncate leading-tight">{char.name}</span>
									{#if char.online}
										<span class="shrink-0 w-1.5 h-1.5 rounded-full bg-green-500"></span>
									{/if}
								</div>
								<span class="text-xs" style="color:{classColor(char.class)}">{char.class}</span>
							</div>

							<!-- Level badge -->
							<span class="shrink-0 text-xs font-mono text-amber-400 bg-gray-700/60 px-1.5 py-0.5 rounded">
								{char.level}
							</span>
						</li>
					{/each}
				</ul>
			</div>
		{/each}
	</div>
</section>
