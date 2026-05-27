<script lang="ts">
	import '../app.css';
	import { DarkMode, Navbar, NavBrand, ThemeProvider, type ThemeConfig, Heading } from 'flowbite-svelte';

	let { children } = $props();

	const theme: ThemeConfig = {
		heading: "medievalsharp-regular text-amber-700 dark:text-amber-500"
	};
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
				<DarkMode />
			</Navbar>
		</header>

		<main>
			{@render children()}
		</main>
	</div>
</ThemeProvider>
