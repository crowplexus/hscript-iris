package crowplexus.iris;

import haxe.ds.StringMap;
import crowplexus.hscript.*;

/**
 * Initialization Rules for a Script
**/
typedef InitRules = {
	var name:String;
	var autoRun:Bool;
	var preset:Bool;
}

/**
 * This basic object helps with the creation of scripts,
 * along with having neat helper functions to initialize and stop scripts
 * 
 * It is highly recommended that you override this class to add custom defualt variables and such.
**/
class Iris {
	/**
	 * Dictionary with stored instances of scripts.
	**/
	public static var instances:StringMap<Iris> = new StringMap<Iris>();

	/**
	 * Script Extensions that should be used to look for script files and execute them.
	**/
	public static var extensions:Array<String> = [".hx"];

	/**
	 * Checks if `this` script is running
	**/
	public var running:Bool = false;

	/**
	 * The current initialization rules for `this` script.
	**/
	public var ruleSet:InitRules = null;

	/**
	 * The script string  for `this` script.
	 * 
	 * contains a full haxe script instance
	**/
	var scriptStr:String = "";

	/**
	 * Current initialized script interpreter.
	**/
	var interp:Interp;

	/**
	 * Current initialized script parser.
	**/
	var parser:Parser;

	/**
	 * Helper variable for the error string caused by a nulled interpreter.
	**/
	final interpErrStr:String = "Careful, the interpreter hasn't been initialized";

	/**
	 * Instantiates a new Script with the string value.
	 * 
	 * @param scriptStr      the script to be parsed, e.g:
	 * ```haxe
	 * function hi() {
	 * 		trace("Hello World!");
	 * }
	 * ```
	 */
	public function new(scriptStr:String, ?rules:InitRules):Void {
		if (rules == null)
			rules = {name: "iris", autoRun: true, preset: true};

		this.scriptStr= scriptStr;
		this.ruleSet = rules;

		parser = new Parser();
		interp = new Interp();

		parser.allowTypes = true;
		parser.allowMetadata = true;

		if (rules.autoRun)
			execute();
	}

	/**
	 * Executes this script
	**/
	public function execute():Void {
		if (running || interp == null) {
			trace("[Iris:execute()]: " + (interp == null ? interpErrStr + ", Aborting." : "Script is already running!"));
			return;
		}

		interp.execute(parser.parseString(scriptStr));
		// gonna chane this to also include the extension later, should work for now.
		Iris.instances.set(ruleSet.name, this);

		#if hscriptPos
		// overriding trace for good measure.
		set("trace", hPrint, true);
		#end

		if (ruleSet.preset)
			preset();

		running = true;
	}

	/**
	 * Appends Default Classes/Enums for the Script to use.
	**/
	public function preset():Void {
		set("Math", Math);
		set("StringTools", StringTools);
	}

	/**
	 * Returns a field from the script.
	 * @param field 	The field that needs to be looked for.
	 */
	public function get(field:String):Dynamic {
		if (interp == null)
			trace("[Iris:get()]: " + interpErrStr + ", returning false...");
		return interp != null ? interp.variables.get(field) : false;
	}

	/**
	 * Sets a new field to the script
	 * @param name          The name of your new field, scripts will be able to use the field with the name given.
	 * @param value         The value for your new field.
	 * @param allowOverride If set to true, when setting the new field, we will ignore any previously set fields of the same name.
	 */
	public function set(name:String, value:Dynamic, allowOverride:Bool = false):Void {
		if (interp == null) {
			trace("[Iris:set()]: " + interpErrStr + ", so variables cannot be set.");
			return;
		}

		try {
			if (allowOverride)
				interp.variables.set(name, value);
			else {
				if (!interp.variables.exists(name))
					interp.variables.set(name, value);
			}
		} catch (e:haxe.Exception)
			hPrint("[Iris:set()]: We are sorry, something went terribly wrong, Error: " + e);
	}

	/**
	 * Calls a method on the script
	 * @param fun       The name of the method you wanna call.
	 * @param args      The arguments that the method needs.
	 */
	public function call(fun:String, ?args:Array<Dynamic>):Void {
		if (interp == null) {
			trace("[Iris:call()]: " + interpErrStr + ", so functions cannot be called.");
			return;
		}

		if (args == null)
			args = [];

		// fun-ny
		var ny:Dynamic = interp.variables.get(fun);
		if (ny != null && Reflect.isFunction(ny)) {
			try {
				Reflect.callMethod(null, interp.variables.get(fun), args);
			} catch (e:haxe.Exception)
				hPrint("[Iris:call()]: We are sorry, something went terribly wrong, Error: " + e);
		} else
			hPrint("[Iris:call()]: Function \"" + fun + "\" does not exist anywhere in your script.");
	}

	/**
	 * Checks the existance of a field or method within your script.
	 * @param field 		The field to check if exists.
	 */
	public function exists(field:String):Bool {
		if (interp == null)
			trace("[Iris:exists()]: " + interpErrStr + ", returning false...");
		return interp != null ? interp.variables.exists(field) : false;
	}

	/**
	 * Destroys the current instance of this script
	 * along with its parser, and also removes it from the `Iris.instances` dictionary.
	 * 
	 * **WARNING**: this action CANNOT be undone.
	**/
	public function destroy():Void {
		if (Iris.instances.exists(ruleSet.name))
			Iris.instances.remove(ruleSet.name);

		running = false;
		interp = null;
		parser = null;
	}

	/**
	 * Destroys every single script found within the `Iris.instances` dictionary.
	 * 
	 * **WARNING**: this action CANNOT be undone.
	**/
	public static function destroyAll():Void {
		for (key in Iris.instances.keys()) {
			if (Iris.instances.get(key) == null)
				continue;
			Iris.instances.get(key).destroy();
		}
	}

	@:noCompletion // not doing "@:noPrivateAccess" for the sake of letting people override this
	/**
	 * Special print function for Scripts.
	 * @param v 	Defines what to print to the console.
	 */
	private function hPrint(v):Void {
		#if sys Sys.print #else trace #end ('[${ruleSet.name}:${interp.posInfos().lineNumber}]: ${v}\n');
	}
}
