package;

using StringTools;

/**
 * Helper class for testing, and benchmarking, made by Ne_Eo and Lunar
**/
class Util {
	public static inline function getTime():Float {
		return untyped __global__.__time_stamp();
	}

	public static function repeatString(str:String, times:Int):String {
		var result = "";
		for (i in 0...times)
			result += str;
		return result;
	}

	// expandScientificNotation but its WAY too long to write out
	public static function exScienceN(value:Float):String {
		var parts = Std.string(value).split("e");
		var coefficient = Std.parseFloat(parts[0]);
		var exponent = parts.length > 1 ? Std.parseInt(parts[1]) : 0;
		var result = "";

		if (exponent > 0) {
			result += StringTools.replace(Std.string(coefficient), ".", "");
			var decimalLength = Std.string(coefficient).split(".")[1].length;
			var additionalZeros:Int = Std.int(Math.abs(exponent - decimalLength));
			result += repeatString("0", additionalZeros); // repeat
		} else {
			result += "0.";
			var leadingZeros:Int = Std.int(Math.abs(exponent) - 1);
			result += repeatString("0", leadingZeros); // repeat
			result += StringTools.replace(Std.string(coefficient), ".", "");
		}

		return result;
	}

	public static function convertToReadableTime(seconds:Float) {
		if (seconds >= 1) return seconds + " s";
		var milliseconds = seconds * 1000;       // 1 second = 1,000 ms
		if (milliseconds >= 1) return milliseconds + " ms";
		var microseconds = seconds * 1000000;   // 1 second = 1,000,000 μs
		if (microseconds >= 1) return microseconds + " μs";
		var nanoseconds = seconds * 1000000000; // 1 second = 1,000,000,000 ns
		return nanoseconds + " ns";
	}

	public static function roundDecimal(Value:Float, Precision:Int):Float {
		var mult:Float = 1;
		for (i in 0...Precision)
			mult *= 10;
		return Math.fround(Value * mult) / mult;
	}

	public inline static function roundWith(Value:Float, Mult:Int):Float {
		return Math.fround(Value * Mult) / Mult;
	}
}
