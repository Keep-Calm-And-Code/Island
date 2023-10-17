import haxe.ds.Vector;

//uses ANSIcon to display colored characters. These are the ANSI escape sequences
@:enum
abstract ANSIColor(String) {
	var black 	= '\033[0;30m';
	var red 	= '\033[0;31m';
	var green 	= '\033[0;32m';
	var brown 	= '\033[0;33m';
	var blue 	= '\033[0;34m';
	var magenta = '\033[0;35m';
	var cyan 	= '\033[0;36m';
	var gray 	= '\033[0;37m';
		
	var darkgray 		= '\033[1;30m';
	var lightred		= '\033[1;31m';
	var lightgreen		= '\033[1;32m';
	var lightbrown	 	= '\033[1;33m';
	var lightblue		= '\033[1;34m';
	var lightmagenta 	= '\033[1;35m';
	var lightcyan		= '\033[1;36m';
	var white	 		= '\033[1;37m';
	
	var none = '';
}

class ColoredChar {
	
	public var char(default, default):String;
	public var ansiColor(default, default):ANSIColor;
	
	public function new(?char:String = ' ', ?color = ANSIColor.gray) {
		if (char.length != 1) throw "Not a character; string length not 1";
	
		this.char = char;
		this.ansiColor = color;
	}	
}


class ChildWindowInfo {
	
	public var window:TextWindow;
	
	public var parentFirstRow:Int;
	public var parentFirstColumn:Int;
	
	public var displayFirstRow:Int;
	public var displayFirstColumn:Int;
	
	public var displayRows:Int;
	public var displayColumns:Int;

	public var isVisible:Bool;
	
	public function new(child:TextWindow, pfrow = 0, pfcol = 0, 
						?dFRow = 0, ?dFCol = 0, ?dRows, ?dCols, isVisible = true) {
		window = child;
		
		parentFirstRow = pfrow;
		parentFirstColumn = pfcol;
		
		displayFirstRow = dFRow;
		displayFirstColumn = dFCol;
		
		if (dRows == null) displayRows = window.rows;
		else displayRows = dRows;
		if (dCols == null) displayColumns = window.columns;
		else displayColumns = dCols;
		
		this.isVisible = isVisible;
	}
}


class TextScreen {
	
	public var defaultChar = ' ';
	public var defaultTextColor = ANSIColor.gray;
	
	public var rows(default, null):UInt; public var columns(default, null):UInt;
	
	public var displayBuffer:Vector<Vector<ColoredChar>>;
	
	public var childWindowInfoList:Array<ChildWindowInfo>;
	
	public function new(?rows = 24, ?columns = 80) {
		if (rows < 1) throw 'rows must be a positive integer';
		if (columns < 1) throw 'columns must be a positive integer';
		this.rows = rows;
		this.columns = columns;
		
		this.displayBuffer = new Vector(rows);
		for (i in 0...rows) {
			this.displayBuffer[i] = new Vector<ColoredChar>(columns);
		}
		
		childWindowInfoList = new Array<ChildWindowInfo>();
		
		clear();
	}
	
 
	public function write(text:String, ?color:ANSIColor = null, ?row = 0, ?column = 0) {

		if ((row < 0) || (row >= rows)) throw "row outside of range";
		if (column < 0) {
			var writeFrom = Utils.minInt(text.length, -column);
			text = text.substr(writeFrom);
			column = 0;
		}
		
		if (color == null) color = defaultTextColor;
		for (i in 0...Math.round(Math.min(text.length, this.columns - column))) {  //this is stupid, how do I cast properly?
			displayBuffer[row][column + i] = new ColoredChar(text.charAt(i), color);
		}
	}
	
	public function writeLeft(text:String, ?color:ANSIColor = null, ?rows = 0, ?column) {
		if (column == null) column = columns - 1;
		write(text, color, rows, column - text.length + 1);
	}
	
	
	public function clear(?fill:String) {		
		if (fill == null) fill = defaultChar;
		fill = fill.charAt(0);
		
		for (i in 0...rows) {
			for (j in 0...columns) {
				displayBuffer[i][j] = new ColoredChar(fill, defaultTextColor);
			}
		}		
	}
	
	
	public function addChild(child:TextWindow, parentFirstRow = 0, parentFirstCol = 0, 
							 displayFirstRow = 0, displayFirstCol = 0,
							 ?displayRows, ?displayCols, isVisible = true) {
		var info = new ChildWindowInfo(child, parentFirstRow, parentFirstCol, 
									   displayFirstRow, displayFirstCol,
									   displayRows, displayCols, isVisible);
		childWindowInfoList.push(info);
	}
	
	//removes ALL child windows of this name
	public function removeChild(name:String) {
		for (info in childWindowInfoList) {
			if (info.window.name == name) {
				childWindowInfoList.remove(info);
			}
		}
	}
	
