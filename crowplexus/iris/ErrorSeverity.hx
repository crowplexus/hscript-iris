package crowplexus.iris;

import crowplexus.iris.utils.Ansi;

/**
 * Declares the severity of an error,
 * adds a little prefix to printing showing which kind of failure it is
**/
enum ErrorSeverity {
	NONE;
	WARN;
	ERROR;
	FATAL;
}

class ErrorSeverityTools implements crowplexus.iris.IrisUsingClass {
	public static function getPrefix(severity: ErrorSeverity): String {
		return switch (severity) {
			case NONE: "";
			// case WARN: "WARN ";
			// case ERROR: "ERROR";
			// case FATAL: "FATAL";
			case null: "UNKNOWN";
			case _: Type.enumConstructor(severity);
		}
	}

	public static function getColor(severity: ErrorSeverity): AnsiColor {
		return switch (severity) {
			case NONE: AnsiColor.DEFAULT;
			case WARN: AnsiColor.YELLOW;
			case ERROR: AnsiColor.RED;
			case FATAL: AnsiColor.RED;
			case _: AnsiColor.DEFAULT;
		}
	}
}
