package;

/**
 * ...
 * @author 
 */

enum Building {
	House;
	Farm;	
	Sawmill;
	Mine;
	Blacksmith;
	Port;
	Temple;
}
 

var names = [
	Building.House 		=> "House",
	Building.Farm 		=> "Farm",
	Building.Sawmill 	=> "Sawmill",
	Building.Mine 		=> "Mine",
	Building.Blacksmith => "Blacksmith",
	Building.Port		=> "Port",
	Building.Temple 	=> "Temple"
];



 
//cost of the next building
function CostToBuild(b:Building, n:Int) {  //n: current number of buildings)
	
	var cost = new Resource.Pile();
	
	switch(b) {
		
		case Building.House:
			cost.add(Resource.Grain, 12 + 3 * n * n);
			cost.add(Resource.Wood, 30 + 5 * n * (n + 1));
			if (n >= 4) cost.add(Resource.Tools, 4 * (n - 3) * (n - 2));
			return cost;
			
		case Building.Farm:
			cost.add(Resource.Wood, 10 + 5 * n * (n + 1));
			if (n >= 3) cost.add(Resource.Tools, 3 * (n - 2) * (n - 1));
			return cost;
			
		case Building.Sawmill:
			cost.add(Resource.Grain, 6 + 3 * n * (n + 1));
			cost.add(Resource.Metal, 6 + 3 * n * (n + 1));
			if (n >= 5) cost.add(Resource.Tools, 5 * (n - 3) * (n - 3));
			return cost;
			
		case Building.Mine:
			cost.add(Resource.Wood, 8 + 4 * n * (n + 1));
			cost.add(Resource.Grain, 6 + 3 * n * (n + 1));
			return cost;
			
		case Building.Blacksmith:
			cost.add(Resource.Wood, 6 + 3 * n * (n + 1));
			cost.add(Resource.Metal, 8 + 4 * n * (n + 1));
			return cost;		
			
		case Building.Port:
			cost.add(Resource.Wood, 6 + 6 * n * (n + 1));
			cost.add(Resource.Metal, 5 + 3 * n * (n + 1));
			if (n >= 3) cost.add(Resource.Tools, 4 * n * n);
			return cost;
			
		case Building.Temple:
			cost.add(Resource.Grain, 5 + 5 * n * (n + 2));
			cost.add(Resource.Wood, 10 + 3 * n * (n + 1));			
			if (n >= 3) cost.add(Resource.Metal, 10 + 6 * n * (n - 1));			
			return cost;
			
	}
	
}

