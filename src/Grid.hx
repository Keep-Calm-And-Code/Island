package;

import TextScreen;

/**
 * ...
 * @author 
 */

 
class Grid {
	
	public var name:String;
	
	public var cells:Map<String, Cell>;
	
	public var size:UInt;
	
	public var activeCellKey(default, set):String;
	
	
	public function new(?name = "") {
		this.name = name;
		
		cells = new Map<String, Cell>();
		
		size = 0;
	}
	
	
	public function addCellWithoutAdjacency(cell:Cell, ?label:String) {

		if (label == null) label = cell.name;
		//removeCell(label);	Cannot force inline-call to removeCell because it is overridden
		if (cells.exists(label)) {		//hence have to make the code explicit
			cells[label].grid = null;
			cells.remove(label);
		}		
		
		cell.grid = this;
		cells.set(label, cell);
		size++;
	}
	
	public overload extern inline function removeCell(label:String) {
		if (cells.exists(label)) {
			for (n in cells[label].neighbors) {
				cells[n].neighbors.remove(label);
			}
			cells[label].grid = null;
			cells.remove(label);
			size--;
		}
	}
	
	public overload extern inline function makeAdjacent(key1:String, key2:String) {
		if (cells.exists(key1) && cells.exists(key2)) {
			if (!cells[key1].neighbors.contains(key2)) cells[key1].neighbors.push(key2);
			if (!cells[key2].neighbors.contains(key1)) cells[key2].neighbors.push(key1);
		}
	}
	
	public overload extern inline function makeAdjacent(key:String, neighborKeys:Array<String>) {
		for (n in neighborKeys) {
			makeAdjacent(key, n);
		}
	}
	
	public overload extern inline function breakAdjacent(key1:String, key2:String) {
		if (cells.exists(key1) && cells.exists(key2)) {
			cells[key1].neighbors.remove(key2);
			cells[key2].neighbors.remove(key1);
		}
	}
	
	public overload extern inline function breakAdjacent(key:String, neighborKeys:Array<String>) {
		for (n in neighborKeys) {
			breakAdjacent(key, n);
		}		
	}
	
	//meant to be overridden in inherited classes
	public function set_activeCellKey(activeCell) {
		if (cells.exists(activeCell)) {
			return this.activeCellKey = activeCell;
		}
		else {
			return this.activeCellKey = null;
		}
	}
	
	
	public function randomCellKey() {
		if (size == 0) return null; 
		
		var count = Utils.randomInt(0, size - 1);
		
		var keys = cells.keys();
		for (i in 0...count) {
			keys.next();
		}
		return keys.next();
	}
}

 
class HexGrid extends Grid
{
	public var window:TextWindow;
	
	public var leftCellBracket:TextWindow;
	public var rightCellBracket:TextWindow;
	
	public var gridRows:UInt;
	public var gridCols:UInt;
	
	public var cellRows:UInt;
	public var cellCols:UInt;

	public function new(gridRows, gridCols, cellRows, cellCols, ?name:String) 
	{		
		this.gridRows = gridRows;	this.gridCols = gridCols;
		this.cellRows = cellRows;	this.cellCols = cellCols;
		
		var rows = gridRows * cellRows;
		var cols = getColumnFromCoords(gridCols, gridRows - 1);
		
		window = new TextWindow(rows, cols);
		
		leftCellBracket = new TextWindow(cellRows, 1, "leftCellBracket");
		leftCellBracket.write("[", 0);
		leftCellBracket.write("[", cellRows - 1);
		
		rightCellBracket = new TextWindow(cellRows, 1, "rightCellBracket");
		rightCellBracket.write("]", 0);
		rightCellBracket.write("]", cellRows - 1);
		
		window.addChild(leftCellBracket, false);
		window.addChild(rightCellBracket, false);	
		
		//deal with drawing bug, then delete old bracket code
		
		super(name);
	}
	
	override public function set_activeCellKey(key) {
		if (cells.exists(key)) {
			var x = Point2D.xFromString(key);
			var y = Point2D.yFromString(key);
			
			var row = getRowFromCoords(x, y);
			var col = getColumnFromCoords(x, y);
			
			window.findChild("leftCellBracket").parentFirstRow = row;
			window.findChild("leftCellBracket").parentFirstColumn = col - 1;

			window.findChild("rightCellBracket").parentFirstRow = row;
			window.findChild("rightCellBracket").parentFirstColumn = col + cellCols;

			return this.activeCellKey = key;
		}
		else {
			return this.activeCellKey = null;
		}
	}
	
