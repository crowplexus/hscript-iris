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
	}

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
