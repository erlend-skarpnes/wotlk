import type { PageServerLoad } from './$types';
import { searchItems, getItemDropSources, type ItemSearchResult, type DropSource } from '$lib/server/db';

export const load: PageServerLoad = async ({ url }) => {
	const query = url.searchParams.get('q') ?? '';
	const idParam = url.searchParams.get('id');
	const selectedId = idParam ? Number(idParam) : null;

	let items: ItemSearchResult[] = [];
	let selectedItem: ItemSearchResult | null = null;
	let dropSources: DropSource[] = [];

	if (query.length >= 2) {
		items = await searchItems(query);
	}

	if (selectedId !== null) {
		selectedItem = items.find((i) => i.id === selectedId) ?? null;
		dropSources = await getItemDropSources(selectedId);
	}

	return { query, items, selectedItem, dropSources };
};
