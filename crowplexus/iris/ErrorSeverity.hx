package crowplexus.iris;

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

class ErrorSeverityTools {
	public static function getErrorSeverityPrefix(severity: ErrorSeverity): String {
		return switch (severity) {
			case NONE: "";
			// case WARN: "WARN ";
			// case ERROR: "ERROR";
			// case FATAL: "FATAL";
			case null: "UNKNOWN";
			case _: Type.enumConstructor(severity);
		}
	}
}
