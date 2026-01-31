export interface Driver {
	id: string
	name: string
	team: string
	number: number
	color: string
}

export const drivers: Driver[] = [
	// McLaren
	{ id: 'norris', name: 'Lando Norris', team: 'McLaren', number: 1, color: '#FF8000' },
	{ id: 'piastri', name: 'Oscar Piastri', team: 'McLaren', number: 81, color: '#FF8000' },

	// Ferrari
	{ id: 'leclerc', name: 'Charles Leclerc', team: 'Ferrari', number: 16, color: '#E8002D' },
	{ id: 'hamilton', name: 'Lewis Hamilton', team: 'Ferrari', number: 44, color: '#E8002D' },

	// Red Bull Racing
	{
		id: 'verstappen',
		name: 'Max Verstappen',
		team: 'Red Bull Racing',
		number: 3,
		color: '#3671C6'
	},
	{ id: 'hadjar', name: 'Isack Hadjar', team: 'Red Bull Racing', number: 6, color: '#3671C6' },

	// Mercedes
	{ id: 'russell', name: 'George Russell', team: 'Mercedes', number: 63, color: '#27F4D2' },
	{ id: 'antonelli', name: 'Kimi Antonelli', team: 'Mercedes', number: 12, color: '#27F4D2' },

	// Williams
	{ id: 'albon', name: 'Alexander Albon', team: 'Williams', number: 23, color: '#64C4FF' },
	{ id: 'sainz', name: 'Carlos Sainz', team: 'Williams', number: 55, color: '#64C4FF' },

	// Racing Bulls
	{ id: 'lawson', name: 'Liam Lawson', team: 'Racing Bulls', number: 30, color: '#5E8FAA' },
	{ id: 'lindblad', name: 'Arvid Lindblad', team: 'Racing Bulls', number: 41, color: '#5E8FAA' },

	// Aston Martin
	{ id: 'alonso', name: 'Fernando Alonso', team: 'Aston Martin', number: 14, color: '#229971' },
	{ id: 'stroll', name: 'Lance Stroll', team: 'Aston Martin', number: 18, color: '#229971' },

	// Haas
	{ id: 'ocon', name: 'Esteban Ocon', team: 'Haas', number: 31, color: '#B6BABD' },
	{ id: 'bearman', name: 'Oliver Bearman', team: 'Haas', number: 87, color: '#B6BABD' },

	// Audi
	{ id: 'hulkenberg', name: 'Nico Hülkenberg', team: 'Audi', number: 27, color: '#C92D4B' },
	{ id: 'bortoleto', name: 'Gabriel Bortoleto', team: 'Audi', number: 5, color: '#C92D4B' },

	// Alpine
	{ id: 'gasly', name: 'Pierre Gasly', team: 'Alpine', number: 10, color: '#FF87BC' },
	{ id: 'colapinto', name: 'Franco Colapinto', team: 'Alpine', number: 43, color: '#FF87BC' },

	// Cadillac
	{ id: 'perez', name: 'Sergio Pérez', team: 'Cadillac', number: 11, color: '#F4C430' },
	{ id: 'bottas', name: 'Valtteri Bottas', team: 'Cadillac', number: 77, color: '#F4C430' }
]
