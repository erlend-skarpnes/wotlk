<script lang="ts">
	interface ChallengeInfo {
		key: string;
		name: string;
		title: string;
		description: string;
	}

	interface CharacterChallenge {
		name: string;
		level: number;
		race: string;
		gender: 'Male' | 'Female';
		class: string;
		online: boolean;
		challenges: string[];
	}

	let { data }: { data: { challenges: ChallengeInfo[]; characters: CharacterChallenge[] } } = $props();

	const CLASS_COLORS: Record<string, string> = {
		Warrior: '#C79C6E', Paladin: '#F58CBA', Hunter: '#ABD473',
		Rogue: '#FFF569', Priest: '#CECECE', 'Death Knight': '#C41F3B',
		Shaman: '#0070DE', Mage: '#69CCF0', Warlock: '#9482C9', Druid: '#FF7D0A'
	};

	function classColor(cls: string) { return CLASS_COLORS[cls] ?? '#9ca3af'; }

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

<svelte:head>
	<title>Azeroth · Challenges</title>
</svelte:head>

<section class="px-6 pt-8 pb-12 max-w-6xl mx-auto">
	<!-- Header -->
	<div class="flex items-center gap-3 mb-2">
		<span class="text-3xl">🎯</span>
		<h1 class="medievalsharp-regular text-3xl text-amber-500 dark:text-amber-400">Challenges</h1>
	</div>
	<p class="text-sm text-gray-400 mb-8">
		Optional, self-imposed difficulty modifiers. Activate one (or several, if they don't conflict) at the
		Shrine of Challenge near your starting graveyard, before level 2 (or level 55 for Death Knights).
		Each one grants and equips a title the moment you begin, so everyone can see what you're running.
	</p>

	<!-- Challenge cards -->
	<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 mb-10">
		{#each data.challenges as challenge}
			<div class="bg-gray-800/60 border border-gray-700 rounded-lg px-4 py-3.5">
				<div class="text-sm font-semibold text-gray-100 mb-1">{challenge.name}</div>
				<div class="text-xs text-amber-400 italic mb-2">&ldquo;{challenge.title}&rdquo;</div>
				<div class="text-xs text-gray-400">{challenge.description}</div>
			</div>
		{/each}
	</div>

	<!-- Divider -->
	<div class="border-t border-gray-700/60 mb-8"></div>

	<!-- Characters on a challenge -->
	<div class="flex items-center gap-3 mb-6">
		<h2 class="medievalsharp-regular text-2xl text-amber-500 dark:text-amber-400">On a Challenge</h2>
	</div>

	{#if data.characters.length === 0}
		<div class="flex flex-col items-center justify-center py-16 text-gray-500">
			<span class="text-3xl mb-3 opacity-40">🎯</span>
			<p class="text-base italic">No one's taken up a challenge yet.</p>
		</div>
	{:else}
		<div class="bg-gray-800/60 border border-gray-700 rounded-lg overflow-hidden">
			<table class="w-full text-sm">
				<thead>
					<tr class="bg-gray-900/50 border-b border-gray-700 text-xs text-gray-500 uppercase tracking-wider">
						<th class="px-4 py-3 text-left">Character</th>
						<th class="px-4 py-3 text-left">Challenges</th>
					</tr>
				</thead>
				<tbody class="divide-y divide-gray-700/40">
					{#each data.characters as char}
						<tr class="hover:bg-gray-700/20 transition-colors duration-100">
							<td class="px-4 py-3">
								<div class="flex items-center gap-3">
									<div class="relative shrink-0 w-8 h-8">
										<img
											src={racePortraitUrl(char.race, char.gender)}
											alt={char.race}
											class="w-8 h-8 rounded-full object-cover object-top border border-gray-600"
											onerror={onImgError}
										/>
										<div
											style="display:none; background-color:{classColor(char.class)}22; color:{classColor(char.class)}"
											class="w-8 h-8 rounded-full border border-gray-600 flex items-center justify-center text-xs font-bold"
										>
											{char.name[0]}
										</div>
									</div>
									<div>
										<div class="text-gray-200 font-medium leading-tight flex items-center gap-1.5">
											{char.name}
											{#if char.online}
												<span class="relative flex h-1.5 w-1.5">
													<span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
													<span class="relative inline-flex h-1.5 w-1.5 rounded-full bg-green-500"></span>
												</span>
											{/if}
										</div>
										<div class="text-xs mt-0.5">
											<span style="color:{classColor(char.class)}">{char.class}</span>
											<span class="text-gray-600"> · </span>
											<span class="text-gray-500">{char.race} · Lv {char.level}</span>
										</div>
									</div>
								</div>
							</td>
							<td class="px-4 py-3">
								<div class="flex flex-wrap gap-1.5">
									{#each char.challenges as c}
										<span class="px-2 py-0.5 rounded-full text-xs bg-amber-900/30 text-amber-400 border border-amber-800/40">
											{c}
										</span>
									{/each}
								</div>
							</td>
						</tr>
					{/each}
				</tbody>
			</table>
		</div>
	{/if}
</section>
