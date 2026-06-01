<script lang="ts">
	interface HighscoreEntry {
		rank: number;
		name: string;
		race: string;
		gender: 'Male' | 'Female';
		class: string;
		level: number;
		achievementPoints: number;
		achievementCount: number;
	}

	let { data }: { data: { highscores: HighscoreEntry[] } } = $props();

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

	const RANK_MEDAL: Record<number, { label: string; bg: string; text: string; border: string }> = {
		1: { label: '🥇', bg: 'bg-yellow-900/40', text: 'text-yellow-300', border: 'border-yellow-700/60' },
		2: { label: '🥈', bg: 'bg-gray-700/40',   text: 'text-gray-300',   border: 'border-gray-600/60'   },
		3: { label: '🥉', bg: 'bg-amber-900/30',  text: 'text-amber-600',  border: 'border-amber-800/50'  }
	};

	function classColor(cls: string) {
		return CLASS_COLORS[cls] ?? '#9ca3af';
	}

	function racePortraitUrl(race: string, gender: string) {
		return `/races/${race.toLowerCase().replace(/\s+/g, '')}-${gender.toLowerCase()}.jpg`;
	}

	function onImgError(e: Event) {
		const img = e.currentTarget as HTMLImageElement;
		img.style.display = 'none';
		const fallback = img.nextElementSibling as HTMLElement;
		if (fallback) fallback.style.removeProperty('display');
	}
</script>

<section class="px-6 pt-8 pb-12 max-w-4xl mx-auto">
	<!-- Header -->
	<div class="flex items-center gap-3 mb-8">
		<span class="text-3xl">🏆</span>
		<h1 class="medievalsharp-regular text-3xl text-amber-500 dark:text-amber-400">Achievement Highscores</h1>
	</div>

	{#if data.highscores.length === 0}
		<!-- Empty state -->
		<div class="flex flex-col items-center justify-center py-20 text-gray-500">
			<svg class="w-10 h-10 mb-3 opacity-30" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round"
					d="M16.5 18.75h-9m9 0a3 3 0 013 3h-15a3 3 0 013-3m9 0v-4.5A3.75 3.75 0 0012 10.5a3.75 3.75 0 00-3.75 3.75v4.5m0 0h9" />
			</svg>
			<p class="text-base italic">No achievements recorded yet.</p>
			<p class="text-sm mt-1 opacity-70">Be the first to earn some glory.</p>
		</div>
	{:else}
		<!-- Top 3 podium cards -->
		{#if data.highscores.length >= 1}
			<div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
				{#each data.highscores.slice(0, Math.min(3, data.highscores.length)) as entry}
					{@const medal = RANK_MEDAL[entry.rank]}
					<div class="relative {medal.bg} border {medal.border} rounded-xl px-5 py-5 flex flex-col items-center gap-3 text-center
						{entry.rank === 1 ? 'sm:order-2 ring-1 ring-yellow-600/30' : entry.rank === 2 ? 'sm:order-1' : 'sm:order-3'}">
						<!-- Medal badge -->
						<span class="absolute -top-3 left-1/2 -translate-x-1/2 text-2xl">{medal.label}</span>

						<!-- Portrait -->
						<div class="relative mt-2">
							<img
								src={racePortraitUrl(entry.race, entry.gender)}
								alt={entry.race}
								class="w-16 h-16 rounded-full object-cover object-top border-2"
								style="border-color: {classColor(entry.class)}66"
								onerror={onImgError}
							/>
							<div
								style="display:none; background-color:{classColor(entry.class)}22; color:{classColor(entry.class)}"
								class="w-16 h-16 rounded-full border-2 flex items-center justify-center font-bold text-xl"
							>
								{entry.name[0]}
							</div>
						</div>

						<!-- Name & class -->
						<div>
							<div class="font-bold text-gray-100 text-lg leading-tight">{entry.name}</div>
							<div class="text-xs mt-0.5" style="color:{classColor(entry.class)}">{entry.class}</div>
							<div class="text-xs text-gray-500 mt-0.5">{entry.race} · Lv {entry.level}</div>
						</div>

						<!-- Points -->
						<div class="mt-1">
							<div class="text-2xl font-bold {medal.text}">{entry.achievementPoints.toLocaleString()}</div>
							<div class="text-xs text-gray-500">achievement points</div>
						</div>

						<div class="text-xs text-gray-600">{entry.achievementCount} completed</div>
					</div>
				{/each}
			</div>
		{/if}

		<!-- Full leaderboard table (rank 4+, or all if fewer than 4) -->
		{#if data.highscores.length > 3}
			<div class="bg-gray-800/60 border border-gray-700 rounded-lg overflow-hidden">
				<table class="w-full text-sm">
					<thead>
						<tr class="bg-gray-900/50 border-b border-gray-700 text-xs text-gray-500 uppercase tracking-wider">
							<th class="px-4 py-3 text-left w-12">#</th>
							<th class="px-4 py-3 text-left">Character</th>
							<th class="px-4 py-3 text-right">Points</th>
							<th class="px-4 py-3 text-right hidden sm:table-cell">Achievements</th>
						</tr>
					</thead>
					<tbody class="divide-y divide-gray-700/40">
						{#each data.highscores.slice(3) as entry}
							<tr class="hover:bg-gray-700/20 transition-colors duration-100">
								<!-- Rank -->
								<td class="px-4 py-3 text-gray-500 font-mono text-xs">{entry.rank}</td>

								<!-- Character -->
								<td class="px-4 py-3">
									<div class="flex items-center gap-3">
										<div class="relative shrink-0 w-8 h-8">
											<img
												src={racePortraitUrl(entry.race, entry.gender)}
												alt={entry.race}
												class="w-8 h-8 rounded-full object-cover object-top border border-gray-600"
												onerror={onImgError}
											/>
											<div
												style="display:none; background-color:{classColor(entry.class)}22; color:{classColor(entry.class)}"
												class="w-8 h-8 rounded-full border border-gray-600 flex items-center justify-center text-xs font-bold"
											>
												{entry.name[0]}
											</div>
										</div>
										<div>
											<div class="text-gray-200 font-medium leading-tight">{entry.name}</div>
											<div class="text-xs mt-0.5">
												<span style="color:{classColor(entry.class)}">{entry.class}</span>
												<span class="text-gray-600"> · </span>
												<span class="text-gray-500">Lv {entry.level}</span>
											</div>
										</div>
									</div>
								</td>

								<!-- Points -->
								<td class="px-4 py-3 text-right font-semibold text-amber-400 font-mono">
									{entry.achievementPoints.toLocaleString()}
								</td>

								<!-- Achievement count -->
								<td class="px-4 py-3 text-right text-gray-500 hidden sm:table-cell">
									{entry.achievementCount}
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{/if}
	{/if}
</section>
