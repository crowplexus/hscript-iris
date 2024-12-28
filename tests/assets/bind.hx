function main() {
	trace("Hello World!");

	function test(a: Int, b: Int) {
		trace(a + b);
	}

	var test2 = test.bind(1, _);
	test2(2);

	var test3 = test.bind(1, _);
	test3(2);

	var test4 = test.bind(_, 2);
	test4(1);

	var test5 = test.bind(_, _);
	test5(1, 2);

	try {
		var test5 = test.bind(_, 4);
		test5();
		trace("Should have thrown an error");
	} catch (e:Dynamic) {
		trace(e);
	}
}
