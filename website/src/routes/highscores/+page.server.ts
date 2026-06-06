import type { PageServerLoad } from './$types';
import { getAchievementHighscores, getProfessionHighscores, getPlaytimeHighscores } from '$lib/server/db';

export const load: PageServerLoad = async () => {
	const [highscores, professions, playtime] = await Promise.all([
		getAchievementHighscores(),
		getProfessionHighscores(),
		getPlaytimeHighscores()
	]);
	return { highscores, professions, playtime };
};
