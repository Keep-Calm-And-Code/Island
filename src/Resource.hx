package;

/**
 * ...
 * @author 
 */

enum Resource {
	Food;
	Wood;
}


var names = [
	Resource.Food => "Food",
	Resource.Wood => "Wood"
];



class Pile {
	
	public var resources:Map<Resource, Int>;
	
	public function new(?newResources:Map<Resource, Int>) {
		if (newResources == null) {
			resources = [];
		}
		else {
			for (value in newResources) {
				if (value < 0) throw "Cannot have negative resources";
			}
			
			resources = newResources;
		}
	}
	
	public function toString() {
		return toResourceAlignedString("");
	}
	
	public function toLeftAlignedString(?prefix:String = "", ?isResourceNameVisible = true) {
		var all = "";
		
		for (r in resources.keys()) {
			
			var s = prefix + resources[r] + " ";
			if (isResourceNameVisible) s += names[r];
			
			var padLength = Utils.maxInt((10 - s.length), 0);
			for (i in 0...padLength) {
				s += " ";
			}
			
			all += s;
		}
		
		return all;
	}
	
	public function toResourceAlignedString(?prefix:String = "", ?isResourceNameVisible = true) {
		var all = "";
		
		for (r in Type.allEnums(Resource)) {
			
			var s = "";
			if (resources.exists(r)) {
				s = prefix + resources[r] + " ";
				if (isResourceNameVisible) s += names[r];
			}
			
			var padLength = Utils.maxInt((10 - s.length), 0);
			for (i in 0...padLength) {
				s += " ";
			}
			
			all += s;
		}
		
		return all;
	}
	
	public function hasPile(p:Pile) {
		for (r in p.resources.keys()) {
			if (!resources.exists(r) || resources[r] < p.resources[r]) {
				return false;
			}
		}
		return true;
	}
	
	public function add(r:Resource, n:Int) {
		if (n < 0) throw "add() is only for increasing resources";
		
		if (resources.exists(r)) {
			resources[r] += n;
		}
		else {
			resources[r] = n;
		}
	}
	
	//will not subtract if there is less than n of the resource
	public function subtract(r:Resource, n:Int) {
		if (n < 0) throw "subtract() is only for decreasing resources";
		if (!resources.exists(r)) throw "cannot subtract a resource not in the pile";
		
		if (resources[r] < n) throw "not enough resources to subtract";	//improve handling
		
		resources[r] -= n;
		
	}
	
	//always subtracts the resources, but will stop at 0
	public function forceSubtract(r:Resource, n:Int) {
		if (n < 0) throw "forceSubtract() is only for decreasing resources";
		
		if (resources.exists(r)) resources[r] = Utils.maxInt(resources[r] - n, 0);
		
	}
	
	public function addPile(p:Pile) {
		for (r in p.resources.keys()) {
			add(r, p.resources[r]);
		}
	}
	
	public function subtractPile(p:Pile) {
		for (r in p.resources.keys()) {
			this.subtract(r, p.resources[r]);
		}		
	}
	
	public function forceSubtractPile(p:Pile) {
		for (r in p.resources.keys()) {
			this.forceSubtract(r, p.resources[r]);
		}		
	}
}




