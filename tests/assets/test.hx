import haxe.ds.StringMap;

typedef HaxeStringMap = StringMap;
typedef HaxeIntMap = haxe.ds.IntMap;

typedef Human = {
	isSecretlyAFurry: Bool
}

typedef Entity = {
	ai: Bool
}

typedef Person = {
	> Human,
	> Entity,
	name: String,
	age: Int
}

typedef Animal = Entity & {species: String};
typedef Callback = Animal->Void & {name: String};
final test = "Iris";

trace("Top level " + test);
function main() {
	// test = "Lua"; // should error
	trace("Hello from " + test);

	final enumTest = Test.A;
	final enumTestTwo = Test.D(0);
	trace("Enum Value A: " + enumTest);
	trace("Enum Value D: " + enumTestTwo);
	trace(HaxeStringMap);
	trace(HaxeIntMap);

	trace(0b1010);
	trace(0b1010_1010);
	trace(0xFF);
	trace(0xFF_FF);

	trace(5 & 2);

	var obj = null;
	obj?.name = "Crow";
	trace(obj?.name);

	trace(obj?.name?.length ?? "invalid length");

	obj ??= {name: "Crow"};
	obj ??= {};
	trace(obj.name);

	switch (test) {
		case "Iris":
			trace("Matching Iris");
		default:
			trace("Not Matching");
	}

	return "Return value";
}

enum Test {
	A;
	B;
	C;
	D(a: Int);
}
