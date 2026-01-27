import { json } from '@sveltejs/kit'
import type { RequestHandler } from './$types'
import {
	getRedisClient,
	RedisKeys,
	RATE_LIMIT_MAX,
	RATE_LIMIT_TTL,
	COOKIE_MAX_AGE
} from '$lib/server/redis'
import { drivers } from '$lib/drivers'

export const POST: RequestHandler = async ({ request, cookies, getClientAddress }) => {
	const redis = getRedisClient()
	const ip = getClientAddress()

	try {
		const formData = await request.formData()
		const driverId = formData.get('driver') as string
		const fingerprint = formData.get('fingerprint') as string

		// Validate driver exists
		if (!driverId || !drivers.find((d) => d.id === driverId)) {
			return json({ error: 'Invalid driver' }, { status: 400 })
		}

		if (!fingerprint) {
			return json({ error: 'Missing fingerprint' }, { status: 400 })
		}

		// Step 1: Check race status
		const status = await redis.get(RedisKeys.raceStatus())
		if (status !== 'OPEN') {
			return json({ error: 'Voting is not open' }, { status: 403 })
		}

		// Step 2: Check cookie
		const currentSessionId = (await redis.get(RedisKeys.sessionId())) || 'default'
		const cookieValue = cookies.get('has_voted')
		if (cookieValue === currentSessionId) {
			return json({ error: 'Already voted' }, { status: 403 })
		}

		// Step 3: Check IP rate limit
		const rateLimitKey = RedisKeys.rateLimit(ip)
		const currentCount = await redis.get(rateLimitKey)

		if (currentCount && parseInt(currentCount) > RATE_LIMIT_MAX) {
			return json({ error: 'Too many requests' }, { status: 429 })
		}

		// Increment rate limit
		const newCount = await redis.incr(rateLimitKey)
		if (newCount === 1) {
			// First vote from this IP, set TTL
			await redis.expire(rateLimitKey, RATE_LIMIT_TTL)
		}

		// Step 4: Check fingerprint
		const fpKey = RedisKeys.voteFingerprint(fingerprint)
		const fpExists = await redis.exists(fpKey)

		if (fpExists) {
			return json({ error: 'Device already voted' }, { status: 403 })
		}

		// All checks passed - record the vote
		await redis.incr(RedisKeys.score(driverId))
		await redis.set(fpKey, '1')

		// Set cookie
		cookies.set('has_voted', currentSessionId, {
			path: '/',
			maxAge: COOKIE_MAX_AGE,
			httpOnly: true,
			sameSite: 'strict'
		})

		return json({ success: true })
	} catch (error) {
		console.error('Vote error:', error)
		return json({ error: 'Internal server error' }, { status: 500 })
	}
}
