import type { LayoutServerLoad } from './$types';
import os from 'os';

export const load: LayoutServerLoad = async () => {
	return {
		hostname: os.hostname()
	};
};