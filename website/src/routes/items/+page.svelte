<script lang="ts">
	interface ItemSearchResult {
		id: number;
		name: string;
		quality: number;
	}

	interface DropSource {
		sourceType: 'creature' | 'gameobject';
		sourceId: number;
		sourceName: string;
		chance: number;
		minCount: number;
		maxCount: number;
	}

	let { data }: { data: { query: string; items: ItemSearchResult[]; selectedItem: ItemSearchResult | null; dropSources: DropSource[] } } = $props();

	const QUALITY_COLORS: Record<number, string> = {
		0: '#9d9d9d',
		1: '#ffffff',
		2: '#1eff00',
		3: '#0070dd',
		4: '#a335ee',
		5: '#ff8000',
		6: '#e6cc80'
	};

	const QUALITY_NAMES: Record<number, string> = {
		0: 'Poor', 1: 'Common', 2: 'Uncommon', 3: 'Rare', 4: 'Epic', 5: 'Legendary', 6: 'Artifact'
	};

	function qualityColor(q: number): string {
		return QUALITY_COLORS[q] ?? '#ffffff';
	}

	function formatChance(chance: number): string {
		if (chance >= 100) return '100%';
		if (chance < 0.01) return '<0.01%';
		return chance.toFixed(2) + '%';
	}

	function formatCount(min: number, max: number): string {
		return min === max ? String(min) : `${min}–${max}`;
	}
</script>

<svelte:head>
	<title>Item Search · Azeroth</title>
</svelte:head>

<div class="max-w-4xl mx-auto px-4 py-8">
	<h1 class="medievalsharp-regular text-3xl text-amber-700 dark:text-amber-500 mb-6">Item Search</h1>

	<!-- Search form -->
	<form method="GET" class="flex gap-2 mb-8">
		<input
			type="text"
			name="q"
			value={data.query}
			placeholder="Search items…"
			minlength="2"
			class="flex-1 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-amber-500"
		/>
		<button
			type="submit"
			class="px-5 py-2 rounded-lg bg-amber-600 hover:bg-amber-700 text-white text-sm font-medium transition-colors"
		>
			Search
		</button>
	</form>

	<!-- Results -->
	{#if data.query.length >= 2}
		{#if data.items.length === 0}
			<p class="text-gray-500 dark:text-gray-400 text-sm">No items found for "{data.query}".</p>
		{:else}
			<div class="bg-white dark:bg-gray-800 rounded-xl shadow divide-y divide-gray-100 dark:divide-gray-700">
				{#each data.items as item}
					{@const selected = data.selectedItem?.id === item.id}
					<a
						href={selected ? `/items?q=${encodeURIComponent(data.query)}` : `/items?q=${encodeURIComponent(data.query)}&id=${item.id}`}
						class="flex items-center gap-3 px-4 py-3 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors {selected ? 'bg-gray-50 dark:bg-gray-700' : ''}"
					>
						<span class="text-xs text-gray-400 w-12 shrink-0">#{item.id}</span>
						<span class="text-sm font-medium" style="color: {qualityColor(item.quality)}">{item.name}</span>
						<span class="ml-auto text-xs text-gray-400">{QUALITY_NAMES[item.quality] ?? ''}</span>
						<span class="text-gray-400 text-xs ml-1">{selected ? '▲' : '▼'}</span>
					</a>

					{#if selected}
						<div class="px-4 py-3 bg-gray-50 dark:bg-gray-700/50 border-t border-gray-100 dark:border-gray-600">
							{#if data.dropSources.length === 0}
								<p class="text-gray-500 dark:text-gray-400 text-sm">
									No drop sources found. This item may come from quests, vendors, or crafting.
								</p>
							{:else}
								<table class="w-full text-sm">
									<thead>
										<tr class="text-left text-gray-500 dark:text-gray-400 text-xs uppercase tracking-wide">
											<th class="pb-2 pr-4">Source</th>
											<th class="pb-2 pr-4">Type</th>
											<th class="pb-2 text-right">Drop Chance</th>
											<th class="pb-2 pl-4 text-right">Count</th>
										</tr>
									</thead>
									<tbody class="divide-y divide-gray-100 dark:divide-gray-600">
										{#each data.dropSources as src}
											<tr>
												<td class="py-2 pr-4 text-gray-900 dark:text-white font-medium">{src.sourceName}</td>
												<td class="py-2 pr-4 text-gray-500 dark:text-gray-400 capitalize">{src.sourceType}</td>
												<td class="py-2 text-right font-mono {src.chance < 1 ? 'text-gray-400' : src.chance < 10 ? 'text-amber-500' : 'text-green-500'}">
													{formatChance(src.chance)}
												</td>
												<td class="py-2 pl-4 text-right text-gray-500 dark:text-gray-400">{formatCount(src.minCount, src.maxCount)}</td>
											</tr>
										{/each}
									</tbody>
								</table>
							{/if}
						</div>
					{/if}
				{/each}
			</div>
		{/if}
	{/if}
</div>
