package crowplexus.iris.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

/**
 * Based on CodenameCrew's DefinesMacro.hx
 */
class DefineMacro {
	/**
	 * Contains defined values in the source
	**/
	public static var defines(get, never): Map<String, Dynamic>;

	private static function get_defines() {
		return getDefines();
	}

	#if macro
	public static macro function getDefines(): Expr {
		return macro $v{#if display [] #else Context.getDefines() #end};
	}
	#else
	public static macro function getDefines(): Expr;
	#end
}
