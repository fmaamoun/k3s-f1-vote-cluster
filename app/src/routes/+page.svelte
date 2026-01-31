<script lang="ts">
	import { onMount } from 'svelte'
	import { getFingerprint } from '$lib/fingerprint'
	import { drivers } from '$lib/drivers'
	import { Button } from '$lib/components/ui/button'
	import { Card } from '$lib/components/ui/card'
	import * as Empty from '$lib/components/ui/empty'
	import { ScrollArea } from '$lib/components/ui/scroll-area'
	import { Spinner } from '$lib/components/ui/spinner'
	import f1Logo from '$lib/assets/f1-logo.svg'
	import {
		CheckCircle2,
		Trophy,
		RefreshCcwIcon
	} from 'lucide-svelte'

	let { data } = $props()

	let currentView = $state(data.view)
	let isSubmitting = $state(false)
	let selectedDriver = $state<string | null>(null)
	let fingerprint = $state<string>('')

	const totalVotes = $derived(data.scores.reduce((sum, driver) => sum + driver.votes, 0))

	function getPercentage(votes: number): number {
		return totalVotes === 0 ? 0 : (votes / totalVotes) * 100
	}

	function hexToRgba(hex: string, alpha: number): string {
		const r = parseInt(hex.slice(1, 3), 16)
		const g = parseInt(hex.slice(3, 5), 16)
		const b = parseInt(hex.slice(5, 7), 16)
		return `rgba(${r}, ${g}, ${b}, ${alpha})`
	}

	function getDriverColor(name: string): string {
		const driver = drivers.find((d) => d.name === name)
		return driver?.color || '#000000'
	}

	function getRanksWithTies(scores: any[]): any[] {
		if (scores.length === 0) return []

		const sortedScores = [...scores].sort((a, b) => b.votes - a.votes)
		const rankedScores = []
		let currentRank = 1
		let previousVotes = -1

		for (let i = 0; i < sortedScores.length; i++) {
			const driver = sortedScores[i]
			if (driver.votes !== previousVotes) {
				currentRank = i + 1
			}
			rankedScores.push({
				...driver,
				rank: currentRank
			})
			previousVotes = driver.votes
		}

		return rankedScores
	}

	const rankedScores = $derived(getRanksWithTies(data.scores))
	const winners = $derived(rankedScores.filter((driver) => driver.rank === 1))

	onMount(async () => {
		if (currentView === 'loading') {
			try {
				fingerprint = await getFingerprint()
				const response = await fetch(`/api/check-status?fp=${fingerprint}`)
				const result = await response.json()
				currentView = result.hasVoted ? 'already_voted' : 'vote'
			} catch (error) {
				console.error('Fingerprint check failed:', error)
				currentView = 'error'
			}
		}
	})

	async function handleVote() {
		if (!selectedDriver || !fingerprint) return
		isSubmitting = true

		try {
			const formData = new FormData()
			formData.append('driver', selectedDriver)
			formData.append('fingerprint', fingerprint)

			const response = await fetch('/api/vote', { method: 'POST', body: formData })
			const result = await response.json()
			currentView = result.success ? 'success' : 'error'
		} catch (error) {
			console.error('Vote submission failed:', error)
			currentView = 'error'
		} finally {
			isSubmitting = false
		}
	}
</script>

