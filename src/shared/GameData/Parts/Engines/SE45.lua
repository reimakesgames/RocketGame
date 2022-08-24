return {
	name = 'SE-45 "Pivot" Liquid Fuel Engine';
	flavor = nil;

	cost = 1200;

	mass = 1500; -- Kilograms
	drag = 0.2; -- I don't know what this value is for
	maxTemperature = 2000; -- kelvin?? what the ####
	volume = nil;
	impactTolerance = 7; -- m/s

	engine = {
		fuelConsumption = 13.70; -- Units?
		thrustVectoring = 3; -- degrees

		alternator = 6; -- Units

		thrust = {
			atmosphere = 167.97; -- kN
			vaccum = 215.00; -- kN
		};
		isp = {
			atmosphere = 250; -- s
			vaccum = 320; -- s
		}
	}
}