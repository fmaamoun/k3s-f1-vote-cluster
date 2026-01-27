import type { Actions, ServerLoad, RequestEvent } from '@sveltejs/kit';
import { drivers } from '$lib/drivers';
import { getRedis } from '$lib/redis';
import os from 'os';

interface VoteResult {
	driverId: string;
	score: number;
	name: string;
	team: string;
	color: string;
	textColor?: string;
}

export const load: ServerLoad = async ({ cookies, url }) => {
	const hasVoted = cookies.get('voted') === 'true' || url.searchParams.get('hasvoted') === 'true';

	let votes: VoteResult[] = [];
	let totalVotes = 0;
	let hostname = '';

	if (hasVoted) {
		const redis = getRedis();
		hostname = os.hostname();

		// Retrieve all scores from Redis (descending order)
		const results = await redis.zrevrange('f1:votes', 0, -1, 'WITHSCORES');

		// Parse Redis results [driverId, score, driverId, score, ...]
		for (let i = 0; i < results.length; i += 2) {
			const driverId = results[i];
			const score = parseInt(results[i + 1]);
			
			const driver = drivers.find(d => d.id === driverId);
			if (driver) {
				votes.push({
					driverId,
					score,
					name: driver.name,
					team: driver.team,
					color: driver.color,
					textColor: driver.textColor
				});
			}
		}

		// Calculate total for percentages
		totalVotes = votes.reduce((sum, v) => sum + v.score, 0);
	}

	return {
		drivers,
		votes,
		totalVotes,
		hostname,
		allDrivers: drivers,
		hasVoted
	};
};

export const actions: Actions = {
	default: async (event: RequestEvent) => {
		const data = await event.request.formData();
		const driverId = data.get('driverId') as string;

		if (!driverId) {
			return { error: 'Driver ID required' };
		}

		const redis = getRedis();
		await redis.zincrby('f1:votes', 1, driverId);
		
		// Set cookie to indicate voted
		event.cookies.set('voted', 'true', {
			path: '/',
			maxAge: 60 * 60 * 24 * 30 // 30 days
		});

		// Return success, page will reload with hasVoted=true
		return { success: true };
	}
};
