<script lang="ts">
	import './layout.css';
	import { Select, SelectContent, SelectItem, SelectTrigger } from '$lib/components/ui/select';
	import { onMount } from 'svelte';
	import type { LayoutData } from './$types';

	let { children, data }: { children: any; data: LayoutData } = $props();
	
	let darkMode = $state(true);
	let currentTheme = $state('dark');
	let systemMediaQuery: MediaQueryList | null = null;

	onMount(() => {
		// Retrieve the user's preferred mode
		const savedTheme = localStorage.getItem('theme') || 'dark';
		currentTheme = savedTheme;
		applyTheme(savedTheme);
	});

	function applyTheme(theme: string) {
		if (theme === 'system') {
			systemMediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
			darkMode = systemMediaQuery.matches;
			
			// Listen for system preference changes
			const handleChange = (e: MediaQueryListEvent) => {
				if (currentTheme === 'system') {
					darkMode = e.matches;
				}
			};
			systemMediaQuery.addEventListener('change', handleChange);
		} else {
			// Remove system listener if it exists
			if (systemMediaQuery) {
				systemMediaQuery.removeEventListener('change', () => {});
				systemMediaQuery = null;
			}
			
			darkMode = theme === 'dark';
		}
		
		localStorage.setItem('theme', theme);
	}

	function handleThemeChange(newTheme: string) {
		currentTheme = newTheme;
		applyTheme(newTheme);
	}

	$effect(() => {
		if (darkMode) {
			document.documentElement.classList.add('dark');
		} else {
			document.documentElement.classList.remove('dark');
		}
	});
</script>

<svelte:head><link rel="icon" href="/f1-logo.svg" /></svelte:head>

<div class="min-h-screen bg-background text-foreground transition-colors duration-300 flex flex-col">
	<!-- F1 logo centered at top -->
	<div class="container mx-auto px-4 pt-6 pb-2 text-center">
		<img src="/f1-logo.svg" alt="Formula 1" class="h-10 md:h-12 mx-auto" />
	</div>

	<!-- Main content -->
	<main class="flex-1">
		{@render children()}
	</main>

	<!-- Footer -->
	<footer class="border-t border-border mt-12 bg-card/30">
		<div class="container mx-auto px-4 py-6">
			<div class="flex flex-col sm:flex-row items-center justify-between gap-4">
				<div class="text-sm text-muted-foreground">
					🏎️ Formula 1 Driver of the Day Voting System
				</div>
				<div class="flex items-center gap-4">
					<Select type="single" onValueChange={handleThemeChange}>
						<SelectTrigger class="h-8">
							{#if currentTheme === 'light'}Light{:else if currentTheme === 'dark'}Dark{:else}System{/if}
						</SelectTrigger>
						<SelectContent>
							<SelectItem value="light">Light</SelectItem>
							<SelectItem value="dark">Dark</SelectItem>
							<SelectItem value="system">System</SelectItem>
						</SelectContent>
					</Select>
					<div class="h-8 px-3 py-1 bg-background border border-input rounded-md flex items-center gap-2 text-xs text-muted-foreground">
						<div class="w-2 h-2 rounded-full bg-green-500"></div>
						Pod: <span class="font-mono font-semibold">{data.hostname}</span>
					</div>
				</div>
			</div>
		</div>
	</footer>
</div>
