package crowplexus.iris.macro;

import Type.ValueType;
import eval.vm.Gc;
import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;
using StringTools;
using haxe.macro.Tools;

/**
 * Macro used for the `using Class;` keyword
 *
 * you can make classes be able to be used by implementing the `IrisUsingClass` interface!
 *
 * ```haxe
 * // @:irisUsableEntry() // optional
 * // @:irisUsableEntry(forceAny) // optional // forces the class to be called with any type
 * // @:irisUsableEntry(onlyBasic) // optional // only basic types will be allowed
 * // @:irisUsableEntry(onlyBasic, forceAny) // optional // only basic types will be allowed, and the class will be called with any type
 * class VeryNiceTools implements crowplexus.iris.macro.IrisUsingClass {}
 * ```
 * @author NeeEoo
**/
class UsingMacro {
	public static function build() {
		var cls: haxe.macro.Type.ClassType = Context.getLocalClass().get();
		var fields = Context.getBuildFields();

		var packName = (cls.pack.length > 0 ? cls.pack.join(".") + "." : "") + cls.name;

		var alreadyProcessed_metadata = cls.meta.get().find(function(m) return m.name == ':irisUsingProcessed');
		if (alreadyProcessed_metadata != null)
			return fields;

		var entryField = cls.meta.get().find(function(m) return m.name == ':irisUsableEntry');
		var hasParams = entryField != null && entryField.params != null;
		var forceAny = false;
		var onlyBasic = false;
		if (hasParams) {
			for (i in 0...entryField.params.length) {
				if (entryField.params[i].expr.match(EConst(CIdent("onlyBasic"))))
					onlyBasic = true;
				if (entryField.params[i].expr.match(EConst(CIdent("forceAny"))))
					forceAny = true;
			}
		}

		var data: Array<Array<String>> = [];

		for (field in fields) {
			// functions marked with @:noUsing won't be able to be used by variables
			if (field.meta.find(function(m) return m.name == ':noUsing') != null)
				continue;
			// if you want it to be usable in source, but not in the script, use @:irisNoUse
			if (field.meta.find(function(m) return m.name == ':irisNoUse') != null)
				continue;

			// if (field.isPublic == false)
			//	continue;

			switch (field.kind) {
				default:
				case FFun(f):
					if (f.args.length == 0)
						continue;
					var arg = f.args[0];
					if (arg.type == null)
						continue;
					var type = arg.type;

					var valueType: String = switch (type) {
						case TPath({name: "Int", pack: []}):
							"TInt";
						case TPath({name: "Float", pack: []}):
							"TFloat";
						case TPath({name: "Single", pack: []}):
							"TFloat";
						case TPath({name: "String", pack: []}):
							"TClass(String)";
						case TPath({name: "Bool", pack: []}):
							"TBool";
						case TPath({name: "Array", pack: []}):
							"TClass(Array)";
						case TPath({name: "Map", pack: []}):
							"TClass(haxe.Constraints.IMap)";
						case TPath({name: "Dynamic", pack: []}):
							null;
						case TPath({name: "Class", pack: []}):
							"TClass(null)"; // this feels wrong
						case TPath({name: "Enum", pack: []}):
							"TEnum(null)";
						// case TPath({name: "Void", pack: []}): "ValueType.TVoid";
						default:
							null; // null acts as a wildcard
					}

					// MIGHT CRASH COMPILATION?
					if (!onlyBasic && valueType == null) {
						var rtype = type.toType();

						switch (rtype) {
							case TInst(t, []):
								valueType = "TClass(" + t.toString() + ")";
							default:
						}
					}

					if (forceAny) {
						valueType = null;
					}

					data.push([field.name, valueType]);
			}
		}

		fields.push({
			name: '__irisUsing_' + packName.replace(".", "_"),
			access: [APrivate, AStatic],
			kind: FVar(macro : Map<String, Type.ValueType>, {
				var arr: Array<Expr> = [];
				for (i in data)
					if (i[1] != null)
						arr.push(macro $v{i[0]} => ${Context.parse("Type.ValueType." + i[1], Context.currentPos())});
					else
						arr.push(macro $v{i[0]} => null);
				macro $a{arr};
			}),
			pos: cls.pos,
		});

		// var printer = new haxe.macro.Printer();
		// trace(printer.printField(fields[fields.length - 1]));

		cls.meta.add(':irisUsingProcessed', [], cls.pos);

		return fields;
	}
}
