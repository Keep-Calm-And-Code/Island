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
	public var menuState:MenuState;
	
	public static var cellRows = 2;
	public static var cellCols = 3;
	
	public var size:UInt;
	
	
	var turn:Int;
	
	var population:Int;
	
	public static var baseHappiness = 50;
	
	public var resources:Pile;
	
	public var buildings:Map<Building, UInt>;
	
	
	public function new(size, type:GenerationType, ?name:String) {
		
		this.mainWindow = new TextScreen(24);
		
		this.name = name;
		this.size = size;
		
		menuState = MenuState.Upgrade;
		
		turn = 1;
				
		resources = new Pile();
		resources.add(Grain, 50);
		resources.add(Wood, 50);
		resources.add(Metal, 50);
		
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
		
		countBuildings();

		population = 3;	
		
		mainWindow.addChild(grid.window, 5);
		
		infoWindow = new TextWindow(2, "info");
		mainWindow.addChild(infoWindow, 5, 40);
		
		commandWindow = new TextWindow(20, "command");
		mainWindow.addChild(commandWindow, 8, 40);
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
		cast(grid.cells["2, 1"], Island.IslandCell).buildingLevel = 1;	
		
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
			var coastKey = Utils.randomElement(coastCellKeys());
			var key = Utils.randomElement(grid.potentialNeighbors(coastKey));
			
			makeCell(grid.toCellX(key), grid.toCellY(key));
			
			switch (i) {
				case 1:
					cast(grid.cells[key], IslandCell).building = Building.Farm;
					cast(grid.cells[key], IslandCell).buildingLevel = 1;
				case 2:
					cast(grid.cells[key], IslandCell).building = Building.Sawmill;
					cast(grid.cells[key], IslandCell).buildingLevel = 1;	
				default:
			}
			
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
	
	public function countIncome() {
		
		var income = new Pile();
		
		income.add(Resource.Grain, 10 * buildings[Building.Farm]);
		income.add(Resource.Wood, 10 * buildings[Building.Sawmill]);
		income.add(Resource.Metal, 10 * buildings[Building.Mine]);
		income.add(Resource.Tools, 5 * buildings[Building.Blacksmith]);

		income.add(Resource.Grain, -4 * population);
		
		return income;
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
		
		return true;
	}
	
	public function coastCellKeys() {
		
		var coast = [];
		
		for (c in grid.cells.keys()) {
			if (grid.potentialNeighbors(c).length > 0) {
				coast.push(c);
			}
		}
		
		return coast;
	}
	
	public function display() {
		write('Week $turn',  0, 4);
		
		write('Islanders: $population', 0, 20);
		write('Happiness: ' + calculateHappiness(), 0, 40);
		
		if (calculateHappiness() >= 90) write ('You win!', 0, 60);
		
		write('$resources', 2, 8);
		var income = countIncome().toResourceAlignedString("+", false);
		write('$income', 3, 7);

		
		var active = grid.activeCellKey;
		infoWindow.clear();
		if (active != null) {
			var cell = cast(grid.cells[active], IslandCell);
			
			infoWindow.write(terrainNames[cell.terrain]);
			
			if (cell.building != null) {
				infoWindow.write('Level ' + cell.buildingLevel + " " + Building.names[cell.building], 1);
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
						
						commandWindow.write('$cost', row, 12);
					}	
						
					row++;
				}

				commandWindow.write("V)iew population", 10);
				
			case Upgrade:
				commandWindow.write(" U)pgrade");
				
				var cost = costToUpgrade();
				
				if (resources.hasPile(costToUpgrade())) commandWindow.write("*");
				
				commandWindow.write(cost.toLeftAlignedString(), 0, 12);
				
				commandWindow.write("V)iew population", 10);
				
			case ViewPopulation:
				commandWindow.write('Base happiness:  $baseHappiness');
				commandWindow.write('From temples  : +' + buildings[Building.Temple] * 2, 1);
				commandWindow.write('                 ' + calculateHappiness(), 2);
		}
		
		commandWindow.write("N)ext week", 12);
		
		mainWindow.display();
	}
	
	public function inputLoop() {
		var input:TextScreen.ASCIIChar = "";
		
		while (input == "") {
			input = Sys.getChar(false);
			trace(input);
		
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
				case 't' | 'T':
					commandBuild(Building.Temple);
				case 'n' | 'N' | ' ':
					commandNextTurn();
				case 'u' | 'U':	
					commandUpgrade();
				case 'v' | 'V':
					menuState = MenuState.ViewPopulation;
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
				
			resources.subtractPile(costToBuild(b));
			getActiveCell().building = b;
			getActiveCell().buildingLevel = 1;
			buildings[b]++;
	
			menuState = MenuState.Upgrade;
			
			commandNextTurn();
		}
	}
	
	//these functions are simple placeholders, meant to map out the code structure first
	//they'll become much more sophisticated later
	public function growPopulation() {
		if (population < buildings[Building.House] * 3) population++;
	}
	
	public function shrinkPopulation(deficit:Int) {
		if (population > 0) population--;
	}
	
	public function calculateHappiness() {
		return baseHappiness + 2 * buildings[Building.Temple];
	}
		
	public function commandNextTurn() {
		var foodDeficit = -countIncome().resources[Resource.Grain] - resources.resources[Resource.Grain];
		if (foodDeficit > 0) {
			shrinkPopulation(foodDeficit);
		}
		
		//something wrong with grain arithmetic
		@FIX
		resources.cutoffAddPile(countIncome());
		if (resources.resources[Resource.Grain] > 0) growPopulation();
		turn++;
	}
	
	public function commandUpgrade() {
		if (menuState == MenuState.Upgrade &&
			resources.hasPile(costToUpgrade())) {
				
			resources.subtractPile(costToUpgrade());
			getActiveCell().buildingLevel++;
			buildings[getActiveCell().building]++;
	
			commandNextTurn();
		}
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



