package crowplexus.pscript;

import haxe.ds.StringMap;
import hscript.*;

/**
 * Initialization Rules for a Script
**/
typedef PInitRules = {
	var autoRun:Bool;
	var preset:Bool;
}

/**
 * This basic object helps with the creation of scripts,
 * along with having neat helper functions to initialize and stop scripts
 * 
 * It is highly recommended that you override this class to add custom defualt variables and such.
**/
class PScript {
	/**
	 * Dictionary with stored instances of scripts.
	**/
	public static var instances:StringMap<PScript> = new StringMap<PScript>();

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
	public var ruleSet:PInitRules = null;

	/**
	 * The file path for `this` script.
	**/
	var file:String = "";

	/**
	 * The name of `this` script, trimmed from the `file` string.
	**/
	var scriptName:String = "";

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
	 * Instantiates a new Script with the specified file.
	 * this function automatically checks whether the file exists or not.
	 * 
	 * @param file      the file (preferably with its path, e.g: assets/scripts/myScript.hx)
	 */
	public function new(file:String, ?rules:PInitRules):Void {
		#if !hscript
		throw "[PScript:new()]: Please make sure you have \"hscript\" defined on your project/build file.";
		return;
		#end

		if (rules == null)
			rules = {autoRun: true, preset: true};

		this.file = file;
		this.ruleSet = rules;

		function fileExists():Bool
			return #if sys sys.FileSystem.exists(file) #elseif openfl openfl.utils.Assets.exists(file) #end;

		if (fileExists()) {
			parser = new Parser();
			interp = new Interp();

			parser.allowTypes = true;
			parser.allowMetadata = true;

			if (rules.autoRun)
				execute();
		} else
			trace('[PScript:new()]: Failed to initialize script, File "${file}" does not exist in filesystem.');
	}

	/**
	 * Executes this script
	**/
	public function execute():Void {
		#if !hscript
		throw "[PScript:execute()]: Please make sure you have \"hscript\" defined on your project/build file.";
		return;
		#end

		if (running || interp == null) {
			trace("[PScript:execute()]: " + (interp == null ? interpErrStr + ", Aborting." : "Script is already running!"));
			return;
		}

		final str:String = #if sys sys.io.File.getContent(file) #elseif openfl openfl.utils.Assets.getText(file) #end;
		interp.execute(parser.parseString(str));
		// gonna chane this to also include the extension later, should work for now.
		PScript.instances.set(file.substr(0, file.lastIndexOf(".")), this);
		scriptName = file.substr(0, file.lastIndexOf("."));

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
		#if !hscript
		throw "[PScript:preset()]: Please make sure you have \"hscript\" defined on your project/build file.";
		return;
		#end

		set("Math", Math);
		set("StringTools", StringTools);
	}

	/**
	 * Returns a field from the script.
	 * @param field 	The field that needs to be looked for.
	 */
	public function get(field:String):Dynamic {
		#if !hscript
		throw "[PScript:get()]: Please make sure you have \"hscript\" defined on your project/build file.";
		return false;
		#end

		if (interp == null)
			trace("[PScript:get()]: " + interpErrStr + ", returning false...");
		return interp != null ? interp.variables.get(field) : false;
	}

	/**
	 * Sets a new field to the script
	 * @param name          The name of your new field, scripts will be able to use the field with the name given.
	 * @param value         The value for your new field.
	 * @param allowOverride If set to true, when setting the new field, we will ignore any previously set fields of the same name.
	 */
	public function set(name:String, value:Dynamic, allowOverride:Bool = false):Void {
		#if !hscript
		throw "[PScript:set()]: Please make sure you have \"hscript\" defined on your project/build file.";
		return;
		#end

		if (interp == null) {
			trace("[PScript:set()]: " + interpErrStr + ", so variables cannot be set.");
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
			hPrint("[PScript:set()]: We are sorry, something went terribly wrong, Error: " + e);
	}

	/**
	 * Calls a method on the script
	 * @param fun       The name of the method you wanna call.
	 * @param args      The arguments that the method needs.
	 */
	public function call(fun:String, ?args:Array<Dynamic>):Void {
		#if !hscript
		throw "[PScript:call()]: Please make sure you have \"hscript\" defined on your project/build file.";
		return;
		#end

		if (interp == null) {
			trace("[PScript:call()]: " + interpErrStr + ", so functions cannot be called.");
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
				hPrint("[PScript:call()]: We are sorry, something went terribly wrong, Error: " + e);
		} else
			hPrint("[PScript:call()]: Function \"" + fun + "\" does not exist anywhere in your script.");
	}

	/**
	 * Checks the existance of a field or method within your script.
	 * @param field 		The field to check if exists.
	 */
	public function exists(field:String):Bool {
		if (interp == null)
			trace("[PScript:exists()]: " + interpErrStr + ", returning false...");
		return interp != null ? interp.variables.exists(field) : false;
	}

	/**
	 * Destroys the current instance of this script
	 * along with its parser, and also removes it from the `PScript.instances` dictionary.
	 * 
	 * **WARNING**: this action CANNOT be undone.
	**/
	public function destroy():Void {
		if (PScript.instances.exists(this.file))
			PScript.instances.remove(this.file);

		running = false;
		interp = null;
		parser = null;
	}

	/**
	 * Destroys every single script found within the `PScript.instances` dictionary.
	 * 
	 * **WARNING**: this action CANNOT be undone.
	**/
	public static function destroyAll():Void {
		for (key in PScript.instances.keys()) {
			if (PScript.instances.get(key) == null)
				continue;
			PScript.instances.get(key).destroy();
		}
	}

	@:noCompletion // not doing "@:noPrivateAccess" for the sake of letting people override this
	/**
	 * Special print function for Scripts.
	 * @param v 	Defines what to print to the console.
	 */
	private function hPrint(v):Void {
		#if sys Sys.print #else trace #end ('[${scriptName}:${interp.posInfos().lineNumber}]: ${v}\n');
	}
}