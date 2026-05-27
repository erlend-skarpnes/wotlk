export const formatDuration = (durationInSeconds: number, timeComponents: number = 2) => {
	const units = [
		{ label: 'day', seconds: 86400 },
		{ label: 'hour', seconds: 3600 },
		{ label: 'minute', seconds: 60 },
		{ label: 'second', seconds: 1 }
	];

	const parts = [];

	for (const unit of units) {
		const value = Math.floor(durationInSeconds / unit.seconds);
		if (value > 0) {
			parts.push(`${value} ${unit.label}${value > 1 ? 's' : ''}`);
		}
		durationInSeconds %= unit.seconds;
	}

	return parts.length > 0 ? parts.slice(0, timeComponents).join(', ') : '0 seconds';
};

export const formatMoney = (amount: number) => {
	const gold = Math.floor(amount / 10000);
	const silver = Math.floor((amount % 10000) / 100);
	const copper = amount % 100;

	const parts = [];
	if (gold) parts.push(`${gold}g`);
	if (gold || silver) parts.push(`${silver}s`);
	parts.push(`${copper}c`);

	return parts.join(' ');
};
export const capitalizeFirst = (str: string) =>
	str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();