	public function findChild(name:String) {
		for (info in childWindowInfoList) {
			if (info.window.name == name) {
				return info;
			}
		}
		return null;
	}
	
	
	public function render() {  //writes contents of child windows onto displayBuffer
								//note that this overwrites anything you write onto the displayBuffer!
								//subclasses of this class should implement some kind of data buffer to write to							
		var rowsToRender:Int;
		var columnsToRender:Int;

		//child may be added to negative row and column. This will cause access error in displayBuffer. FIX!
		for (child in childWindowInfoList) {
			child.window.render();	//first update child's displayBuffer		
			rowsToRender = Utils.minInt(child.window.rows - child.displayFirstRow, child.displayRows, rows - child.parentFirstRow);
			columnsToRender = Utils.minInt(child.window.columns - child.displayFirstColumn, child.displayColumns, columns - child.parentFirstColumn);				
			for (row in 0...rowsToRender) {
				for (col in 0...columnsToRender) {
					displayBuffer[child.parentFirstRow + row][child.parentFirstColumn + col] = child.window.displayBuffer[child.displayFirstRow + row][child.displayFirstColumn + col];   //copies chars from child's displayBuffer to our displayBuffer
				}
			}
		}
		
		
	}
	
    
	public function display() {
		displayMonochrome();
	}
	
	public function displayColour() {
		render();
		var currentChar = new ColoredChar();
		var currentLine = "";
		
		for (i in 0...rows) {
			currentLine = "";
			for (j in 0...columns) {
				currentChar = displayBuffer[i][j];
				currentLine += (currentChar.ansiColor + currentChar.char);
			}
			Sys.println(currentLine);
		}
	}
	
	
	public function displayMonochrome() {
		render();
		var currentLine = "";
		
		for (i in 0...rows) {
			currentLine = "";
			for (j in 0...columns) {
				currentLine += displayBuffer[i][j].char;
			}
			Sys.println(currentLine);
		}
	}
	
	//pads or truncates strings to a specific length
	static public function pad(str:String, length:Int) {
		padRight(str, length);
	}
	
	static public function padRight(str:String, length:Int) {
		if (length < 0) throw "length cannot be negative";		
		if (str.length > length) {
			return str.substr(0, length);
		}
		else {
			for (i in 0...length - str.length) {
				str += " ";
			}
			return str;
		}
	}
	
	static public function padLeft(str:String, length:Int) {
		if (length < 0) throw "length cannot be negative";		
		if (str.length > length) {
			return str.substring(str.length - length);
		}
		else {
			for (i in 0...length - str.length) {
				str = " " + str;
			}
			return str;
		}
	}

	
}



class TextWindow extends TextScreen {
	
	public var name:String;
	
	//write data to this buffer first before copying to displaybuffer
	//this contains all the data possessed the window can potentially display
	//displayBuffer contains what is going to be displayed, which is gathered from
	//this databuffer as well as that of child TextWindows
	//
	//I've yet to make full use of this separation.
	public var dataBuffer:Vector<Vector<ColoredChar>>;
	
	override public function new(?rows = 24, ?columns = 80, ?name = "") {
		this.name = name;
		dataBuffer = new Vector(rows);
		for (i in 0...rows) {
			dataBuffer[i] = new Vector<ColoredChar>(columns);
		}
		
		super(rows, columns);
	}
	
	override public function write(text:String, ?color:ANSIColor = null, ?row = 0, ?column = 0) {

		if (color == null) color = defaultTextColor;
		for (i in 0...Math.round(Math.min(text.length, this.columns - column))) {  //this is stupid, how do I cast properly?
			dataBuffer[row][column + i] = new ColoredChar(text.charAt(i), color);
		}
	}

	override public function clear(?fill:String) {
		if (fill == null) fill = defaultChar;
		fill = fill.charAt(0);
		
		for (i in 0...rows) {
			for (j in 0...columns) {
				displayBuffer[i][j] = new ColoredChar(defaultChar, defaultTextColor);
				dataBuffer[i][j] = new ColoredChar(defaultChar, defaultTextColor);
			}
		}		
	}
	
	//need to extend to allow change of display area. Remember ChildWindowOptions
	override public function render() {
		copyDataBuffer();
		super.render();   //then writes child windows onto displayBuffer		
	}
	
	public function copyDataBuffer() {
		for (row in 0...rows) {
			for (col in 0...columns) {
				displayBuffer[row][col] = dataBuffer[row][col];   //copies dataBuffer onto displayBuffer
			}
		}
	}

	
}


class TextLog extends TextWindow {
	
	public var stringBuffer:List<String>;   //stores logged strings. Most recently logged string is last
	public var maxLength:Int;   //max number of strings to store in dataBuffer
								//maxLength = 0 means no max
								
	public function new(rows = 24, columns = 80, length = 10) {
		if (length < 1) throw "length must be a positive integer";
		maxLength = length;
		stringBuffer = new List<String>();
		
		super(rows, columns);
	}
	
