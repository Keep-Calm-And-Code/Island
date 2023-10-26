package;

import TextScreen;
import Grid;
import Resource;

/**
 * ...
 * @author 
 */

 class Island {
	
	public var name:String;
	
	public var mainWindow:TextScreen;
	
	public var grid:HexGrid;

	public var infoWindow:TextWindow;
	public var commandWindow:TextWindow;
	public var restartGameWindow:TextWindow;
	
	public var menuState:MenuState;
	
	@IMPROVE	//this is to handle a small, singular secondary menu. So maybe a kludge like this is justified
	public var restartGameMenuIsActive:Bool;	
	
	public static var cellRows = 2;
	public static var cellCols = 3;
	
	public var size:UInt;
	
	
	var turn:Int;
	
	var population:Int;
	
	public static var baseHappiness = 50;
	public static var maxHappinessFromFood = 20;
	
	public var resources:Pile;
	
	public var buildings:Map<Building, UInt>;
	
	
	public function new(size, ?type:GenerationType, ?name:String) {
		
		this.mainWindow = new TextScreen(24);
		
		this.name = name;
		this.size = size;
		
		infoWindow = new TextWindow(2, "info");
		mainWindow.addChild(infoWindow, 5, 35);
		
		commandWindow = new TextWindow(20, "command");
		mainWindow.addChild(commandWindow, 8, 35);
		
		restartGameWindow = new TextWindow(1, 40);
		mainWindow.addChild(restartGameWindow, 17);
		
		newIsland(type);
	}
	
	public function newIsland(?type = GenerationType.Random) {
		
		menuState = MenuState.Upgrade;
		restartGameMenuIsActive = false;
		
		turn = 1;
				
		resources = new Pile();
		resources.add(Grain, 50).add(Wood, 50).add(Metal, 50);

		mainWindow.removeChild(name);
		
		switch (type) {
			case Empty:
				generateEmpty();
			case OneCell:
				generateOneCell();
			case Filled:
				generateFilled();
			case Random:
				generateRandom();
		}

		mainWindow.addChild(grid.window, 5);		
		
		countBuildings();

		population = 3;	
	}
	
	public function randomTerrain() {
		var roll = Math.random();
		
		if (roll < 0.4) {
			return Terrain.Grass;
		}
		else if (roll < 0.7) {
			return Terrain.Forest;
		}
		else {
			return Terrain.Hills;
		}
	}
	
	
	public function makeCell(x:Int, y:Int, ?terrain) {
		if (terrain == null) terrain = randomTerrain();
		
		var cell = new IslandCell(terrain, grid.toCellKey(x, y));
		cell.render();
		grid.addCell(cell, x, y);
	}
	
	public function generateEmpty() {
		grid = new HexGrid(size, size, cellRows, cellCols, name);
	}
	
	public function generateOneCell() {
		grid = new HexGrid(size, size, cellRows, cellCols, name);
		makeCell(Math.floor(size / 2), Math.floor(size / 2));
	}
	
	public function generateFilled() {
		
		//placeholder island		
		grid = new HexGrid(size, size, cellRows, cellCols, name);
		
		for (r in 0...size) {
			for (c in 0...size) {
				var terrain = Terrain.Grass;
				switch ((r + c) % 3) {
					case 0:
						terrain = Terrain.Grass;
					case 1:
						terrain = Terrain.Forest;
					case 2:
						terrain = Terrain.Hills;		
				}
				
				var cell = new IslandCell(terrain, grid.toCellKey(c, r));
				grid.addCell(cell, c, r);
			}
		}
	
		//assumes size >= 3. This function should be used only for testing anyways
		cast(grid.cells["1, 2"], Island.IslandCell).building = Building.House;
		cast(grid.cells["1, 2"], Island.IslandCell).buildingLevel = 2;
		cast(grid.cells["2, 2"], Island.IslandCell).building = Building.Sawmill;
		cast(grid.cells["2, 2"], Island.IslandCell).buildingLevel = 1;
		cast(grid.cells["2, 1"], Island.IslandCell).building = Building.Farm;
		cast(grid.cells["2, 1"], Island.IslandCell).buildingLevel = 2;	
		
	}
	
	
	//makes a new Cell adjacent to the coast
	public function growIsland() {
		
	}
	
	public function generateRandom() {
		var semiperimeter = Math.ceil(2 * Math.sqrt(2 * size));  //estimates a comfortably large grid in which to generate the island
		var gridRows = Math.floor(semiperimeter / 2);
		var gridCols = semiperimeter - gridRows;
	
		grid = new HexGrid(gridRows, gridCols, cellRows, cellCols, name);

		var x = Math.floor(gridCols / 2);	var y = Math.floor(gridRows / 2);
		makeCell(x, y);
		grid.activeCellKey = grid.toCellKey(x, y);
		getActiveCell().building = Building.House;
		getActiveCell().buildingLevel = 1;
		
		for (i in (1...size)) {
			
			//coast is recalculated each time, instead of gradually being updated. 
			//just not worthwhile to do something smarter now, island generator is currently a naive placeholder anyways			
			@IMPROVE
			var borderKey = Utils.randomElement(grid.cellKeysWithPotentialNeighbors());
			var key = Utils.randomElement(grid.potentialNeighbors(borderKey));
			
			@IMPROVE
			if (i == 1) {
				makeCell(grid.toCellX(key), grid.toCellY(key), Terrain.Grass);
				cast(grid.cells[key], IslandCell).building = Building.Farm;
				cast(grid.cells[key], IslandCell).buildingLevel = 2;
			}
			else if (i == 2) {
				makeCell(grid.toCellX(key), grid.toCellY(key), Terrain.Forest);
				cast(grid.cells[key], IslandCell).building = Building.Sawmill;
				cast(grid.cells[key], IslandCell).buildingLevel = 1;	
			}
			//crude way to make sure there's enough of each terrain type at the end of island generation
			else if (i > 0.75 * size) {
				if (countTerrain(Terrain.Grass) < 0.25 * size) {
					makeCell(grid.toCellX(key), grid.toCellY(key), Terrain.Grass);					
				}
				else if (countTerrain(Terrain.Forest) < 0.25 * size) {
					makeCell(grid.toCellX(key), grid.toCellY(key), Terrain.Forest);					
				}
				else if (countTerrain(Terrain.Hills) < 0.2 * size) {
					makeCell(grid.toCellX(key), grid.toCellY(key), Terrain.Hills);					
				}
				else makeCell(grid.toCellX(key), grid.toCellY(key));
			}
			else makeCell(grid.toCellX(key), grid.toCellY(key));
		}
		
	}	
	
	private inline function write(s:String, ?r:Int = 0, ?c:Int = 0) {
		mainWindow.write(s, r, c);
	}
	
	private inline function getCell(key:String) {
		if (grid.cells.exists(key)) return cast(grid.cells[key], IslandCell);
		else return null;
	}
	
	private inline function getActiveCell() {
		if (grid.activeCellKey == null) return null;
		return getCell(grid.activeCellKey);
	}
	
	private inline function getActiveCellKey() {
		return grid.activeCellKey;
	}
	
	
	//buildings is actually updated every time a building is built or upgraded
	//I'm still keeping this function here.
	public function countBuildings() {
		var count:Map<Building, UInt> = [for (b in Type.allEnums(Building)) b => 0];
		
		for (cell in grid.cells) {
			var b = cast(cell, IslandCell).building;
			if (b != null) {
				count[b] += cast(cell, IslandCell).buildingLevel;
			}
		}
		
		return buildings = count;
	}
	
	public function countTerrain(terrain:Terrain) {
		var count = 0;
		
		for (cell in grid.cells) {
			if (cast(cell, IslandCell).terrain == terrain) count++;
		}
		
		return count;
	}
	
	//This value is recalculated every time it's used.
	//This constantly bothers me: whether something should be recalculated from scratch,
	//or whether a variable representing it should be updated whenever it changes.
	//The best decision depends on the code complexity and computational cost of both approaches
	//Trouble is, as the design evolves, both may change in unexpected ways.
	//
	//Maybe the bigger consideration is that something may matter so little that one should treat
	//it as insignificant, just to reduce one thing from mental consideration.
	//In this case, computational cost is probably insignificant.
	//If the value is to be constantly updated, code is needed in other places too.
	//Means it's harder to make changes.
	
	public function countJobs() {
		var count = -buildings[Building.House];
		for (b in buildings) count += b;	//counts all building levels except Houses
		return count;
	}
	
	
	inline public function costToUpgrade() {
		return Building.CostToBuild(getActiveCell().building, getActiveCell().buildingLevel);
	}
	
	inline public function costToBuild(b:Building) {
		return Building.CostToBuild(b, 0);		
	}
	
	public function isValidLocation(b:Building, ?key:String) {
		if (key == null) key = grid.activeCellKey;
		
		if (b == Building.Farm && getCell(key).terrain != Terrain.Grass) return false;
		if (b == Building.Sawmill && getCell(key).terrain != Terrain.Forest) return false;
		if (b == Building.Mine && getCell(key).terrain != Terrain.Hills) return false;
		
		if (b == Building.Port && 
			(getCell(key).terrain != Terrain.Grass || !isCoastCellKey(key))) return false; 
		
		return true;
	}
	
	public function isCoastCellKey(key:String) {
		
		if (grid.toCellX(key) == 0 || grid.toCellX(key) == grid.gridCols - 1 ||
			grid.toCellY(key) == 0 || grid.toCellY(key) == grid.gridRows - 1 ||
			grid.cellKeysWithPotentialNeighbors().contains(key)) {
				return true;
		}
		else return false;
	}
	
	public function display() {
		
		write('Week $turn',  0, 4);
		
		write('Islanders: $population / ' + countJobs() + ' jobs', 0, 20);
		write('Happiness: ' + calculateHappiness() + '   ', 0, 50);
		
		if (calculateHappiness() >= 100) write ('You win!', 0, 70);
		
		write('$resources', 2, 8);
		var income = calculateIncome().toResourceAlignedString("+", false);
		write('$income', 3, 7);

		
		var active = grid.activeCellKey;
		infoWindow.clear();
		if (active != null) {
			var cell = cast(grid.cells[active], IslandCell);
			
			infoWindow.write(terrainNames[cell.terrain], 1);
			
			if (cell.building != null) {
				infoWindow.write('Level ' + cell.buildingLevel + " " + Building.names[cell.building]);
				
				if (calculateCellProduction(cell) != null) {
					infoWindow.write('Produces ' + calculateCellProduction(cell).toLeftAlignedString(), 0, 19);
					
					var adjacentBuildings = countNeighborsWithBuilding(cell);
					if (adjacentBuildings > 0) {
						infoWindow.write('bonus ' + 20 * adjacentBuildings + '% from adjacency', 1, 16);
					}
				}
			}
		}
		
		commandWindow.clear();
		
		switch(menuState) {
			case Build:
				commandWindow.write("Build:");
				
				var row = 2;
				for (b in Type.allEnums(Building)) {
					if (isValidLocation(b)) {
						commandWindow.write(Building.names[b], row, 2);
						commandWindow.write(Building.names[b].charAt(0) + ")", row, 1);
						
						var cost = costToBuild(b);
						
						if (resources.hasPile(cost)) commandWindow.write("*", row, 0);
						
						commandWindow.write(cost.toLeftAlignedString(), row, 13);
					}	
						
					row++;
				}

				commandWindow.write("V)iew population", 11);
				
			case Upgrade:
				commandWindow.write(" U)pgrade");
				
				var cost = costToUpgrade();
				
				if (resources.hasPile(costToUpgrade())) commandWindow.write("*");
				
				commandWindow.write(cost.toLeftAlignedString(), 0, 12);
				
				commandWindow.write("V)iew population", 11);
				
			case ViewPopulation:
				commandWindow.write('$population islanders consuming ' + population * 4 + ' food');
				var grainEaten = calculateConsumption().resources[Resource.Grain];
				var fishEaten = calculateConsumption().resources[Resource.Fish];
				if (fishEaten == null) fishEaten = 0;
				
				commandWindow.write('$grainEaten Grain + $fishEaten Fish', 1, 22);
				
				commandWindow.write('Happiness from', 3);
				
				commandWindow.write('Employment :  ' + calculateHappinessFromEmployment(), 5);
				commandWindow.write('(max $baseHappiness at 50% employment)', 5, 19);
				commandWindow.write('Food       :  ' + calculateHappinessFromFood(), 6);
				commandWindow.write('(max $maxHappinessFromFood at 50% fish eaten)', 6, 19);
				commandWindow.write('Goods      :  ' + calculateHappinessFromGoods(), 7);
				commandWindow.write('Temples    :  ' + calculateHappinessFromTemples(), 8);
				commandWindow.write('              ' + calculateHappiness(), 9);
				
				commandWindow.write("V)iew island", 11);
		}
		
		restartGameWindow.clear();
		if (restartGameMenuIsActive) restartGameWindow.write("R)estart game?  Y)es / N)o", 0, 6);
		else restartGameWindow.write("R)estart game", 0, 6);
		
		mainWindow.write("Next W)eek", 19, 6);
		
		mainWindow.display();
	}
	
	public function inputLoop() {
		var input:TextScreen.ASCIIChar = "";
		
		while (input == "") {
			input = Sys.getChar(false);
			//trace(input);
		
			switch(input) {
				case '4':
					commandMove(Direction.Left);
				case '6':
					commandMove(Direction.Right);
				case '8':
					commandMove(Direction.Up);
				case '2':
					commandMove(Direction.Down);
				case 'h' | 'H':	
					commandBuild(Building.House);
				case 'f' | 'F':
					commandBuild(Building.Farm);
				case 's' | 'S':
					commandBuild(Building.Sawmill);
				case 'm' | 'M':
					commandBuild(Building.Mine);
				case 'b' | 'B':
					commandBuild(Building.Blacksmith);
				case 'p' | 'P':
					commandBuild(Building.Port);
				case 't' | 'T':
					commandBuild(Building.Temple);
				case 'u' | 'U':	
					commandUpgrade();
				case 'w' | 'W' | ' ':
					commandNextTurn();
				case 'r' | 'R':
					if (!restartGameMenuIsActive) restartGameMenuIsActive = true;
				case 'y' | 'Y':
					if (restartGameMenuIsActive) newIsland();
				case 'n' | 'N':
					if (restartGameMenuIsActive) restartGameMenuIsActive = false;
				case 'v' | 'V':
					switch(menuState) {
						case Build | Upgrade:
							menuState = ViewPopulation;
						case ViewPopulation:
							if (getActiveCell().building == null) menuState = Build;
							else menuState = Upgrade;
					}
				default:
			}
			
			//I don't like that I need this line here. Easy to forget/overlook what it does in the whole scheme of things
			//The problem is that grid has a window, but is not a window itself and so can't be added as a child window
			//the TextWindow display() updates all child windows properly, but the grid needs
			//to do additional things which isn't invoked in the usual display() heirarchy
			@IMPROVE
			grid.window.clear();  
			
			display();
			input = "";
		}
	}
	
	public function commandMove(dir:Direction) {
		grid.activeCellKey = grid.closestCellInDirection(grid.activeCellKey, dir);
		
		if (getActiveCell().building == null) menuState = MenuState.Build;
		else menuState = MenuState.Upgrade;
		
		
	}

	
	public function commandBuild(b:Building) {
		if (menuState == MenuState.Build &&
			isValidLocation(b) &&
			resources.hasPile(costToBuild(b))) {
			
			commandNextTurn();	
				
			resources.subtractPile(costToBuild(b));
			getActiveCell().building = b;
			getActiveCell().buildingLevel = 1;
			buildings[b]++;
	
			menuState = MenuState.Upgrade;			
		}
	}
	
	public function commandUpgrade() {
		if (menuState == MenuState.Upgrade &&
			resources.hasPile(costToUpgrade())) {
				
			commandNextTurn();

			resources.subtractPile(costToUpgrade());
			getActiveCell().buildingLevel++;
			buildings[getActiveCell().building]++;
	
		}
	}
	
	public function commandNextTurn() {
		var income = calculateIncome();
		
		var foodDeficit = -income.resources[Resource.Grain] - resources.resources[Resource.Grain];
		if (foodDeficit > 0) {
			shrinkPopulation(foodDeficit);
		}
		
		//something wrong with grain arithmetic in some cases when total Grain hovers around 0
		@FIX
		resources.cutoffAddPile(income);
		if (resources.resources[Resource.Grain] > 0) growPopulation();
		turn++;
	}
	
	
	//these functions are simple placeholders, meant to map out the code structure first
	//they'll become much more sophisticated later
	@IMPROVE
	public function growPopulation() {
		if (population < buildings[Building.House] * 3) population++;
	}
	
	@IMPROVE
	public function shrinkPopulation(deficit:Int) {
		if (population > 0) population--;
	}
	
	
	public function calculateIncome() {
		
		return calculatePrimaryProduction().addPile(calculateSecondaryProduction()).subtractPile(calculateConsumption());
	}
	
	public function countNeighborsWithBuilding(?cell:IslandCell, ?building:Building) {
		if (cell == null) cell = getActiveCell();
		
		//building may still end up null. Should I allow this?
		if (building == null) building = cell.building;
		
		var count = 0;
		
		for (key in cell.neighbors) {
			if (getCell(key).building == building) count++;
		}
		
		return count;
	}
	
	public function calculateCellProduction(?cell:IslandCell):Pile {
		
		if (cell == null) cell = getActiveCell();
		
		var income = new Pile();
		
		if (cell.building == null) return null;
		
		switch(cell.building) {
			
			case Building.Farm:

				return income.add(Resource.Grain, (10 + 2 * countNeighborsWithBuilding(cell)) * cell.buildingLevel);
				
			case Building.Sawmill:
				
				return income.add(Resource.Wood, (10 + 2 * countNeighborsWithBuilding(cell)) * cell.buildingLevel);
			
			case Building.Mine:

				return income.add(Resource.Metal, (10 + 2 * countNeighborsWithBuilding(cell)) * cell.buildingLevel);
			
			case Building.Blacksmith:
				
				return income.add(Resource.Tools, 5 * cell.buildingLevel);
				
			case Building.Port:
				
				income.add(Resource.Fish, 8 * cell.buildingLevel);
				return income.add(Resource.Goods, 4 * cell.buildingLevel);
				
			default:
				
				return null;
				
		}
		
	}
	
	
	//instead of primaryProd, secondaryProd, tertiaryProd, etc
	//I should just do this for each individual resource
	//but calculated in a sequence so that lower, material resource production is calculated before
	//higher resources that require lower resources
	
	//grain, wood, metal
	public function calculatePrimaryProduction() {
		var prod = new Pile();
		
		for (cell in grid.cells) {
			var iCell = cast(cell, IslandCell);
			if (iCell.building == Building.Farm ||
				iCell.building == Building.Sawmill ||
				iCell.building == Building.Mine ||
				iCell.building == Building.Port) {
				
				prod.addPile(calculateCellProduction(iCell));
			}
		}
		
		if (countJobs() > population) {
			return prod.multiplyAndRound(population / countJobs());
		}
		else return prod;
	}
	
	public function calculateSecondaryProduction() {
		var prod = new Pile();
		
		if (buildings[Building.Blacksmith] > 0) {
			var primaryProd = calculatePrimaryProduction();
			var woodMade = primaryProd.resources[Resource.Wood];
			var metalMade = 0;
			if (primaryProd.resources.exists(Resource.Metal)) {
				metalMade = primaryProd.resources[Resource.Metal];
			}
			
			var toolsMade = Utils.minInt(resources.resources[Resource.Wood] + woodMade, 
										 resources.resources[Resource.Metal] + metalMade,
										 5 * buildings[Building.Blacksmith]);
										 
			prod.add(Resource.Tools, toolsMade);
		}
		
		if (countJobs() > population) {
			return prod.multiplyAndRound(population / countJobs());
		}
		else return prod;
	}
	
	public function calculateConsumption() {
		var consumption = new Pile();
		
		var totalGrain = resources.resources[Resource.Grain] + calculatePrimaryProduction().resources[Resource.Grain];
		var totalFish = resources.resources[Resource.Fish] + calculatePrimaryProduction().resources[Resource.Fish];

		var toEat = 4 * population;
		
		if (toEat > totalGrain + totalFish) {
			consumption.add(Resource.Grain, toEat - totalFish);
			if (totalFish > 0) consumption.add(Resource.Fish, totalFish);
		}
		else {
			var grainEaten = Math.ceil(toEat * totalGrain / (totalGrain + totalFish));
			consumption.add(Resource.Grain, grainEaten);
			if (toEat - grainEaten > 0) consumption.add(Resource.Fish, toEat - grainEaten);
		}
		
		if (resources.resources[Resource.Goods] > 0) {
			var goodsUsed = Utils.minInt(population, Math.ceil(resources.resources[Resource.Goods] / 2));
			consumption.add(Resource.Goods, goodsUsed);
		}
		
		//tools may be made
		if (buildings[Building.Blacksmith] > 0) {
			var toolsMade = calculateSecondaryProduction().resources[Resource.Tools];
		
			consumption.add(Resource.Wood, toolsMade);
			consumption.add(Resource.Metal, toolsMade);
		}
		
		return consumption;
	}
	
	//simple placeholder functions
	public function calculateHappinessFromEmployment() {
		return Utils.round(baseHappiness * Math.min(1, population / (2 * countJobs())), 1);
	}
	
	public function calculateHappinessFromFood() {
		var fishEaten = calculateConsumption().resources[Resource.Fish];
		var grainEaten = calculateConsumption().resources[Resource.Grain];
		
		return Utils.round(maxHappinessFromFood * Math.min(fishEaten / grainEaten, 1), 1);
	}
	
	public function calculateHappinessFromGoods() {
		return calculateConsumption().resources[Resource.Goods] * 0.3;
	}
	
	public function calculateHappinessFromTemples() {
		return 3 * buildings[Building.Temple];
	}
	
	public function calculateHappiness() {
		return calculateHappinessFromEmployment()
			 + calculateHappinessFromFood()
			 + calculateHappinessFromGoods()
		     + calculateHappinessFromTemples();
	}
 
}
 
enum GenerationType {
	Empty;
	OneCell;
	Filled;
	Random;
}
	
enum MenuState {
	Build;
	Upgrade;
	ViewPopulation;
}


class IslandCell extends Grid.Cell {
	
	public var terrain:Terrain;
	
	public var building:Building;
	public var buildingLevel:UInt;
	
	public function new(?terrain = Terrain.Forest, ?name:String) {
		
		super(Island.cellRows, Island.cellCols, name);
		
		this.terrain = terrain;
		
		defaultChar = terrainChars[terrain];
		
		render();
	}

	
	override public function render() {
		
		clear();
		
		if (building != null) {
			write(Building.names[building].charAt(0), 0, 1);
			writeLeft("" + buildingLevel, 1, columns - 2);
		}
		
		//this call should not be needed. Why does super.render() not work?
		//There's something I'm missing here
		@FIX
		copyDataBuffer();
		
	}
}


enum Terrain {
	Grass;
	Forest;
	Hills;
}

var terrainNames = [ Terrain.Grass => "Grass",
					 Terrain.Forest => "Forest",
					 Terrain.Hills => "Hills" ];
					 
var terrainChars = [ Terrain.Grass => ".",
					 Terrain.Forest => "&",
					 Terrain.Hills => "^" ];



