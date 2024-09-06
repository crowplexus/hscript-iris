import haxe.ds.StringMap;
import Type;

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

	var enum1 = Test.A;
	var enum2 = Test.A;
	trace("Test.A == Test.A: " + (enum1 == enum2));
	trace("Type.enumEq(Test.A, Test.A): " + Type.enumEq(enum1, enum2));

	var enum3 = Test.D(0);
	var enum4 = Test.D(0);
	trace("Test.D(0) == Test.D(0): " + (enum3 == enum4));
	trace("Type.enumEq(Test.D(0), Test.D(0)): " + Type.enumEq(enum3, enum4));

	trace("[1,2,3] == [1,2,3]: " + ([1, 2, 3] == [1, 2, 3]));

	var test = Test2.A(["Hello", "World"]);
	var test2 = Test2.A(["Hello", "World"]);
	trace(Type.enumEq(test, test2));

	final m = "...";
	m = "ajkfd";

	someFuncThatDoesntExist();

	return "Return value";
}

enum Test {
	A;
	B;
	C;
	D(a: Int);
}

enum Test2 {
	A(a: Array<String>);
}
