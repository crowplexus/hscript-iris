final test = "Iris";

trace("Top level " + test);
function main() {
	// test = "Lua"; // should error
	trace("Hello from " + test);

	final enumTest = Test.A;
	final enumTestTwo = Test.D(0);
	trace("Enum Value A: " + enumTest);
	trace("Enum Value D: " + enumTestTwo);

	return "Return value";
}

enum Test {
	A;
	B;
	C;
	D(a: Int);
}
