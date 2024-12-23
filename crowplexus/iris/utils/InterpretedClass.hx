package crowplexus.iris.utils;

// someday
@:structInit
class InterpretedClass {
	/**
	 * This is your class's name
	**/
	public var name: String;

	/**
	 * This is your class's parent class.
	 *
	 * Defined when your class extends another
	 *
	 * class MyClass extends ParentClass {}
	**/
	public var parent: Dynamic;

	/**
	 * This is used for interfaces.
	 *
	 * class MyClass implements Interface1 implements Interface2...
	**/
	public var siblings: Array<Dynamic>;

	/**
	 * Creates a new interpreted class.
	 * @param name 			Name of the class, used to store it globally.
	 * @param parent 		The class' parent, used for inheritance.
	 * @param siblings 	The class' siblings, used for interface implementation.
	**/
	public function new(name: String, ?parent: Dynamic, ?siblings: Array<Dynamic>) {
		this.name = name;
		this.parent = parent;
		if (siblings == null)
			siblings = [];
		this.siblings = siblings;
	}

	/**
	 * Returns the upper class to this class (the one that it extends)
	**/
	public function getUpper()
		return parent;

	/**
	 * Returns this very class.
	**/
	public function getSelf()
		return this;

	public function getField(name: String) {
		var self = getSelf();
		var upper = getUpper();
		if (Reflect.hasField(self, name))
			return Reflect.field(self, name);
		if (upper != null && Reflect.hasField(upper, name))
			return Reflect.field(upper, name);
		return null;
	}
}