	//is point that lies in the bounds of the grid
	inline public function isValidPoint(key:String) {
		if (!Point2D.isPoint(key)) return false;
		
		var x = toCellX(key);
		if (x < 0 || x >= gridCols) return false;
		
		var y = toCellY(key);
		if (y < 0 || y >= gridRows) return false;
		
		//the hex grid is not a perfect parallelogram. The acute corners are truncated. 
		//This keeps the island a little more centered
		if (x == 0 && y == 0) return false;
		
		if (x == gridCols - 1 && y == gridRows - 1) return false;  
		
		return true;
	}
	
	inline public function toCellKey(x:Int, y:Int) {
		return Point2D.coordsToString(x, y);
	}
	
	inline public function toCellX(key:String) {
		return Point2D.xFromString(key);
	}

	inline public function toCellY(key:String) {
		return Point2D.yFromString(key);
	}

	public overload extern inline function addCell(cell:Cell, x:Int, y:Int) {

		cell.name = toCellKey(x, y);
		addCellWithoutAdjacency(cell, cell.name);
		
		for (k in [ toCellKey(x, y - 1), toCellKey(x + 1, y - 1),	//all 6 potential neighboring hexes
					toCellKey(x - 1, y), toCellKey(x + 1, y),
					toCellKey(x - 1, y + 1), toCellKey(x, y + 1) ]) {
			makeAdjacent(cell.name, k);
		}
						
		window.addChild(cell, getRowFromCoords(x, y), getColumnFromCoords(x, y));
	}
	
	
	public overload extern inline function removeCell(x:Int, y:Int) {
		var label = toCellKey(x, y);
		removeCell(label);
		window.removeChild(label);
	}
	
	//row of top-left char of the Cell at coords
	public function getRowFromCoords(x:Int, y:Int) {
		return y * cellRows;
	}
	
	//column of top-left char of the Cell at coords
	public function getColumnFromCoords(x:Int, y:Int) {
		return 1 + Std.int((y * (cellCols + 1) / 2)) + x * (cellCols + 1);
	}
	
	public function fillWithCells() {
		for (i in 0...gridRows) {
			for (j in 0...gridCols) {
				var cell = new Cell(cellRows, cellCols, toCellKey(j, i));
				addCell(cell, j, i);
			}
		}
	}
	
	public function allCellCoords() {
		return [for (str in cells.keys()) Point2D.pointFromString(str)];
	}
	
	public function distanceSquaredToCell(from:String, to:String):Null<Int> {
		if (!isValidPoint(from)) return null;
		if (!isValidPoint(to)) return null;
		
		var dx = toCellX(to) - toCellX(from);
		var dy = toCellY(to) - toCellY(from);
		
		return (dx + dy) * (dx + dy) - dx * dy;
		//The above is equal to dx * dx + dy * dy + dx * dy, 
		//which is the cosine rule applied to 120 deg.
		//Faster because of one fewer multiplication
	}
	
	
	//positive x-axis extends to the right, is 0 radians
	//positive y-axis extends diagonally 60 degrees down and to the right
	public function angleToCell(from:String, to:String):Null<Float> {
		if (!isValidPoint(from)) return null;
		if (!isValidPoint(to)) return null;
		
		var dx = toCellX(to) - toCellX(from);
		var dy = toCellY(to) - toCellY(from);
		
		return Math.acos((dx + dy / 2) / Math.sqrt(distanceSquaredToCell(from, to)));
		//I'm so concerned about saving one multiplication in the function above, but 
		//there are more efficient ways to compute/estimate this
	}
	
	public function isLeftOf(to:String, from:String):Null<Bool> {
		return isInDirectionOf(to, Direction.Left, from);
	}
	
	public function isRightOf(to:String, from:String):Null<Bool> {
		return isInDirectionOf(to, Direction.Right, from);
	}
	
	public function isUpOf(to:String, from:String):Null<Bool> {
		return isInDirectionOf(to, Direction.Up, from);
	}
	
	public function isDownOf(to:String, from:String):Null<Bool> {
		return isInDirectionOf(to, Direction.Down, from);
	}
		
	
	public function isInDirectionOf(to:String, dir:Direction, from:String):Null<Bool> {
		if (!isValidPoint(from)) return null;
		if (!isValidPoint(to)) return null;

		var dx = toCellX(to) - toCellX(from);
		var dy = toCellY(to) - toCellY(from);
		
		switch(dir) {
			case Left:
				return 2 * dx < -dy;
			case Right:
				return 2 * dx > -dy;
			case Up:
				return dy < 0;
			case Down:
				return dy > 0;
			
			case DownRight:
				return dx > 2 * -dy;
			case UpLeft:	
				return dx < 2 * -dy;
				
			case DownLeft:
				return (dx + dy) > 2 * dx;
			case UpRight:
				return (dx + dy) < 2 * dx;
		}

	}
	
