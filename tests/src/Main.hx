package;

import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;
import crowplexus.iris.Iris;
import crowplexus.hscript.Parser;
import crowplexus.hscript.Printer;
import crowplexus.hscript.Bytes;
import haxe.Resource;

using StringTools;

@:access(crowplexus.iris.Iris)
class Main {
	static function main() {
		// mainTest();
		// mainBytes();
		// testIndenticalNames();
		// testStringInterpolation();
		// fullTestParseEntireSourceCode();
		// testUsing();
		testBind();
	}

	/**
	 * Test main features (i.e: typedefs, enums, etc).
	**/
	static function mainTest() {
		trace("Hello World!");

		var myScript: Iris = new Iris(Resource.getString("assets/test.hx"));
		myScript.execute();

		var result = myScript.call("main"); // prints "Hello from Iris!"
		trace(result);

		var printer = new Printer();
		// trace(printer.exprToString(myScript.expr));
		// fullTestParseEntireSourceCode()

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

		var result = myScript.call("non existent function");
		trace(result);
	}

	/**
	 * Test byte encoding.
	**/
	static function mainBytes() {
		var myScript: Iris = new Iris(Resource.getString("assets/bytes.hx"), {
			autoRun: false,
			autoPreset: false,
			name: "bytes"
		});
		myScript.parse();

		var bytes = Bytes.encode(myScript.expr);

		trace(Util.getEscapedString(bytes.toString()));

		// var printer = new Printer();
		// trace(printer.exprToString(myScript.expr));
	}

	/*
	 * Test identical names, scripts that have indentical names will have a
	 * number appended to their name according to its copy id.
	**/
	static function testIndenticalNames() {
		var script = new Iris('trace("Hello World!");', {name: "script"}).execute();
		var script2 = new Iris('trace("A!");', {name: "script"}).execute();
		var script3 = new Iris('trace("B!");', {name: "script"}).execute();
		var script4 = new Iris('trace("C!");', {name: "script"}).execute();
		trace(Iris.instances);
	}

	public static function fullTestParseEntireSourceCode() {
		var hxfiles = [];

		function recursiveFinder(path: String) {
			var files = FileSystem.readDirectory(path);
			for (file in files) {
				var filePath = Path.join([path, file]);
				if (FileSystem.isDirectory(filePath)) {
					recursiveFinder(filePath);
				} else if (file.endsWith(".hx")) {
					hxfiles.push(filePath);
				}
			}
		}

		var root = Path.join([Sys.getCwd(), "..", "..", ".."]);

		recursiveFinder(root);
		for (file in hxfiles) {
			Sys.println(file);
			var parser = new Parser();
			var tokens = parser.parseString(File.getContent(file));
			trace(tokens);
		}
	}

	/**
	 * Test for HScript Using keyword
	 */
	static function testUsing() {
		var myScript: Iris = new Iris(Resource.getString("assets/using.hx"), {
			name: "using",
			autoRun: false
		});
		myScript.execute();
		myScript.call("main");
	}

	/**
	 * Test for string interpolation in HScript.
	**/
	static function testStringInterpolation() {
		function testFile() { // FILE TEST
			trace('Testing String Interpolation, with a file');
			var file: String = sys.io.File.getContent("./assets/strings.hx");
			var script: Iris = new Iris(file, {name: "StringInterpolationTest"});
			script.call("main", []);
		}
		function testPureString() { // STRING TEST
			trace('...With a pure string');
			var source: String = "function main() {
				trace('Program Start!');

				var hello = 'Hello!';

				trace('test 1, basic interpolation: $hello');
				var tally = {
					score: 10,
					hits: 5,
					misses: 0,
				};
				var stats = 'Score:${tally.score}';
				trace('test 2, bracket interpolation: $stats');
				stats = 'Score:${tally.score} - Hits:${tally.hits} - Misses:${tally.misses}';
				trace('test 3, bracket interpolation with multiple strings: $stats');

				trace('test 4, escaped interpolation: $${caw}');

				trace('test 5, nested interpolation: ${'${tally.score}'}');
			}";
			var source: Iris = new Iris(source, {name: "StringInterpolationTestSource", autoRun: false});
			source.execute();
			source.call("main", []);
		}
	}

	/**
	 * Test for Hscript - function.bind()
	 */
	static function testBind() {
		var myScript: Iris = new Iris(Resource.getString("assets/bind.hx"), {
			name: "bind",
			autoRun: false
		});
		myScript.execute();
		myScript.call("main");
	}
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
