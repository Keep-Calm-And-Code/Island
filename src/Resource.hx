package;

/**
 * ...
 * @author 
 */

enum Resource {
	Grain;
	Fish;
	Wood;
	Metal;
	Tools;
	Goods;
}


var names = [
	Resource.Grain => "Grain",
	Resource.Fish => "Fish",
	Resource.Wood => "Wood",
	Resource.Metal => "Metal",
	Resource.Tools => "Tools",
	Resource.Goods => "Goods"
];


//Currently if a resource hasn't been interacted with to form the pile (i.e. the resource isn't
//relevant to the pile), the resources Map will not contain it as a key
//
//Note that a resource could map to 0; that means it's been interacted with when forming the pile
//(just so happens the value ended up as 0)
//
//Alternatively, should resources contain every resource as a key, and have null values
//indicate resources that haven't been interacted with?
//This means each instance of Pile is larger and takes longer to operate on them. But
//maybe conditionals involving them generally become cleaner?

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
		return toResourceAlignedString();
	}
	
	public function toLeftAlignedString(?isResourceNameVisible = true, ?isIncomeString = false) {
		var all = "";
		
		for (r in resources.keys()) {
			
			var s = resources[r] + " ";
			if (isIncomeString && resources[r] >= 0) s = '+' + s;
			if (isResourceNameVisible) s += names[r];
			
			var padLength = Utils.maxInt((10 - s.length), 0);
			for (i in 0...padLength) {
				s += " ";
			}
			
			all += s;
		}
		
		return all;
	}
	
	public function toResourceAlignedString(?isResourceNameVisible = true, ?isIncomeString = false) {
		var all = "";
		
		for (r in Type.allEnums(Resource)) {
			
			var s = "";
			if (resources.exists(r)) {
				s = resources[r] + " ";
				if (isIncomeString && resources[r] >= 0) {
					s = '+' + s;
				}
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
	
	
	public function get(r:Resource) {
		if (resources.exists(r)) {
			return resources[r];
		}
		else return null;
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
		return this;
	}
	
	//will not result in negative resources
	public function cutoffAdd(r:Resource, n:Int) {
		if (resources.exists(r)) resources[r] = Utils.maxInt(resources[r] + n, 0);
		else resources[r] = Utils.maxInt(n, 0);
		return this;	
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
		return this;
	}
	
	public function cutoffAddPile(p:Pile) {
		for (r in p.resources.keys()) {
			cutoffAdd(r, p.resources[r]);
		}
		return this;
	}
		
	public function subtractPile(p:Pile) {
		for (r in p.resources.keys()) {
			subtract(r, p.resources[r]);
		}		
		return this;
	}
	
	public function cutoffSubtractPile(p:Pile) {
		for (r in p.resources.keys()) {
			cutoffSubtract(r, p.resources[r]);
		}		
		return this;
	}
	
	//This function, or anything else used to compute production bonii/malii should be
	//deterministic.
	//
	//the ideal is to have a function that cleverly performs rounding so that:
	//1) the total number of resources in the product is equal to 
	//   the total number of resources in the original pile * f, rounded
	//2) as f increases, no resource in the product ever decreases, i.e.
	//   f > g implies pile * f contains pile * g
	//
	//Current naive approach is simple but fails 1). But works well enough.
	public function multiplyAndRound(f:Float) {
		var product = new Pile();
		
		for (r in resources.keys()) {
			product.add(r, Math.floor(resources[r] * f + 0.5));
		}
		
		return product;
	}
	
}



