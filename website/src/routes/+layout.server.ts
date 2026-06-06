import type { LayoutServerLoad } from './$types';
import { getServerStatus } from '$lib/server/db';

export const load: LayoutServerLoad = async () => {
	return { serverStatus: await getServerStatus() };
};
