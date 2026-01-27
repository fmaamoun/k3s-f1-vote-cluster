import type { PageServerLoad } from './$types'
import { getRedisClient, RedisKeys, RATE_LIMIT_MAX, type RaceStatus } from '$lib/server/redis'
import { drivers } from '$lib/drivers'

export const load: PageServerLoad = async ({ cookies, getClientAddress }) => {
	const redis = getRedisClient()
	const ip = getClientAddress()

	// Step 1: Check race status
	const status = ((await redis.get(RedisKeys.raceStatus())) as RaceStatus) || 'WAITING'

	// If PUBLISHED, return results
	if (status === 'PUBLISHED') {
		const scores = await Promise.all(
			drivers.map(async (driver) => ({
				id: driver.id,
				name: driver.name,
				team: driver.team,
				number: driver.number,
				color: driver.color,
				votes: parseInt((await redis.get(RedisKeys.score(driver.id))) || '0')
			}))
		)

		scores.sort((a, b) => b.votes - a.votes)

		return {
			status,
			view: 'published',
			scores
		}
	}

	// If not OPEN, return early with status
	if (status !== 'OPEN') {
		return {
			status,
			view: status === 'WAITING' ? 'waiting' : 'ended',
			scores: []
		}
	}

	// Step 2: Check cookie
	const currentSessionId = (await redis.get(RedisKeys.sessionId())) || 'default'
	const cookieValue = cookies.get('has_voted')
	if (cookieValue === currentSessionId) {
		return {
			status,
			view: 'already_voted',
			scores: []
		}
	}

	// Step 3: Check IP rate limit
	const rateLimitCount = await redis.get(RedisKeys.rateLimit(ip))
	if (rateLimitCount && parseInt(rateLimitCount) > RATE_LIMIT_MAX) {
		return {
			status,
			view: 'ip_blocked',
			scores: []
		}
	}

	// Step 4: All checks passed - show loading view
	// The client will verify fingerprint
	return {
		status,
		view: 'loading',
		scores: []
	}
}
