package tests;

// using test.world.Meow;
using Util; // woo to recycling!

function main() {
	try {
		"hello world".contains("hello");
		trace("StringTools.contains should have thrown an error");
	} catch (e:Dynamic) {}
	
	using StringTools;
	try {
		"hello world".contains("hello");
	} catch (e:Dynamic) {
		trace("StringTools.contains threw an error");
	}
	
	try {
		"hello world".hex(6);
		trace("StringTools.hex should have thrown an error");
	} catch (e:Dynamic) {}
	
	try {
		0xFF0000.hex(6);
	} catch (e:Dynamic) {
		trace("StringTools.hex threw an error");
	}

	trace('i am going to die');
	
	trace('StringTools.startsWith("hello world", "hello")', StringTools.startsWith("hello world", "hello"));
	trace('"hello world".startsWith("hello")', "hello world".startsWith("hello"));

	trace('StringTools.hex(0xFF0000)', StringTools.hex(0xFF0000));
	trace('0xFF0000.hex()', 0xFF0000.hex());

	trace('StringTools.hex(0xFF00, 6)', StringTools.hex(0xFF00, 6));
	trace('0x00ff00.hex(6)', 0x00ff00.hex(6));

	trace('StringTools.contains("hello world", "hello")', StringTools.contains("hello world", "hello"));
	trace('"hello world".contains("hello")', "hello world".contains("hello"));
	
	// Util test
	
	trace('Util.repeatString("abc", 5)', Util.repeatString("abc", 5));
	trace('"abc".repeatString(5)', "abc".repeatString(5));

	// Lambda
	
	try {
		var result = [1, 2, 3].findIndex(function(v) return v == 2);
		trace("Lambda.findIndex should have thrown an error");
	} catch (e:Dynamic) {}

	using Lambda;

	try {
		var result = [1, 2, 3].findIndex(function(v) return v == 2);
	} catch (e:Dynamic) {
		trace("Lambda.findIndex threw an error");
	}
	
	try {
		var result = "hello world".find(function(v) return v > 10);
		trace("Lambda.find should have thrown an error");
	} catch (e:Dynamic) {}
	
	try {
		var result = [1, 2, 3].find(function(v) return v > 10);
	} catch (e:Dynamic) {
		trace("Lambda.find threw an error");
	}
}
