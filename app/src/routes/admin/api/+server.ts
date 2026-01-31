import { json } from '@sveltejs/kit'
import { randomUUID } from 'crypto'
import type { RequestHandler } from './$types'
import { getRedisClient, RedisKeys, type RaceStatus } from '$lib/server/redis'

export const POST: RequestHandler = async ({ request }) => {
	const redis = getRedisClient()

	try {
		const { action } = await request.json()

		switch (action) {
			case 'RESET':
				// Flush all data and set to WAITING
				await redis.flushdb()
				await redis.set(RedisKeys.raceStatus(), 'WAITING')
				const newSessionId = randomUUID()
				await redis.set(RedisKeys.sessionId(), newSessionId)
				return json({ success: true, status: 'WAITING' })

			case 'OPEN':
				await redis.set(RedisKeys.raceStatus(), 'OPEN')
				return json({ success: true, status: 'OPEN' })

			case 'CLOSE':
				await redis.set(RedisKeys.raceStatus(), 'CLOSED')
				return json({ success: true, status: 'CLOSED' })

			case 'PUBLISH':
				await redis.set(RedisKeys.raceStatus(), 'PUBLISHED')
				return json({ success: true, status: 'PUBLISHED' })

			default:
				return json({ error: 'Invalid action' }, { status: 400 })
		}
	} catch (error) {
		console.error('Admin action error:', error)
		return json({ error: 'Internal server error' }, { status: 500 })
	}
}

export const GET: RequestHandler = async () => {
	const redis = getRedisClient()
	const status = ((await redis.get(RedisKeys.raceStatus())) as RaceStatus) || 'WAITING'

	// Ensure session ID exists
	let sessionId = await redis.get(RedisKeys.sessionId())
	if (!sessionId) {
		sessionId = randomUUID()
		await redis.set(RedisKeys.sessionId(), sessionId)
	}

	return json({ status })
}
