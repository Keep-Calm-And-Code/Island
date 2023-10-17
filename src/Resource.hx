package;

/**
 * ...
 * @author 
 */

enum Resource {
	Grain;
	Wood;
	Metal;
}


var names = [
	Resource.Grain => "Grain",
	Resource.Wood => "Wood",
	Resource.Metal => "Metal"
];



class Pile {
	
	public var resources:Map<Resource, Int>;
	
	public function new(?resources:Map<Resource, Int>) {
		if (resources == null) {
			this.resources = [];
		}
		else {
			this.resources = resources;
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
		if (resources.exists(r)) resources[r] += n;
		else resources[r] = n;
	}
	
	//will not result in negative resources
	public function cutoffAdd(r:Resource, n:Int) {
		if (resources.exists(r)) resources[r] = Utils.maxInt(resources[r] + n, 0);
		else resources[r] = Utils.maxInt(n, 0);
	}
	
	public function subtract(r:Resource, n:Int) {
		add(r, -n);
	}
	
	//will not result in negative resources
	public function cutoffSubtract(r: Resource, n:Int) {
		cutoffAdd(r, -n);
	}
	
	public function addPile(p:Pile) {
		for (r in p.resources.keys()) {
			add(r, p.resources[r]);
		}
	}
	
	public function cutoffAddPile(p:Pile) {
		for (r in p.resources.keys()) {
			cutoffAdd(r, p.resources[r]);
		}
	}
		
	public function subtractPile(p:Pile) {
		for (r in p.resources.keys()) {
			subtract(r, p.resources[r]);
		}		
	}
	
	public function cutoffSubtractPile(p:Pile) {
		for (r in p.resources.keys()) {
			cutoffSubtract(r, p.resources[r]);
		}		
	}
	
}




