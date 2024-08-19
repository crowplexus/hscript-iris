import haxe.ds.StringMap;

typedef HaxeStringMap = StringMap;
typedef HaxeIntMap = haxe.ds.IntMap;

typedef Human = {
	isSecretlyAFurry: Bool
}

typedef Person = {
	> Human,
	name: String,
	age: Int
}

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

	var obj = null;
	obj?.name = "Crow";
	trace(obj?.name);

	trace(obj?.name?.length ?? "invalid length");

	obj ??= {name: "Crow"};
	trace(obj.name);

	return "Return value";
}

enum Test {
	A;
	B;
	C;
	D(a: Int);
}
