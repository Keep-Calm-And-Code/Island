package;

import TextScreen;
import Grid;
import Resource;
import hl.UI.Window;

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
	
	public var resources:Pile;
	
	public var buildings:Map<Building, UInt>;
	
	
	public function new(size, ?name:String) {
		
		this.mainWindow = new TextScreen(24);
		
		this.name = name;
		this.size = size;
		
		turn = 1;
		
		population = 3;
		
		resources = new Pile();
		resources.add(Food, 5);
		resources.add(Wood, 5);
		
		this.grid = generate();
		countBuildings();
		
		mainWindow.addChild(grid.window, 5);
		
		infoWindow = new TextWindow(2, "info");
		mainWindow.addChild(infoWindow, 19);
		
		commandWindow = new TextWindow(20, "command");
		mainWindow.addChild(commandWindow, 5, 40);
	}
	
	public function generate() {
		return generateBasic();
	}
	
	public function generateBasic() {
		//placeholder island
		
		var grid = new HexGrid(size, size, cellRows, cellCols, name);
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
				var cell = new IslandCell(cellRows, cellCols, terrain, Point2D.coordsToString(c, r));
				cell.render();
				grid.addCell(cell, c, r);
			}
		}
	
		grid.removeCell(2, 3);
		grid.removeCell(3, 4);
		
		cast(grid.cells["1, 2"], Island.IslandCell).building = Building.House;
		cast(grid.cells["1, 2"], Island.IslandCell).buildingLevel = 2;
		cast(grid.cells["2, 2"], Island.IslandCell).building = Building.Sawmill;
		cast(grid.cells["2, 2"], Island.IslandCell).buildingLevel = 1;
		cast(grid.cells["2, 1"], Island.IslandCell).building = Building.Farm;
		cast(grid.cells["2, 1"], Island.IslandCell).buildingLevel = 1;	
		
		return grid;
		
	}
	
	public function generateRandom() {
		var semiperimeter = Math.ceil(2 * Math.sqrt(2 * size));  //estimates a comfortably large grid in which to generate the island
		var gridRows = Math.floor(semiperimeter / 2);
		var gridCols = semiperimeter - gridRows;
	
		var grid = new HexGrid(gridRows, gridCols, cellRows, cellCols, name);
		
		for (i in (2...size)) {

			
		}
		
		return grid;
	}	
	
	private inline function write(s:String, ?r:Int = 0, ?c:Int = 0) {
		mainWindow.write(s, r, c);
	}
	
	private inline function getActiveCell() {
		return cast(grid.cells[grid.activeCellKey], IslandCell);
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
		
		income.add(Resource.Food, buildings[Building.Farm]);
		income.add(Resource.Wood, buildings[Building.Sawmill]);
		
		return income;
	}
	
	inline public function costToUpgrade() {
		return Building.CostToBuild(getActiveCell().building, getActiveCell().buildingLevel);
	}
	
	inline public function costToBuild(b:Building) {
		return Building.CostToBuild(b, 0);		
	}
	
	public function display() {
		write('Year $turn', 0, 20);
		
		write('Islanders: $population', 2);
		write('$resources', 2, 18);
		var income = countIncome().toResourceAlignedString("+", false);
		write('$income', 3, 17);
		
		menuState = MenuState.Empty;
		
		var active = grid.activeCellKey;
		infoWindow.clear();
		if (active != null) {
			var cell = cast(grid.cells[active], IslandCell);
			infoWindow.write(terrainNames[cell.terrain]);
			
			if (cell.building == null) {
				menuState = MenuState.Build;
			}
			if (cell.building != null) {
				menuState = MenuState.Upgrade;
				infoWindow.write('Level ' + cell.buildingLevel + " " + Building.names[cell.building], 0, 12);
			}
		}
		
		commandWindow.clear();
		switch(menuState) {
			case Empty:
				
			case Build:
				commandWindow.write("Build:");
				
				var row = 2;
				for (b in Type.allEnums(Building)) {
					commandWindow.write(Building.names[b], row, 2);
					commandWindow.write(Building.names[b].charAt(0) + ")", row, 1);
					
					var cost = Building.CostToBuild(b, buildings[b]);
					
					if (resources.hasPile(cost)) commandWindow.write("*", row, 0);
					
					commandWindow.write('$cost', row, 12);
					
					row++;
				}
				
			case Upgrade:
				commandWindow.write("U)pgrade");
		}
		
		commandWindow.write("N)ext year", 14);
		
		mainWindow.display();
	}
	
	public function inputLoop() {
		var input:TextScreen.ASCIIChar = "";
		
		while (input == "") {
			input = Sys.getChar(false);
			trace(input);
		
			switch(input) {
				case '4':	//left
					commandMoveLeft();
				case '6':	//right
					commandMoveRight();
				case '8':	//up
					commandMoveUp();
				case '2':	//down
					commandMoveDown();
				case 'h' | 'H':	
					commandBuild(Building.House);
				case 'f' | 'F':
					commandBuild(Building.Farm);
				case 's' | 'S':
					commandBuild(Building.Sawmill);
				case 'n' | 'N':	//next turn
					commandNextYear();
				case 'u' | 'U':	//upgrade
					commandUpgrade();
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
	
	public function commandMoveUp() {
		grid.activeCellKey = grid.closestCellInDirection(grid.activeCellKey, Direction.Up);
	}
	
	public function commandMoveDown() {
		grid.activeCellKey = grid.closestCellInDirection(grid.activeCellKey, Direction.Down);
	}
	
	public function commandMoveLeft() {
		grid.activeCellKey = grid.closestCellInDirection(grid.activeCellKey, Direction.Left);
	}
	
	public function commandMoveRight() {
		grid.activeCellKey = grid.closestCellInDirection(grid.activeCellKey, Direction.Right);
	}
	
	public function commandBuild(b:Building) {
		if (menuState == MenuState.Build &&
			resources.hasPile(costToBuild(b))) {
				
			resources.subtractPile(costToBuild(b));
			getActiveCell().building = b;
			getActiveCell().buildingLevel = 1;
			buildings[b]++;
	
			commandNextYear();
		}
	}
		
	public function commandNextYear() {
		resources.addPile(countIncome());
		turn++;
	}
	
	public function commandUpgrade() {
		if (menuState == MenuState.Upgrade &&
			resources.hasPile(costToUpgrade())) {
				
			resources.subtractPile(costToUpgrade());
			getActiveCell().buildingLevel++;
			buildings[getActiveCell().building]++;
	
			commandNextYear();
		}
	}
 
 }
	
enum MenuState {
	Empty;
	Build;
	Upgrade;
}

enum Commands {
	MoveLeft;
	MoveRight;
	MoveUp;
	MoveDown;
	BuildHouse;
	BuildFarm;
	BuildSawmill;
	Upgrade;
	NextTurn;
}



class IslandCell extends Grid.Cell {
	
	public var terrain:Terrain;
	
	public var building:Building;
	public var buildingLevel:UInt;
	
	public function new(rows:UInt, columns:UInt, ?terrain = Terrain.Forest, ?name:String) {
		
		super(rows, columns, name);
		
		this.terrain = terrain;
		
		defaultChar = terrainChars[terrain];
	}

	
	override public function render() {
		
		clear();
		
		if (building != null) {
			write(Building.names[building].charAt(0));
			writeLeft("" + buildingLevel, 0, columns - 1);
		}
		
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



