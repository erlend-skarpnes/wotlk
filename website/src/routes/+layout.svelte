<script lang="ts">
	import '../app.css';
	import { DarkMode, Navbar, NavBrand, NavUl, NavLi, ThemeProvider, type ThemeConfig, Heading } from 'flowbite-svelte';

	interface ServerStatus { worldOnline: boolean; authOnline: boolean; uptimeSeconds: number | null; }
	let { children, data }: { children: any; data: { serverStatus: ServerStatus } } = $props();

	const theme: ThemeConfig = {
		heading: "medievalsharp-regular text-amber-700 dark:text-amber-500"
	};

	function formatUptime(s: number): string {
		const d = Math.floor(s / 86400);
		const h = Math.floor((s % 86400) / 3600);
		const m = Math.floor((s % 3600) / 60);
		if (d > 0) return `${d}d ${h}h`;
		if (h > 0) return `${h}h ${m}m`;
		return `${m}m`;
	}

	const { worldOnline, authOnline, uptimeSeconds } = $derived(data.serverStatus);
	const bothUp = $derived(worldOnline && authOnline);
</script>

<svelte:head>
	<title>Azeroth</title>
</svelte:head>

<ThemeProvider {theme}>
	<div class="min-h-screen bg-gray-100 dark:bg-gray-900">
		<header>
			<Navbar>
				<NavBrand href="/">
					<Heading class="text-2xl">Azeroth</Heading>
				</NavBrand>
				<NavUl>
					<NavLi href="/">Home</NavLi>
					<NavLi href="/highscores">Highscores</NavLi>
				</NavUl>

				<!-- Server status badge -->
				<div class="flex items-center gap-2 text-xs mr-1">
					{#if bothUp}
						<span class="relative flex h-2 w-2">
							<span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
							<span class="relative inline-flex h-2 w-2 rounded-full bg-green-500"></span>
						</span>
						<span class="text-gray-400 hidden sm:inline">
							Online
							{#if uptimeSeconds !== null}
								· {formatUptime(uptimeSeconds)}
							{/if}
						</span>
					{:else}
						<span class="h-2 w-2 rounded-full bg-red-500"></span>
						<span class="text-gray-400 hidden sm:inline">
							{#if !worldOnline && !authOnline}
								Offline
							{:else if !worldOnline}
								World offline
							{:else}
								Auth offline
							{/if}
						</span>
					{/if}
				</div>

				<DarkMode />
			</Navbar>
		</header>

		<main>
			{@render children()}
		</main>
	</div>
</ThemeProvider>
