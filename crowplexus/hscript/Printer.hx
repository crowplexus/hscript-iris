/*
 * Copyright (C)2008-2017 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package crowplexus.hscript;

import crowplexus.hscript.Expr;

class Printer {
	var buf: StringBuf;
	var tabs: String;

	var indent: String = "  ";

	public function new() {}

	public function exprToString(e: Expr) {
		buf = new StringBuf();
		tabs = "";
		expr(e);
		return buf.toString();
	}

	public function typeToString(t: CType) {
		buf = new StringBuf();
		tabs = "";
		type(t);
		return buf.toString();
	}

	inline function add<T>(s: T)
		buf.add(s);

	public function typePath(tp: TypePath) {
		add(tp.pack.join("."));
		if (tp.pack.length > 0)
			add(".");
		add(tp.name);
		add((tp.sub != null && tp.sub.length > 0) ? "." + tp.sub : "");
		if (tp.params != null && tp.params.length > 0) {
			add("<");
			var first = true;
			for (p in tp.params) {
				if (first)
					first = false
				else
					add(", ");
				type(p);
			}
			add(">");
		}
	}

	function type(t: CType) {
		switch (t) {
			case CTOpt(t):
				add('?');
				type(t);
			case CTPath(path):
				typePath(path);
			case CTNamed(name, t):
				add(name);
				add(':');
				type(t);
			case CTFun(args, ret) if (Lambda.exists(args, function(a) return a.match(CTNamed(_, _)))):
				add('(');
				for (a in args)
					switch a {
						case CTNamed(_, _): type(a);
						default: type(CTNamed('_', a));
					}
				add(')->');
				type(ret);
			case CTFun(args, ret):
				if (args.length == 0)
					add("Void -> ");
				else {
					for (a in args) {
						type(a);
						add(" -> ");
					}
				}
				type(ret);
			case CTAnon(fields):
				add("{");
				var first = true;
				for (f in fields) {
					if (first) {
						first = false;
						add(" ");
					} else
						add(", ");
					add(f.name + " : ");
					type(f.t);
				}
				add(first ? "}" : " }");
			case CTParent(t):
				add("(");
				type(t);
				add(")");
			case CTExtend(t, fields):
				add("{");
				var first = true;
				for (f in t) {
					if (first) {
						first = false;
						add(" ");
					} else
						add(", ");
					typePath(f);
				}
				var first = true;
				for (f in fields) {
					if (first) {
						first = false;
						add(" ");
					} else
						add(", ");
					add(f.name + " : ");
					type(f.t);
				}
				add(first ? "}" : " }");
			case CTIntersection(types):
				for (i => t in types) {
					type(t);
					if (i < types.length - 1)
						add(" & ");
				}
		}
	}

	function addType(t: CType) {
		if (t != null) {
			add(" : ");
			type(t);
		}
	}

	function addArgument(a: Argument) {
		if (a.opt)
			add("?");
		add(a.name);
		addType(a.t);
	}

	function expr(e: Expr) {
		if (e == null) {
			add("??NULL??");
			return;
		}
		switch (Tools.expr(e)) {
			case EIgnore(_):
			case EConst(c):
				switch (c) {
					case CInt(i): add(i);
					case CFloat(f): add(f);
					case CString(s):
						add('"');
						add(s.split('"')
							.join('\\"')
							.split("\n")
							.join("\\n")
							.split("\r")
							.join("\\r")
							.split("\t")
							.join("\\t"));
						add('"');
				}
			case EIdent(v):
				add(v);
			case EVar(n, t, e, c):
				if (c) {
					add("final " + n);
				} else {
					add("var " + n);
				}
				addType(t);
				if (e != null) {
					add(" = ");
					expr(e);
				}
			case EParent(e):
				add("(");
				expr(e);
				add(")");
			case EBlock(el):
				if (el.length == 0) {
					add("{}");
					return;
				}

				incrementIndent();
				add("{\n");
				for (e in el) {
					add(tabs);
					expr(e);
					add(";\n");
				}
				decrementIndent();
				add(tabs);
				add("}");
			case EField(e, f, s):
				expr(e);
				if (s) {
					add("?." + f);
				} else {
					add("." + f);
				}
			case EBinop(op, e1, e2):
				expr(e1);
				add(" " + op + " ");
				expr(e2);
			case EUnop(op, pre, e):
				if (pre) {
					add(op);
					expr(e);
				} else {
					expr(e);
					add(op);
				}
			case ECall(e, args):
				if (e == null)
					expr(e);
				else
					switch (Tools.expr(e)) {
						case EField(_), EIdent(_), EConst(_):
							expr(e);
						default:
							add("(");
							expr(e);
							add(")");
					}
				add("(");
				var first = true;
				for (a in args) {
					if (first)
						first = false
					else
						add(", ");
					expr(a);
				}
				add(")");
			case EIf(cond, e1, e2):
				add("if( ");
				expr(cond);
				add(" ) ");
				expr(e1);
				if (e2 != null) {
					add(" else ");
					expr(e2);
				}
			case EWhile(cond, e):
				add("while( ");
				expr(cond);
				add(" ) ");
				expr(e);
			case EDoWhile(cond, e):
				add("do ");
				expr(e);
				add(" while ( ");
				expr(cond);
				add(" )");
			case EFor(v, it, e):
				add("for( " + v + " in ");
				expr(it);
				add(" ) ");
				expr(e);
			case EBreak:
				add("break");
			case EContinue:
				add("continue");
			case EFunction(params, e, name, ret):
				add("function");
				if (name != null)
					add(" " + name);
				add("(");
				var first = true;
				for (a in params) {
					if (first)
						first = false
					else
						add(", ");
					addArgument(a);
				}
				add(")");
				addType(ret);
				add(" ");
				expr(e);
			case EReturn(e):
				add("return");
				if (e != null) {
					add(" ");
					expr(e);
				}
			case EImport(v, as):
				add("import " + v);
				if (as != null)
					add(" as " + as);
			case EArray(e, index):
				expr(e);
				add("[");
				expr(index);
				add("]");
			case EArrayDecl(el):
				add("[");
				var first = true;
				for (e in el) {
					if (first)
						first = false
					else
						add(", ");
					expr(e);
				}
				add("]");
			case ENew(cl, args):
				add("new " + cl + "(");
				var first = true;
				for (e in args) {
					if (first)
						first = false
					else
						add(", ");
					expr(e);
				}
				add(")");
			case EThrow(e):
				add("throw ");
				expr(e);
			case ETry(e, v, t, ecatch):
				add("try ");
				expr(e);
				add(" catch( " + v);
				addType(t);
				add(") ");
				expr(ecatch);
			case EObject(fl):
				if (fl.length == 0) {
					add("{}");
					return;
				}
				incrementIndent();
				add("{\n");
				for (i => f in fl) {
					add(tabs);
					add(f.name + " : ");
					expr(f.e);
					if (i < fl.length - 1)
						add(",");
					add("\n");
				}
				decrementIndent();
				add(tabs);
				add("}");
			case ETernary(c, e1, e2):
				expr(c);
				add(" ? ");
				expr(e1);
				add(" : ");
				expr(e2);
			case ESwitch(e, cases, def):
				add("switch");
				expr(e);
				add(" {");
				incrementIndent();
				for (c in cases) {
					add("\n");
					add(tabs);
					add("case ");
					var first = true;
					for (v in c.values) {
						if (first)
							first = false
						else
							add(", ");
						expr(v);
					}
					add(": ");
					expr(c.expr);
					add(";");
				}
				if (def != null) {
					add("\n");
					add(tabs);
					add("default: ");
					expr(def);
					add(";");
				}
				decrementIndent();
				if (cases.length > 0) {
					add("\n");
					add(tabs);
				}
				add("}");
			case EMeta(name, args, e):
				add("@");
				add(name);
				if (args != null && args.length > 0) {
					add("(");
					var first = true;
					for (a in args) {
						if (first)
							first = false
						else
							add(", ");
						expr(e);
					}
					add(")");
				}
				add(" ");
				expr(e);
			case ECheckType(e, t):
				add("(");
				expr(e);
				add(" : ");
				addType(t);
				add(")");
			case EEnum(name, params):
				if (params.length == 0) {
					add("enum " + name + " {}");
					return;
				}
				add("enum " + name + " {\n");
				incrementIndent();
				for (p in params) {
					add(tabs);
					switch p {
						case EConstructor(name, args):
							add(name);
							add("(");
							for (a in args)
								addArgument(a);
							add(")");
						case ESimple(name):
							add(name);
					}
					add(";\n");
				}
				decrementIndent();
				add(tabs);
				add("}");
			case EDirectValue(value):
				add("<Internal Value " + value + ">");
			case EUsing(name):
				add("using ");
				add(name);
		}
	}

	inline function incrementIndent() {
		tabs += indent;
	}

	inline function decrementIndent() {
		tabs = tabs.substr(indent.length);
	}

	public static function toString(e: Expr) {
		return new Printer().exprToString(e);
	}

	public static function errorToString(e: Expr.Error, showPos: Bool = true) {
		var message = switch (#if hscriptPos e.e #else e #end) {
			case EInvalidChar(c): "Invalid character: '" + (StringTools.isEof(c) ? "EOF" : String.fromCharCode(c)) + "' (" + c + ")";
			case EUnexpected(s): "Unexpected token: \"" + s + "\"";
			case EUnterminatedString: "Unterminated string";
			case EUnterminatedComment: "Unterminated comment";
			case EInvalidPreprocessor(str): "Invalid preprocessor (" + str + ")";
			case EUnknownVariable(v): "Unknown variable: " + v;
			case EInvalidIterator(v): "Invalid iterator: " + v;
			case EInvalidOp(op): "Invalid operator: " + op;
			case EInvalidAccess(f): "Invalid access to field " + f;
			case ECustom(msg): msg;
			default: "Unknown Error.";
		};
		#if hscriptPos
		if (showPos)
			return e.origin + ":" + e.line + ": " + message;
		else
			return message;
		#else
		return message;
		#end
	}
}
