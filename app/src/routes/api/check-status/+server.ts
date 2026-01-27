import { json } from '@sveltejs/kit'
import type { RequestHandler } from './$types'
import { getRedisClient, RedisKeys, COOKIE_MAX_AGE } from '$lib/server/redis'

export const GET: RequestHandler = async ({ url, cookies }) => {
	const fingerprint = url.searchParams.get('fp')

	if (!fingerprint) {
		return json({ error: 'Missing fingerprint' }, { status: 400 })
	}

	const redis = getRedisClient()
	const currentSessionId = (await redis.get(RedisKeys.sessionId())) || 'default'
	const cookieValue = cookies.get('has_voted')

	// Check if voted in current session
	// The client might not have the cookie (e.g. incognito or cleared), 
	// but we must respect the server-side fingerprint record.
	const hasVoted = (await redis.exists(RedisKeys.voteFingerprint(fingerprint))) === 1

	if (hasVoted) {
		// If cookie is missing but user has voted (fingerprint found), restore the cookie
		if (cookieValue !== currentSessionId) {
			cookies.set('has_voted', currentSessionId, {
				path: '/',
				maxAge: COOKIE_MAX_AGE,
				httpOnly: true,
				sameSite: 'strict'
			})
		}
		return json({ hasVoted })
	}

	return json({ hasVoted })
}
