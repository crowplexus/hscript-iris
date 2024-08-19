package;

using StringTools;

/**
 * Helper class for testing, and benchmarking, made by Ne_Eo and Lunar
**/
class Util {
	public static inline function getTime(): Float {
		return untyped __global__.__time_stamp();
	}

	public static function repeatString(str: String, times: Int): String {
		var result = "";
		for (i in 0...times)
			result += str;
		return result;
	}

	// expandScientificNotation but its WAY too long to write out
	public static function exScienceN(value: Float): String {
		var parts = Std.string(value).split("e");
		var coefficient = Std.parseFloat(parts[0]);
		var exponent = parts.length > 1 ? Std.parseInt(parts[1]) : 0;
		var result = "";

		if (exponent > 0) {
			result += StringTools.replace(Std.string(coefficient), ".", "");
			var decimalLength = Std.string(coefficient).split(".")[1].length;
			var additionalZeros: Int = Std.int(Math.abs(exponent - decimalLength));
			result += repeatString("0", additionalZeros); // repeat
		} else {
			result += "0.";
			var leadingZeros: Int = Std.int(Math.abs(exponent) - 1);
			result += repeatString("0", leadingZeros); // repeat
			result += StringTools.replace(Std.string(coefficient), ".", "");
		}

		return result;
	}

	public static function convertToReadableTime(seconds: Float) {
		if (seconds >= 1)
			return seconds + " s";
		var milliseconds = seconds * 1000; // 1 second = 1,000 ms
		if (milliseconds >= 1)
			return milliseconds + " ms";
		var microseconds = seconds * 1000000; // 1 second = 1,000,000 μs
		if (microseconds >= 1)
			return microseconds + " μs";
		var nanoseconds = seconds * 1000000000; // 1 second = 1,000,000,000 ns
		return nanoseconds + " ns";
	}

	public static function roundDecimal(Value: Float, Precision: Int): Float {
		var mult: Float = 1;
		for (i in 0...Precision)
			mult *= 10;
		return Math.fround(Value * mult) / mult;
	}

	public inline static function roundWith(Value: Float, Mult: Int): Float {
		return Math.fround(Value * Mult) / Mult;
	}

	@:pure static function isJson(s: String) {
		var len = s.length;
		var i = 0;
		while (i < len) {
			var c = StringTools.fastCodeAt(s, i++);
			if (c >= 'a'.code && c <= 'z'.code)
				continue;
			if (c >= 'A'.code && c <= 'Z'.code)
				continue;
			if (c >= '0'.code && c <= '9'.code)
				continue;
			if (c == '_'.code)
				continue;
			return false;
		}
		return true;
	}

	@:pure static inline function isPrintable(c: Int) {
		return c >= 32 && c <= 126;
	}

	@:pure public static function hexLower(n: Int, digits: Int = -1) {
		#if flash
		var n: UInt = n;
		var s: String = untyped n.toString(16);
		s = s.toLowerCase();
		#else
		var s = "";
		var hexChars = "0123456789abcdef";
		do {
			s = hexChars.charAt(n & 15) + s;
			n >>>= 4;
		} while (n > 0);
		#end
		#if python
		if (digits != -1 && s.length < digits) {
			var diff = digits - s.length;
			for (_ in 0...diff)
				s = "0" + s;
		}
		#else
		if (digits != -1)
			while (s.length < digits)
				s = "0" + s;
		#end
		return s;
	}

	@:pure public static function getEscapedString(s: String) {
		var buf = new StringBuf();
		#if target.unicode
		var s = new UnicodeString(s);
		#end
		for (i in 0...s.length) {
			#if target.unicode
			var c: Null<Int> = s.charCodeAt(i);
			#else
			var c: Null<Int> = StringTools.unsafeCodeAt(s, i);
			#end
			switch (c) {
				case '"'.code:
					buf.add('\\"');
				case '\\'.code:
					buf.add('\\\\');
				case '\n'.code:
					buf.add('\\n');
				case '\r'.code:
					buf.add('\\r');
				case '\t'.code:
					buf.add('\\t');
				default:
					if (c == null)
						continue;
					if (isPrintable(c))
						buf.addChar(c);
					else {
						if (c > 0xFF) {
							buf.add("\\u{");
							buf.add(hexLower(c, 2));
							buf.add("}");
						} else {
							buf.add("\\x");
							buf.add(hexLower(c & 0xFF, 2));
						}
					}
			}
		}
		return buf.toString();
	}
}
