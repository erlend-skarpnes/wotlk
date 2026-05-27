import type { PageServerLoad } from './$types';
import { getOnlineCharacters, getRoster } from '$lib/server/db';

export const load: PageServerLoad = async () => {
	const [online, roster] = await Promise.all([
		getOnlineCharacters(),
		getRoster()
	]);

	return { online, roster };
};
