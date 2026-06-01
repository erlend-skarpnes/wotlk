import type { PageServerLoad } from './$types';
import { getAchievementHighscores } from '$lib/server/db';

export const load: PageServerLoad = async () => {
	return { highscores: await getAchievementHighscores() };
};
