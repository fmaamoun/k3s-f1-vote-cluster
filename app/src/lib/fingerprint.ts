import FingerprintJS from '@fingerprintjs/fingerprintjs'

let fpPromise: Promise<string> | null = null

/**
 * Get the device fingerprint hash
 * This is cached for the session
 */
export async function getFingerprint(): Promise<string> {
	if (!fpPromise) {
		fpPromise = (async () => {
			const fp = await FingerprintJS.load()
			const result = await fp.get()
			return result.visitorId
		})()
	}
	return fpPromise
}
