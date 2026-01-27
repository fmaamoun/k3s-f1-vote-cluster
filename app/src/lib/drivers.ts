export interface Driver {
	id: string;
	name: string;
	number: number;
	team: string;
	color: string;
	textColor?: string;
}

export const drivers: Driver[] = [
	{
		id: 'verstappen',
		name: 'Max Verstappen',
		number: 1,
		team: 'Red Bull Racing',
		color: '#3671C6',
		textColor: '#FFFFFF'
	},
	{
		id: 'perez',
		name: 'Sergio Pérez',
		number: 11,
		team: 'Red Bull Racing',
		color: '#3671C6',
		textColor: '#FFFFFF'
	},
	{
		id: 'hamilton',
		name: 'Lewis Hamilton',
		number: 44,
		team: 'Ferrari',
		color: '#E8002D',
		textColor: '#FFFFFF'
	},
	{
		id: 'leclerc',
		name: 'Charles Leclerc',
		number: 16,
		team: 'Ferrari',
		color: '#E8002D',
		textColor: '#FFFFFF'
	},
	{
		id: 'norris',
		name: 'Lando Norris',
		number: 4,
		team: 'McLaren',
		color: '#FF8000',
		textColor: '#000000'
	},
	{
		id: 'piastri',
		name: 'Oscar Piastri',
		number: 81,
		team: 'McLaren',
		color: '#FF8000',
		textColor: '#000000'
	},
	{
		id: 'russell',
		name: 'George Russell',
		number: 63,
		team: 'Mercedes',
		color: '#27F4D2',
		textColor: '#000000'
	},
	{
		id: 'antonelli',
		name: 'Andrea Kimi Antonelli',
		number: 12,
		team: 'Mercedes',
		color: '#27F4D2',
		textColor: '#000000'
	},
	{
		id: 'alonso',
		name: 'Fernando Alonso',
		number: 14,
		team: 'Aston Martin',
		color: '#229971',
		textColor: '#FFFFFF'
	},
	{
		id: 'stroll',
		name: 'Lance Stroll',
		number: 18,
		team: 'Aston Martin',
		color: '#229971',
		textColor: '#FFFFFF'
	},
	{
		id: 'gasly',
		name: 'Pierre Gasly',
		number: 10,
		team: 'Alpine',
		color: '#FF87BC',
		textColor: '#000000'
	},
	{
		id: 'doohan',
		name: 'Jack Doohan',
		number: 7,
		team: 'Alpine',
		color: '#FF87BC',
		textColor: '#000000'
	},
	{
		id: 'hulkenberg',
		name: 'Nico Hülkenberg',
		number: 27,
		team: 'Sauber',
		color: '#52E252',
		textColor: '#000000'
	},
	{
		id: 'bortoleto',
		name: 'Gabriel Bortoleto',
		number: 5,
		team: 'Sauber',
		color: '#52E252',
		textColor: '#000000'
	},
	{
		id: 'tsunoda',
		name: 'Yuki Tsunoda',
		number: 22,
		team: 'RB',
		color: '#6692FF',
		textColor: '#FFFFFF'
	},
	{
		id: 'lawson',
		name: 'Liam Lawson',
		number: 30,
		team: 'RB',
		color: '#6692FF',
		textColor: '#FFFFFF'
	},
	{
		id: 'albon',
		name: 'Alex Albon',
		number: 23,
		team: 'Williams',
		color: '#64C4FF',
		textColor: '#000000'
	},
	{
		id: 'sainz',
		name: 'Carlos Sainz',
		number: 55,
		team: 'Williams',
		color: '#64C4FF',
		textColor: '#000000'
	},
	{
		id: 'ocon',
		name: 'Esteban Ocon',
		number: 31,
		team: 'Haas',
		color: '#B6BABD',
		textColor: '#000000'
	},
	{
		id: 'bearman',
		name: 'Oliver Bearman',
		number: 87,
		team: 'Haas',
		color: '#B6BABD',
		textColor: '#000000'
	}
];
