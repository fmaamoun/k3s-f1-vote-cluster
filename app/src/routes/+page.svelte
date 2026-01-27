<script lang="ts">
	import type { PageData } from './$types';
	import { Button } from '$lib/components/ui/button';

	let { data }: { data: PageData } = $props();

	// Create a map of votes for quick access
	let votesMap = $derived(new Map(data.votes.map(v => [v.driverId, v.score])));
	
	// Create a list of all drivers with their scores (0 if no vote)
	let allDriversWithScores = $derived(data.allDrivers.map(driver => {
		const score = votesMap.get(driver.id) || 0;
		return { ...driver, score };
	}).sort((a, b) => b.score - a.score)); // Sort by descending score

	let title = $derived(data.hasVoted ? 'Results' : 'Vote');
</script>

<svelte:head>
	<title>F1 Driver of the Day - {title}</title>
</svelte:head>

<div class="min-h-screen bg-background">
	<div class="container mx-auto px-4 py-12 max-w-7xl">
		<!-- Header -->
		<div class="text-center mb-12">
			<h1 class="text-2xl md:text-3xl lg:text-4xl font-black tracking-tight mb-4">
				<span class="bg-linear-to-r from-red-600 via-red-500 to-red-600 bg-clip-text text-transparent">
					{#if data.hasVoted}
						RESULTS
					{:else}
						DRIVER OF THE DAY
					{/if}
				</span>
			</h1>
			{#if data.hasVoted}
				<p class="text-muted-foreground text-sm md:text-base max-w-2xl mx-auto mb-4">
					Total votes: {data.totalVotes}
				</p>
				
				<!-- Thank You Message -->
				<div class="inline-flex items-center gap-2 bg-green-500/10 border-2 border-green-500/30 rounded-lg px-4 py-2">
					<svg class="w-5 h-5 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
					</svg>
					<p class="text-green-500 font-bold text-xs">Thank you for your vote!</p>
				</div>
			{:else}
				<p class="text-muted-foreground text-sm md:text-base max-w-2xl mx-auto">
					Cast your vote for today's best driver
				</p>
			{/if}
		</div>

		{#if data.hasVoted}
			<!-- Results List -->
			<div class="max-w-4xl mx-auto space-y-4">
				{#each allDriversWithScores as driver, index}
					{@const percentage = data.totalVotes > 0 ? (driver.score / data.totalVotes) * 100 : 0}
					<Button
						variant="outline"
						class="w-full h-auto group relative overflow-hidden rounded-xl border-2 transition-all duration-300 hover:scale-[1.02] hover:shadow-xl active:scale-[0.98] p-0 bg-card/50 backdrop-blur-sm"
						style="border-color: {driver.color}"
					>
						<!-- Team color bar on the left -->
						<div 
							class="absolute left-0 top-0 bottom-0 w-2 transition-all duration-300 group-hover:w-3 rounded-l-xl"
							style="background-color: {driver.color}"
						></div>

						<!-- Driver content -->
						<div class="flex items-center gap-4 p-5 pl-7 w-full">
							<!-- Position Badge -->
							<div class="shrink-0 w-10 md:w-12 text-center">
								{#if index === 0 && driver.score > 0}
									<div class="text-2xl md:text-3xl">🥇</div>
								{:else if index === 1 && driver.score > 0}
									<div class="text-2xl md:text-3xl">🥈</div>
								{:else if index === 2 && driver.score > 0}
									<div class="text-2xl md:text-3xl">🥉</div>
								{:else}
									<div class="text-lg md:text-xl font-black text-muted-foreground">#{index + 1}</div>
								{/if}
							</div>

							<!-- Driver number -->
							<div 
								class="shrink-0 text-2xl md:text-3xl font-black opacity-30 group-hover:opacity-60 transition-opacity"
								style="color: {driver.color}"
							>
								{driver.number}
							</div>

							<!-- Driver info -->
							<div class="flex-1 text-left min-w-0">
								<h3 class="text-sm md:text-base font-bold tracking-tight mb-1 truncate">
									{driver.name}
								</h3>
								<p class="text-xs text-muted-foreground font-medium truncate">
									{driver.team}
								</p>
							</div>

							<!-- Stats - Votes and percentage -->
							<div class="shrink-0 text-right min-w-16 md:min-w-20">
								<div 
									class="text-xl md:text-2xl font-black mb-1"
									style="color: {driver.color}"
								>
									{driver.score}
								</div>
								<div class="text-xs text-muted-foreground font-bold">
									{percentage.toFixed(1)}%
								</div>
							</div>

							<!-- Vertical progress bar -->
							<div class="shrink-0 w-2 h-12 bg-accent/30 rounded-full overflow-hidden">
								<div 
									class="w-full transition-all duration-700 ease-out rounded-full"
									style="height: {percentage}%; background-color: {driver.color}"
								></div>
							</div>
						</div>

						<!-- Hover effect -->
						<div 
							class="absolute inset-0 opacity-0 group-hover:opacity-10 transition-opacity pointer-events-none rounded-xl"
							style="background-color: {driver.color}"
						></div>
					</Button>
				{/each}
			</div>
		{:else}
			<!-- Drivers Grid -->
			<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
				{#each data.drivers as driver}
					<form method="POST" class="w-full">
						<input type="hidden" name="driverId" value={driver.id} />
						
						<Button
							type="submit"
							variant="outline"
							class="w-full h-auto group relative overflow-hidden rounded-xl border-2 transition-all duration-300 hover:scale-[1.02] hover:shadow-xl active:scale-[0.98] p-0 bg-card/50 backdrop-blur-sm"
							style="border-color: {driver.color}"
						>
							<!-- Team color bar on the left -->
							<div 
								class="absolute left-0 top-0 bottom-0 w-2 transition-all duration-300 group-hover:w-3 rounded-l-xl"
								style="background-color: {driver.color}"
							></div>

							<!-- Driver content -->
							<div class="flex items-center gap-4 p-5 pl-7 w-full">
								<!-- Driver number -->
								<div 
									class="shrink-0 text-2xl md:text-3xl font-black opacity-30 group-hover:opacity-60 transition-opacity"
									style="color: {driver.color}"
								>
									{driver.number}
								</div>

								<!-- Driver info -->
								<div class="flex-1 text-left min-w-0">
									<h3 class="text-sm md:text-base font-bold tracking-tight mb-1 truncate">
										{driver.name}
									</h3>
									<p class="text-xs text-muted-foreground font-medium truncate">
										{driver.team}
									</p>
								</div>

								<!-- Arrow icon -->
								<div class="shrink-0 opacity-0 group-hover:opacity-100 transition-all duration-300 transform group-hover:translate-x-1">
									<svg class="w-5 h-5 md:w-6 md:h-6" style="color: {driver.color}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M13 7l5 5m0 0l-5 5m5-5H6"/>
									</svg>
								</div>
							</div>

							<!-- Hover effect -->
							<div 
								class="absolute inset-0 opacity-0 group-hover:opacity-10 transition-opacity pointer-events-none rounded-xl"
								style="background-color: {driver.color}"
							></div>
						</Button>
					</form>
				{/each}
			</div>
		{/if}
	</div>
</div>