	public function log(string:String) {    //should I also override write()?
		stringBuffer.add(string);
		if (maxLength != 0 && stringBuffer.length > maxLength) {
			stringBuffer.pop();
		}
	}
	
	override public function render() {   //doesn't support wordwrap. Improve!
		var firstLineToRender = Utils.maxInt(stringBuffer.length - rows, 0);
		var currentRow = 0;
		for (line in stringBuffer) {
			if (currentRow >= firstLineToRender) {
				write(line, currentRow);
			}
			currentRow++;
		}
		super.render();
	}
	
	override public function clear(?fill) {
		stringBuffer.clear();
		super.clear();
	}
	
}


class TextMenu extends TextWindow {
	
	public var orientation:TextMenuType;
	
	public var menuOptions:Array<MenuOption>;
	
	override public function new() {
		super();
	}
	
}


class TextMenuType {
	
}


class MenuOption {
	
	public var name:String;
	public var key:String;
	public var call:Void -> Void; 
	
	public function new(name:String, ?key:String) {
		this.name = name;
		this.key = key;
	}
		
}


abstract ASCIIChar(String) from String to String {
	
	inline public function new(str:String) {
		this = str;
	}
	
	@:from
	static public function fromInt(i:Int) {
		switch(i) {
			case 32:
				return new ASCIIChar(' ');
			case 48:
				return new ASCIIChar('0');
			case 49:
				return new ASCIIChar('1');
			case 50:
				return new ASCIIChar('2');
			case 51:
				return new ASCIIChar('3');
			case 52:
				return new ASCIIChar('4');
			case 53:
				return new ASCIIChar('5');
			case 54:
				return new ASCIIChar('6');
			case 55:
				return new ASCIIChar('7');
			case 56:
				return new ASCIIChar('8');
			case 57:
				return new ASCIIChar('9');
			case 65:
				return new ASCIIChar('A');
			case 66:
				return new ASCIIChar('B');
			case 67:
				return new ASCIIChar('C');
			case 68:
				return new ASCIIChar('D');
			case 69:
				return new ASCIIChar('E');
			case 70:
				return new ASCIIChar('F');
			case 71:
				return new ASCIIChar('G');
			case 72:
				return new ASCIIChar('H');
			case 73:
				return new ASCIIChar('I');
			case 74:
				return new ASCIIChar('J');
			case 75:
				return new ASCIIChar('K');
			case 76:
				return new ASCIIChar('L');
			case 77:
				return new ASCIIChar('M');
			case 78:
				return new ASCIIChar('N');
			case 79:
				return new ASCIIChar('O');
			case 80:
				return new ASCIIChar('P');
			case 81:
				return new ASCIIChar('Q');
			case 82:
				return new ASCIIChar('R');
			case 83:
				return new ASCIIChar('S');
			case 84:
				return new ASCIIChar('T');
			case 85:
				return new ASCIIChar('U');
			case 86:
				return new ASCIIChar('V');
			case 87:
				return new ASCIIChar('W');
			case 88:
				return new ASCIIChar('X');
			case 89:
				return new ASCIIChar('Y');
			case 90:
				return new ASCIIChar('Z');
			case 91:
				return new ASCIIChar('[');
			case 92:
				return new ASCIIChar('\\');
			case 93:
				return new ASCIIChar(']');
			case 94:
				return new ASCIIChar('^');
			case 95:
				return new ASCIIChar('_');
			case 96:
				return new ASCIIChar('`');
			case 97:
				return new ASCIIChar('a');
			case 98:
				return new ASCIIChar('b');
			case 99:
				return new ASCIIChar('c');
			case 100:
				return new ASCIIChar('d');
			case 101:
				return new ASCIIChar('e');
			case 102:
				return new ASCIIChar('f');
			case 103:
				return new ASCIIChar('g');
			case 104:
				return new ASCIIChar('h');
			case 105:
				return new ASCIIChar('i');
			case 106:
				return new ASCIIChar('j');
			case 107:
				return new ASCIIChar('k');
			case 108:
				return new ASCIIChar('l');
			case 109:
				return new ASCIIChar('m');
			case 110:
				return new ASCIIChar('n');
			case 111:
				return new ASCIIChar('o');
			case 112:
				return new ASCIIChar('p');
			case 113:
				return new ASCIIChar('q');
			case 114:
				return new ASCIIChar('r');
			case 115:
				return new ASCIIChar('s');
			case 116:
				return new ASCIIChar('t');
			case 117:
				return new ASCIIChar('u');
			case 118:
				return new ASCIIChar('v');
			case 119:
				return new ASCIIChar('w');
			case 120:
				return new ASCIIChar('x');
			case 121:
				return new ASCIIChar('y');
			case 122:
				return new ASCIIChar('z');
			default:
				return new ASCIIChar('other');
		}
	}
}