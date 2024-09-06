package crowplexus.iris;

import haxe.ds.StringMap;
import crowplexus.hscript.*;

/**
 * Initialization Rules for a Script
**/
@:structInit
class InitRules {
	public var name: String = "";
	public var autoRun: Bool = true;
	public var preset: Bool = true;
}

/**
 * This basic object helps with the creation of scripts,
 * along with having neat helper functions to initialize and stop scripts
 *
 * It is highly recommended that you override this class to add custom defualt variables and such.
**/
class Iris {
	/**
	 * Map with stored instances of scripts.
	**/
	public static var instances: StringMap<Iris> = new StringMap<Iris>();

	///**
	// * Checks if `this` script is running
	//**/
	//public var running: Bool = false;

	/**
	 * The current initialization rules for `this` script.
	**/
	public var ruleSet: InitRules = null;

	/**
	 * The code passed in the `new` function for this script.
	 *
	 * contains a full haxe script instance
	**/
	var scriptCode: String = "";

	/**
	 * Current initialized script interpreter.
	**/
	var interp: Interp;

	/**
	 * Current initialized script parser.
	**/
	var parser: Parser;

	/**
	 * Current initialized script expression.
	**/
	var expr: Expr;

	/**
	 * Helper variable for the error string caused by a nulled interpreter.
	**/
	final interpErrStr: String = "Careful, the interpreter hasn't been initialized";

	/**
	 * Instantiates a new Script with the string value.
	 *
	 * ```haxe
	 * trace("Hello World!");
	 * ```
	 * will trace "Hello World!" to the standard output.
	 * @param scriptCode      the script to be parsed, e.g:
	 */
	public function new(scriptCode: String, ?rules: InitRules): Void {
		if (rules == null)
			rules = {name: "Iris", autoRun: true, preset: true};

		this.scriptCode = scriptCode;
		this.ruleSet = rules;

		parser = new Parser();
		interp = new Interp();

		parser.allowTypes = true;
		parser.allowMetadata = true;
		parser.allowJSON = true;
		fixScriptName(rules.name);
		// set variables to the interpreter.
		if (ruleSet.preset)
			preset();
		// run the script.
		if (rules.autoRun)
			execute();
	}

	private function fixScriptName(defaultName: String): Void {
		// make sure to never have an indentically named instance.
		var copyID: Int = 1;
		while (Iris.instances.exists(ruleSet.name)) {
			ruleSet.name = defaultName + "_" + copyID;
			copyID += 1;
		}
	}

	/**
	 * Executes this script and returns it.
	**/
	public function execute(): Iris {
		if (/*running ||*/ interp == null) {
			#if IRIS_DEBUG
			trace("[Iris:execute()]: " + (interp == null ? interpErrStr + ", Aborting." : "Script " + ruleSet.name + " is already running!"));
			#end
			return this;
		}

		Iris.instances.set(ruleSet.name, this);

		if (expr == null)
			expr = parse();
		interp.execute(expr);
		// running = Iris.instances.exists(ruleSet.name);

		return this;
	}

	public function parse() {
		/*
		if (running)
			return expr;
		*/
		if (expr != null)
			return expr;
		return expr = parser.parseString(scriptCode);
	}

	/**
	 * Appends Default Classes/Enums for the Script to use.
	**/
	public function preset(): Void {
		set("Std", Std);
		set("Math", Math);
		set("StringTools", StringTools);
		#if hscriptPos
		// overriding trace for good measure.
		set("trace", irisPrint, true);
		#end
	}

	/**
	 * Returns a field from the script.
	 * @param field 	The field that needs to be looked for.
	 */
	public function get(field: String): Dynamic {
		#if IRIS_DEBUG
		if (interp == null)
			trace("[Iris:get()]: " + interpErrStr + ", returning false...");
		#end
		return interp != null ? interp.variables.get(field) : false;
	}

	/**
	 * Sets a new field to the script
	 * @param name          The name of your new field, scripts will be able to use the field with the name given.
	 * @param value         The value for your new field.
	 * @param allowOverride If set to true, when setting the new field, we will ignore any previously set fields of the same name.
	 */
	public function set(name: String, value: Dynamic, allowOverride: Bool = true): Void {
		if (interp == null) {
			#if IRIS_DEBUG
			trace("[Iris:set()]: " + interpErrStr + ", so variables cannot be set.");
			#end
			return;
		}

		try {
			if (allowOverride || !interp.variables.exists(name))
				interp.variables.set(name, value);
		} catch (e:haxe.Exception) {
			#if IRIS_DEBUG
			irisPrint("[Iris:set()]: We are sorry, something went terribly wrong, Error: " + e);
			#end
		}
	}

	/**
	 * Calls a method on the script
	 * @param fun       The name of the method you wanna call.
	 * @param args      The arguments that the method needs.
	 */
	public function call(fun: String, ?args: Array<Dynamic>): Dynamic {
		if (interp == null) {
			#if IRIS_DEBUG
			trace("[Iris:call()]: " + interpErrStr + ", so functions cannot be called.");
			#end
			return 0;
		}

		if (args == null)
			args = [];

		// fun-ny
		var ny: Dynamic = interp.variables.get(fun);
		if (ny != null && Reflect.isFunction(ny)) {
			try {
				final ret = Reflect.callMethod(null, ny, args);
				return {methodName: fun, methodReturn: ny, methodVal: ret}
			} catch (e:haxe.Exception) {
				#if IRIS_DEBUG
				irisPrint("[Iris:call()]: We are sorry, something went terribly wrong, Error: " + e);
				#end
			}
		}
		return 0;
	}

	/**
	 * Checks the existance of a field or method within your script.
	 * @param field 		The field to check if exists.
	 */
	public function exists(field: String): Bool {
		#if IRIS_DEBUG
		if (interp == null)
			trace("[Iris:exists()]: " + interpErrStr + ", returning false...");
		#end
		return (interp != null) ? interp.variables.exists(field) : false;
	}

	/**
	 * Destroys the current instance of this script
	 * along with its parser, and also removes it from the `Iris.instances` map.
	 *
	 * **WARNING**: this action CANNOT be undone.
	**/
	public function destroy(): Void {
		if (Iris.instances.exists(ruleSet.name))
			Iris.instances.remove(ruleSet.name);

		// running = false;
		interp = null;
		parser = null;
		ruleSet = null;
	}

	/**
	 * Destroys every single script found within the `Iris.instances` map.
	 *
	 * **WARNING**: this action CANNOT be undone.
	**/
	public static function destroyAll(): Void {
		for (key in Iris.instances.keys()) {
			if (Iris.instances.get(key).interp == null)
				continue;
			Iris.instances.get(key).destroy();
		}
	}

	/**
	 * Special print function for Scripts.
	 * @param v 	Defines what to print to the console.
	 */
	inline function irisPrint(v): Void {
		Sys.println('[${ruleSet.name}:${interp.posInfos().lineNumber}]: ${v}');
	}
}
