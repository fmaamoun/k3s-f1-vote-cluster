<script lang="ts">
	import './layout.css'
	import favicon from '$lib/assets/f1-logo.svg'

	let { children } = $props()
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<title>F1 Driver of the Day - Vote Now</title>
	<meta name="description" content="Vote for your favorite Formula 1 driver of the day" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
</svelte:head>

{@render children()}
