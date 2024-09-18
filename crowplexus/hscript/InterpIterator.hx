package crowplexus.hscript;

/**
 * Fixes For Loop integer iterators.
**/
@:keepSub
@:access(crowplexus.hscript.Interp)
class InterpIterator {
	public var min: Int;
	public var max: Int;

	public inline function new(instance: Interp, expr1: Expr, expr2: Expr) {
		var min: Dynamic = instance.expr(expr1);
		var max: Dynamic = instance.expr(expr2);

		if (min == null)
			instance.error(ECustom('null should be Int'));
		if (max == null)
			instance.error(ECustom('null should be Int'));

		if (Std.isOfType(min, Float) && !Std.isOfType(min, Int))
			instance.error(ECustom('Float should be Int'));
		if (Std.isOfType(max, Float) && !Std.isOfType(max, Int))
			instance.error(ECustom('Float should be Int'));

		if (!Std.isOfType(min, Int))
			instance.error(ECustom('${Type.getClassName(Type.getClass(min))} should be Int'));
		if (!Std.isOfType(max, Int))
			instance.error(ECustom('${Type.getClassName(Type.getClass(max))} should be Int'));

		this.min = min;
		this.max = max;
	}

	public inline function hasNext(): Bool {
		return min < max;
	}

	public inline function next(): Int {
		return min++;
	}
}