<div class="min-h-screen bg-background">
	{#if currentView === 'waiting'}
		<div class="flex min-h-screen items-center justify-center">
			<Empty.Root>
				<Empty.Header>
					<Empty.Media>
						<img src={f1Logo} alt="F1 Logo" class="h-auto w-20" />
					</Empty.Media>
					<Empty.Title>Voting Not Open</Empty.Title>
					<Empty.Description>Check back during the final laps to cast your vote.</Empty.Description>
				</Empty.Header>
				<Empty.Content>
					<Button variant="outline" size="sm" onclick={() => window.location.reload()}>
						<RefreshCcwIcon />
						Refresh
					</Button>
				</Empty.Content>
			</Empty.Root>
		</div>
	{:else if currentView === 'loading'}
		<div class="flex min-h-screen items-center justify-center">
			<Empty.Root>
				<Empty.Header>
					<Empty.Media>
						<img src={f1Logo} alt="F1 Logo" class="h-auto w-20" />
					</Empty.Media>
					<Empty.Title>Verifying...</Empty.Title>
					<Empty.Description>Please wait a moment.</Empty.Description>
				</Empty.Header>
			</Empty.Root>
		</div>
	{:else if currentView === 'vote'}
		<ScrollArea class="h-screen">
			<div class="container mx-auto max-w-4xl px-4 py-16 pb-24">
				<!-- Header with F1 Logo -->
				<div class="mb-12 text-center">
					<img src={f1Logo} alt="F1 Logo" class="mx-auto mb-4 h-auto w-32" />
					<h1 class="mb-2 text-4xl font-bold tracking-tight">Driver of the Day</h1>
					<p class="text-muted-foreground">Cast your vote for today's best driver</p>
				</div>

				<div class="space-y-6">
					<div>
						<div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
							{#each drivers as driver}
								<div
									class="cursor-pointer rounded-lg border bg-card p-4 text-card-foreground shadow-sm transition-all hover:shadow-md"
									style="box-shadow: {selectedDriver === driver.id
										? `0 0 0 1px ${driver.color}`
										: ''};"
									onclick={() => (selectedDriver = driver.id)}
									role="button"
									tabindex="0"
									onkeydown={(e) => {
										if (e.key === 'Enter' || e.key === ' ') {
											selectedDriver = driver.id
											e.preventDefault()
										}
									}}
								>
									<div class="mb-2 flex items-center justify-between">
										<span class="text-xs font-medium text-muted-foreground">#{driver.number}</span>
										{#if selectedDriver === driver.id}
											<CheckCircle2 class="h-4 w-4" style="color: {driver.color}" />
										{/if}
									</div>
									<div class="mb-1 text-sm font-medium">{driver.name}</div>
									<div class="text-xs text-muted-foreground">{driver.team}</div>
									<div class="mt-2 h-1 rounded-full" style="background-color: {driver.color}"></div>
								</div>
							{/each}
						</div>
					</div>
				</div>
			</div>
		</ScrollArea>

		{#if currentView === 'vote'}
			<div
				class="fixed right-0 bottom-0 left-0 z-10 border-t bg-background/95 p-4 backdrop-blur-sm"
			>
				<div class="container mx-auto flex max-w-4xl justify-end gap-4">
					<Button onclick={handleVote} disabled={!selectedDriver || isSubmitting}>
						{#if isSubmitting}
							<Spinner class="mr-2 h-4 w-4" />
						{:else}
							Submit
						{/if}
					</Button>
				</div>
			</div>
		{/if}
	{:else if currentView === 'success'}
		<div class="flex min-h-screen items-center justify-center">
			<Empty.Root>
				<Empty.Header>
					<Empty.Media>
						<img src={f1Logo} alt="F1 Logo" class="h-auto w-20" />
					</Empty.Media>
					<Empty.Title>Vote Recorded</Empty.Title>
					<Empty.Description
						>Thank you for participating! The results will be published at the end of the race.</Empty.Description
					>
				</Empty.Header>
			</Empty.Root>
		</div>
	{:else if currentView === 'already_voted'}
		<div class="flex min-h-screen items-center justify-center">
			<Empty.Root>
				<Empty.Header>
					<Empty.Media>
						<img src={f1Logo} alt="F1 Logo" class="h-auto w-20" />
					</Empty.Media>
					<Empty.Title>Already Voted</Empty.Title>
					<Empty.Description
						>You've already cast your vote for this race. The results will be published at the end
						of the race.</Empty.Description
					>
				</Empty.Header>
			</Empty.Root>
		</div>
	{:else if currentView === 'ip_blocked'}
		<div class="flex min-h-screen items-center justify-center">
			<Empty.Root>
				<Empty.Header>
					<Empty.Media>
						<img src={f1Logo} alt="F1 Logo" class="h-auto w-20" />
					</Empty.Media>
					<Empty.Title>Too Many Requests</Empty.Title>
					<Empty.Description
						>Please wait a moment before trying again. The results will be published at the end of
						the race.</Empty.Description
					>
				</Empty.Header>
			</Empty.Root>
		</div>
	{:else if currentView === 'ended'}
		<div class="flex min-h-screen items-center justify-center">
			<Empty.Root>
				<Empty.Header>
					<Empty.Media>
						<img src={f1Logo} alt="F1 Logo" class="h-auto w-20" />
					</Empty.Media>
					<Empty.Title>Voting Ended</Empty.Title>
					<Empty.Description
						>Voting has ended for this race. Results will be published shortly.</Empty.Description
					>
				</Empty.Header>
				<Empty.Content>
					<Button variant="outline" size="sm" onclick={() => window.location.reload()}>
						<RefreshCcwIcon />
						Refresh
					</Button>
				</Empty.Content>
			</Empty.Root>
		</div>
	{:else if currentView === 'published'}
		<ScrollArea class="h-screen">
			<div class="container mx-auto max-w-3xl px-4 py-16">
				<!-- Header with F1 Logo -->
				<div class="mb-12 text-center">
					<img src={f1Logo} alt="F1 Logo" class="mx-auto mb-4 h-auto w-32" />
					<h1 class="mb-2 text-4xl font-bold tracking-tight">Race Results</h1>
					<p class="text-muted-foreground">Driver of the Day Voting</p>
				</div>

				<div class="space-y-6">
					<!-- Winner(s) Highlight -->
					{#if winners.length > 0}
						{#if winners.length === 1}
							<Card
								class="border-2 p-8"
								style="border-color: {getDriverColor(
									winners[0].name
								)}; background: linear-gradient(135deg, {hexToRgba(
									getDriverColor(winners[0].name),
									0.1
								)} 0%, transparent 100%);"
							>
								<div class="mb-4 flex items-center justify-center gap-2">
									<Trophy class="h-6 w-6" style="color: {getDriverColor(winners[0].name)};" />
									<h2 class="text-xl font-semibold">Winner</h2>
								</div>
								<div class="text-center">
									<p class="mb-1 text-3xl font-semibold">{winners[0].name}</p>
									<p class="mb-3 text-muted-foreground">{winners[0].team}</p>
									<div class="flex items-center justify-center gap-3">
										<p
											class="text-2xl font-semibold"
											style="color: {getDriverColor(winners[0].name)};"
										>
											{winners[0].votes.toLocaleString()}
										</p>
										<p class="text-muted-foreground">
											({getPercentage(winners[0].votes).toFixed(1)}%)
										</p>
									</div>
								</div>
							</Card>
						{:else}
							<ScrollArea orientation="horizontal" class="w-full">
								<div class="flex items-stretch gap-4 px-1 py-2">
									{#each winners as winner}
										<Card
											class="min-w-[220px] flex-shrink-0 border-2 p-6"
											style="border-color: {getDriverColor(
												winner.name
											)}; background: linear-gradient(135deg, {hexToRgba(
												getDriverColor(winner.name),
												0.06
											)} 0%, transparent 100%);"
										>
											<div class="flex h-full flex-col justify-between text-center">
												<div>
													<Trophy
														class="mx-auto mb-2 h-5 w-5"
														style="color: {getDriverColor(winner.name)};"
													/>
													<p class="mb-1 text-2xl font-semibold">{winner.name}</p>
													<p class="mb-3 text-muted-foreground">{winner.team}</p>
												</div>
												<div class="mt-2">
													<div class="flex items-center justify-center gap-3">
														<p
															class="text-xl font-semibold"
															style="color: {getDriverColor(winner.name)};"
														>
															{winner.votes.toLocaleString()}
														</p>
														<p class="text-muted-foreground">
															({getPercentage(winner.votes).toFixed(1)}%)
														</p>
													</div>
												</div>
											</div>
										</Card>
									{/each}
								</div>
							</ScrollArea>
						{/if}
					{/if}

					<!-- Full Rankings -->
					<Card class="p-6">
						<div class="mb-4 flex items-center justify-between">
							<h2 class="text-lg font-semibold">All Results</h2>
							<span class="text-muted-foreground">{totalVotes.toLocaleString()} votes</span>
						</div>
						<div class="space-y-3">
							{#each rankedScores as driver}
								<div class="relative overflow-hidden rounded-lg border p-4">
									<div
										class="absolute top-0 bottom-0 left-0 w-1"
										style="background-color: {getDriverColor(driver.name)};"
									></div>
									<div class="mb-2 flex items-center justify-between pl-2">
										<div class="flex items-center gap-3">
											<span class="w-6 text-center text-lg font-bold text-muted-foreground">
												{driver.rank}
											</span>
											<div>
												<div class="font-medium">
													#{drivers.find((d) => d.name === driver.name)?.number || ''}
													{driver.name}
												</div>
												<div class="text-sm text-muted-foreground">{driver.team}</div>
											</div>
										</div>
										<div class="text-right">
											<div class="font-semibold">{driver.votes.toLocaleString()}</div>
											<div class="text-sm text-muted-foreground">
												{getPercentage(driver.votes).toFixed(1)}%
											</div>
										</div>
									</div>
									<!-- Progress Bar -->
									<div class="ml-2 h-2 overflow-hidden rounded-full bg-secondary">
										<div
											class="h-full rounded-full transition-all duration-500"
											style="width: {getPercentage(
												driver.votes
											)}%; background-color: {getDriverColor(driver.name)};"
										></div>
									</div>
								</div>
							{/each}
						</div>
					</Card>
				</div>
			</div>
		</ScrollArea>
	{:else}
		<div class="flex min-h-screen items-center justify-center">
			<Empty.Root>
				<Empty.Header>
					<Empty.Media>
						<img src={f1Logo} alt="F1 Logo" class="h-auto w-20" />
					</Empty.Media>
					<Empty.Title>Error</Empty.Title>
					<Empty.Description>Something went wrong. Please try again.</Empty.Description>
				</Empty.Header>
				<Empty.Content>
					<Button variant="outline" size="sm" onclick={() => window.location.reload()}>
						<RefreshCcwIcon />
						Refresh
					</Button>
				</Empty.Content>
			</Empty.Root>
		</div>
	{/if}
</div>