	public function closestCellInDirection(p:String, dir:Direction) {
		if (!isValidPoint(p)) return null;
		
		var closestCell = p;
		var closestDistanceSquared:Null<Int> = 0;
		var closestAngle:Float = 0;
		
		var idealAngle;
		
		switch(dir) {
			case Direction.Up:
				idealAngle = Math.PI * 1.01 / 2; 	//up, but slightly inclined to the left to break ties to the left
			case Direction.Down:
				idealAngle = Math.PI * 0.99 / 2;	//up, but slightly inclined to the right to break ties to the right
			case Direction.Left:
				idealAngle = Math.PI;
			case Direction.Right:
				idealAngle = 0;
			
			case Direction.UpLeft:
				idealAngle = Math.PI * 2.01 / 3;
			case Direction.UpRight:
				idealAngle = Math.PI * 0.99 / 3;
			case Direction.DownLeft:
				idealAngle = Math.PI * 2.01 / 3;
			case Direction.DownRight:
				idealAngle = Math.PI * 0.99 / 3;
		}
		
		var x = toCellX(p);
		var y = toCellY(p);
		
		for (q in cells.keys()) {
			if (isValidPoint(q)) {
				if (isInDirectionOf(q, dir, p)) {
					//q is new closest cell to the left
					if (closestDistanceSquared == 0 || distanceSquaredToCell(p, q) < closestDistanceSquared) {
						
						closestCell = q;
						closestDistanceSquared = distanceSquaredToCell(p, q);
						closestAngle = Math.abs((angleToCell(p, q) - idealAngle));

						trace("closer " + q + " " + closestAngle);						
					}
					else if (distanceSquaredToCell(p, q) == closestDistanceSquared) {
						
						if ( Math.abs((angleToCell(p, q) - idealAngle)) <= closestAngle ) {
							
							closestCell = q;
							closestDistanceSquared = distanceSquaredToCell(p, q);
							closestAngle = Math.abs((angleToCell(p, q) - idealAngle));
							
							trace("ideal angle " + idealAngle);
							trace("current angle " + angleToCell(p, q));
							trace("closer angle " + q + " " + closestAngle);
						}
					}
				}
			}
		}
		
		return closestCell;
	}
	
	
	
	//returns array of cell keys that could be neighbors but a
	public function potentialNeighbors(key:String) {
		if (isValidPoint(key)) {
		
			var neighbors = [];
			
			var x = toCellX(key);	var y = toCellY(key);
			
			for (n in [ toCellKey(x, y - 1), toCellKey(x + 1, y - 1),	//all 6 potential neighboring hexes
						toCellKey(x - 1, y), toCellKey(x + 1, y),
						toCellKey(x - 1, y + 1), toCellKey(x, y + 1) ]) {
			
				//inefficient. Coords get converted to keys, but get converted back to coords in isValidPoint()
				//but the the inefficiency is generally negligible and I can't think of a cleaner way to code it
				if (isValidPoint(n) && !cells[key].neighbors.contains(n)) neighbors.push(n);
			}
				
			return neighbors;
		}
		
		return null;	//should I return null or an empty array?
		
	}
	
	
	public function cellKeysWithPotentialNeighbors() {
		
		var keys = [];
		
		for (k in cells.keys()) {
			if (potentialNeighbors(k).length > 0) {
				keys.push(k);
			}
		}
		
		return keys;
	}
	
	public function display() {

		window.display();		
	}
	
}


class Cell extends TextWindow
{
	public var grid:Grid;
	
	public var neighbors:Array<String>;
	
	public function new(rows:UInt, columns:UInt, ?name:String) {
		super(rows, columns, name);
		neighbors = [];
		defaultChar = '.';
		clear();
	
	}
	
	override public function render() {
		
		clear();
	}
	
}


class Point2D {
	
	var x:Int;	var y:Int;
	
	public function new(newx:Int, newy:Int) {
		x = newx;	y = newy;
	}
	
	public function toString() {
		return '$x, $y';
	}
	
	static public function coordsToString(x:Int, y:Int) {
		return '$x, $y';	
	}
	
	static public function isPoint(str:String) {
		if (xFromString(str) == null || yFromString(str) == null) return false;
		
		return true;
	}
	
	//do I want to guarantee that str represents a valid Point2D?
	static public function xFromString(str:String):Null<Int> {
		return Std.parseInt(str);
	}
	
	static public function yFromString(str:String):Null<Int> {
		var coords = str.split(',');
		if (coords.length >= 2) {
			return Std.parseInt(coords[1]);
		}
		else {
			return null;
		}
	}
	
	static public function pointFromString(str:String) {
		var x = xFromString(str);
		var y = yFromString(str);
		
		if (x != null && y != null) return new Point2D(x, y);
		else return null;
	}
	
}

enum Direction {
	Left;
	Right;
	Up;
	Down;
	
	UpLeft;
	UpRight;
	DownLeft;
	DownRight;
}



