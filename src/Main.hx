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
		var island = new Island("Home");
		
		island.display();
		
		island.inputLoop();
	}
	
}