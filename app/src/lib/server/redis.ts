import Redis from 'ioredis'
import { env } from '$env/dynamic/private'

// Singleton Redis client
let redisClient: Redis | null = null

export function getRedisClient(): Redis {
	if (!redisClient) {
		redisClient = new Redis(env.REDIS_URL)
	}
	return redisClient
}

// Race status enum
export type RaceStatus = 'WAITING' | 'OPEN' | 'CLOSED' | 'PUBLISHED'

// Redis key helpers
export const RedisKeys = {
	raceStatus: () => 'race:status',
	score: (driver: string) => `score:${driver}`,
	voteFingerprint: (hash: string) => `vote_fp:${hash}`,
	rateLimit: (ip: string) => `ratelimit:${ip}`,
	sessionId: () => 'race:session_id'
}

// Constants
export const RATE_LIMIT_MAX = 20
export const RATE_LIMIT_TTL = 60 // seconds
export const COOKIE_MAX_AGE = 24 * 60 * 60 // 24 hours in seconds
