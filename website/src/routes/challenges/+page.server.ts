import type { PageServerLoad } from './$types';
import { CHALLENGES, getCharacterChallenges } from '$lib/server/db';

export const load: PageServerLoad = async () => {
	const characters = await getCharacterChallenges();
	return { challenges: CHALLENGES, characters };
};
