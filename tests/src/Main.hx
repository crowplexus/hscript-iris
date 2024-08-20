package;

import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;
import crowplexus.iris.Iris;
import crowplexus.hscript.Parser;
import crowplexus.hscript.Printer;
import crowplexus.hscript.Bytes;

using StringTools;

@:access(crowplexus.iris.Iris)
class Main {
	static function main() {
		mainTest();
		// mainBytes();
		// testIndenticalNames();
	}

	/**
	 * Test main features (i.e: typedefs, enums, etc).
	**/
	static function mainTest() {
		trace("Hello World!");

		var myScript: Iris = new Iris(sys.io.File.getContent("./assets/test.hx"));
		myScript.execute();

		var result = myScript.call("main"); // prints "Hello from Iris!"
		trace(result);

		var printer = new Printer();
		trace(printer.exprToString(myScript.expr));
		// fullTestParseEntireSourceCode()
	}

	/**
	 * Test byte encoding.
	**/
	static function mainBytes() {
		var myScript: Iris = new Iris(sys.io.File.getContent("./assets/bytes.hx"), {
			autoRun: false,
			preset: false,
			name: "bytes"
		});
		myScript.parse();

		var bytes = Bytes.encode(myScript.expr);

		trace(Util.getEscapedString(bytes.toString()));

		// var printer = new Printer();
		// trace(printer.exprToString(myScript.expr));
		// fullTestParseEntireSourceCode()
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
}
