package crowplexus.iris.utils;

@:dox(hide)
typedef UsingCall = (o: Dynamic, f: String, args: Array<Dynamic>) -> Dynamic;

@:dox(hide)
class UsingEntry {
	public var name: String;
	public var call: UsingCall;

	public function new(name: String, call: UsingCall) {
		this.name = name;
		this.call = call;
	}
}
