package;

import TextScreen;
import Grid;
import Utils;

/**
 * ...
 * @author 
 */
class Main 
{
	
	static function main() 
	{
	
		var screen = new TextScreen(24);
		screen.writeLeft("Hello", 0, 3);
		screen.display();
		
		/*
		var island = new OldIsland("Home", screen);
		
		island.display();
		
		turn(island);			
		
		island.nextTurn();
		
		island.display();
		*/	
		
		var island = new Island(6, "Mine");	
		
		island.grid.activeCellKey = "2, 2";
		
		trace(island.grid.potentialNeighbors("3, 3"));
				
		island.display();
		island.inputLoop();
		
	}
	
}