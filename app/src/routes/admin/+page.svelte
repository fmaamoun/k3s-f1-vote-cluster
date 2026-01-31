<script lang="ts">
	import { onMount } from 'svelte'
	import { Button } from '$lib/components/ui/button'
	import * as Card from '$lib/components/ui/card'
	import { ScrollArea } from '$lib/components/ui/scroll-area'
	import {
		AlertDialog,
		AlertDialogAction,
		AlertDialogCancel,
		AlertDialogContent,
		AlertDialogDescription,
		AlertDialogFooter,
		AlertDialogHeader,
		AlertDialogTitle,
		AlertDialogTrigger
	} from '$lib/components/ui/alert-dialog'
	import { Spinner } from '$lib/components/ui/spinner'
	import f1Logo from '$lib/assets/f1-logo.svg'
	import { LockKeyholeOpen, Pause, Send, Plus, Check, Circle, Square } from 'lucide-svelte'
	import type { RaceStatus } from '$lib/server/redis'

	let currentStatus = $state<RaceStatus>('WAITING')
	let isLoading = $state(false)

	const steps = [
		{ status: 'WAITING', label: 'Ready to Start', description: 'Waiting to begin voting' },
		{ status: 'OPEN', label: 'Voting Open', description: 'Fans can vote now' },
		{ status: 'CLOSED', label: 'Voting Ended', description: 'Voting has ended' },
		{ status: 'PUBLISHED', label: 'Results Published', description: 'Final results are live' }
	]

	function getCurrentStepIndex() {
		return steps.findIndex((step) => step.status === currentStatus)
	}

	onMount(async () => {
		await fetchStatus()
	})

	async function fetchStatus() {
		try {
			const response = await fetch('/admin/api')
			const data = await response.json()
			currentStatus = data.status
		} catch (error) {
			console.error('Failed to fetch status:', error)
		}
	}

	async function performAction(action: string) {
		isLoading = true
		try {
			const response = await fetch('/admin/api', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ action })
			})

			const result = await response.json()
			if (result.success) {
				currentStatus = result.status
			}
		} catch (error) {
			console.error('Action failed:', error)
		} finally {
			isLoading = false
		}
	}
</script>

