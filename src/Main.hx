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
			
		
		var test = new Island(14, Island.GenerationType.Random, "Test");
		
		test.display();
		
		
		/*
		var island = new Island(6, Island.GenerationType.Filled, "Mine");	
		
		island.grid.removeCell(2, 3);
		island.grid.removeCell(3, 4);
		
		island.grid.activeCellKey = "2, 2";
			
		island.display();
		*/
		
		test.inputLoop();
		
	}
	
}