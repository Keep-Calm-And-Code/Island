package;

/**
 * ...
 * @author 
 */

enum Building {
	House;
	Farm;	
	Sawmill;
}
 

var names = [
	Building.House 	=> "House",
	Building.Farm 	=> "Farm",
	Building.Sawmill => "Sawmill"
];


 
//cost of the next building
function CostToBuild(b:Building, n:Int) {  //n: current number of buildings)
	
	var cost = new Resource.Pile();
	
	switch(b) {
		
		case Building.House:
			cost.add(Resource.Food, 4 + n ^ 2);
			cost.add(Resource.Wood, 6 + n ^ 2 + n);
			return cost;
			
		case Building.Farm:
			cost.add(Resource.Wood, 2 + Std.int(n * (n + 1) / 2));
			return cost;
			
		case Building.Sawmill:
			cost.add(Resource.Food, 2 + Std.int(n * (n + 1) / 2));
			return cost;
			
	}
	
}