<div class="min-h-screen bg-background">
	<ScrollArea class="h-screen">
		<div class="container mx-auto max-w-4xl px-4 py-16">
			<div class="mb-12 text-center">
				<img src={f1Logo} alt="F1 Logo" class="mx-auto mb-4 h-auto w-32" />
				<h1 class="text-4xl font-bold tracking-tight">Admin Panel</h1>
				<p class="text-muted-foreground">Manage race voting workflow</p>
			</div>

			<div class="space-y-8">
				<!-- Workflow Steps -->
				<Card.Root>
					<Card.Header>
						<Card.Title>Workflow</Card.Title>
					</Card.Header>
					<Card.Content>
						<div class="relative">
							<!-- Progress line -->
							<div class="absolute top-6 right-0 left-0 h-0.5 bg-border"></div>
							<div
								class="absolute top-6 left-0 h-0.5 bg-green-700 transition-all duration-500"
								style="width: {((getCurrentStepIndex() + 1) / steps.length) * 100}%"
							></div>

							<div class="relative flex items-start justify-between">
								{#each steps as step, index}
									{@const isActive =
										step.status === currentStatus &&
										currentStatus !== steps[steps.length - 1].status}
									{@const isCompleted = getCurrentStepIndex() >= index}
									<div class="flex max-w-32 flex-1 flex-col items-center">
										<!-- Step circle -->
										<div
											class="relative z-10 flex h-12 w-12 items-center justify-center rounded-full border-2 transition-all duration-300 {isCompleted
												? 'border-green-700 bg-background shadow-lg'
												: isActive
													? 'border-blue-500 bg-blue-50 shadow-md'
													: 'border-muted bg-background'}"
										>
											{#if isCompleted}
												<Check class="h-5 w-5 text-green-700" />
											{:else if isActive}
												<Circle class="h-6 w-6 fill-blue-600 text-blue-600" />
											{:else}
												<Circle class="h-6 w-6 text-muted-foreground" />
											{/if}
										</div>

										<!-- Step content -->
										<div class="mt-4 text-center">
											<p
												class="text-sm font-semibold {isCompleted
													? 'text-green-700'
													: isActive
														? 'text-blue-700'
														: 'text-muted-foreground'}"
											>
												{step.label}
											</p>
											<p class="mt-1 text-xs leading-tight text-muted-foreground">
												{step.description}
											</p>
										</div>
									</div>
								{/each}
							</div>
						</div>
					</Card.Content>
				</Card.Root>

				<!-- Actions -->
				<Card.Root>
					<Card.Header>
						<Card.Title>Actions</Card.Title>
					</Card.Header>
					<Card.Content>
						{#if currentStatus === 'WAITING'}
							<AlertDialog>
								<AlertDialogTrigger>
									<Button variant="outline" disabled={isLoading}>
										{#if isLoading}
											<Spinner />
										{:else}
											<LockKeyholeOpen class="h-4 w-4 " />
											Open Voting
										{/if}
									</Button>
								</AlertDialogTrigger>
								<AlertDialogContent>
									<AlertDialogHeader>
										<AlertDialogTitle>Confirm Action</AlertDialogTitle>
										<AlertDialogDescription
											>Are you sure you want to open voting?</AlertDialogDescription
										>
									</AlertDialogHeader>
									<AlertDialogFooter>
										<AlertDialogCancel>Cancel</AlertDialogCancel>
										<AlertDialogAction onclick={() => performAction('OPEN')}
											>Confirm</AlertDialogAction
										>
									</AlertDialogFooter>
								</AlertDialogContent>
							</AlertDialog>
						{:else if currentStatus === 'OPEN'}
							<AlertDialog>
								<AlertDialogTrigger>
									<Button disabled={isLoading} class="w-full" variant="outline">
										{#if isLoading}
											<Spinner />
										{:else}
											<Square class="h-4 w-4 " />
											End Voting
										{/if}
									</Button>
								</AlertDialogTrigger>
								<AlertDialogContent>
									<AlertDialogHeader>
										<AlertDialogTitle>Confirm Action</AlertDialogTitle>
										<AlertDialogDescription
											>Are you sure you want to end voting?</AlertDialogDescription
										>
									</AlertDialogHeader>
									<AlertDialogFooter>
										<AlertDialogCancel>Cancel</AlertDialogCancel>
										<AlertDialogAction onclick={() => performAction('CLOSE')}
											>Confirm</AlertDialogAction
										>
									</AlertDialogFooter>
								</AlertDialogContent>
							</AlertDialog>
						{:else if currentStatus === 'CLOSED'}
							<AlertDialog>
								<AlertDialogTrigger>
									<Button disabled={isLoading} class="w-full" variant="outline">
										{#if isLoading}
											<Spinner />
										{:else}
											<Send class="h-4 w-4 " />
											Publish Results
										{/if}
									</Button>
								</AlertDialogTrigger>
								<AlertDialogContent>
									<AlertDialogHeader>
										<AlertDialogTitle>Confirm Action</AlertDialogTitle>
										<AlertDialogDescription
											>Are you sure you want to publish the results?</AlertDialogDescription
										>
									</AlertDialogHeader>
									<AlertDialogFooter>
										<AlertDialogCancel>Cancel</AlertDialogCancel>
										<AlertDialogAction onclick={() => performAction('PUBLISH')}
											>Confirm</AlertDialogAction
										>
									</AlertDialogFooter>
								</AlertDialogContent>
							</AlertDialog>
						{:else if currentStatus === 'PUBLISHED'}
							<AlertDialog>
								<AlertDialogTrigger>
									<Button disabled={isLoading} class="w-full" variant="outline">
										{#if isLoading}
											<Spinner />
										{:else}
											<Plus class="h-4 w-4 " />
											New Voting Session
										{/if}
									</Button>
								</AlertDialogTrigger>
								<AlertDialogContent>
									<AlertDialogHeader>
										<AlertDialogTitle>Confirm Action</AlertDialogTitle>
										<AlertDialogDescription
											>Are you sure you want to start a new voting session? This will delete all
											previous data.</AlertDialogDescription
										>
									</AlertDialogHeader>
									<AlertDialogFooter>
										<AlertDialogCancel>Cancel</AlertDialogCancel>
										<AlertDialogAction onclick={() => performAction('RESET')}
											>Confirm</AlertDialogAction
										>
									</AlertDialogFooter>
								</AlertDialogContent>
							</AlertDialog>
						{/if}
					</Card.Content>
				</Card.Root>
			</div>
		</div>
	</ScrollArea>
</div>
