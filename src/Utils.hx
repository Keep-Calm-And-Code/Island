import Math;
import haxe.ds.Vector;

class Utils {
	   
	//returns a random integer between min and max inclusive
    static public function randomInt(min:Int, ?max:Int = 0):Int {
		if (min > max) {
			var temp = min; 
			max = min;
			min = temp;
		}
		
		return Math.floor( min + Math.random() * (max - min + 1) );
	}
	
	static public function maxInt(a:Int, b:Int):Int {
		if (a > b) { return a; }
		else { return b; }
	}
	
	static public function minInt(a:Int, b:Int, ?c:Int):Int {
		if (c == null) {
			if (a < b) { return a; }
			else { return b; }
		}
		else return minInt(a, minInt(b, c));
	}	
	
	static public function randomElement(a:Array<Dynamic>) {
		if (a.length == 0) return null;
		
		return(a[randomInt(0, a.length - 1)]);
	}
	

	macro static public function assert(condition, ?message) {
		 #if debug
			return macro if (!($condition)) { throw($message == null ? "assert error" : $message); }
		 #else
			return macro {};
		 #end
	}
	
}




class DescIter {
	
	public var end:Int;
	public var at:Int;
	
	public function new(max:Int, min:Int) {
		at = max;
		end = min;
	}
	
	public function hasNext() { return (at >= end); }
	
	public function next() { return at--; }
	
}


class Vector2D {
	
    public static function create(h:Int, w:Int)
    {
        var v = new Vector(h);
        for (i in 0...h)
        {
            v[i] = new Vector(w);
        }
        return v;
    }
}


