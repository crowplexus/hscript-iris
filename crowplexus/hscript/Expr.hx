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

import crowplexus.hscript.Types.ByteUInt;

enum Const {
	CInt(v: Int);
	CFloat(f: Float);
	CString(s: String);
	#if !haxe3
	CInt32(v:haxe.Int32);
	#end
}

#if hscriptPos
@:structInit
class Expr {
	public var e: ExprDef;
	public var pmin: Int;
	public var pmax: Int;
	public var origin: String;
	public var line: Int;

	public function toString(): String {
		return Std.string({
			e: e,
			pmin: pmin,
			pmax: pmax,
			origin: origin,
			line: line
		});
	}
}

enum ExprDef
#else
typedef ExprDef = Expr;

enum Expr
#end
{
	EIgnore(skipSemicolon:Bool);
	EConst(c:Const);
	EIdent(v:String);
	EImport(v:String, as:String);
	EVar(n:String, ?t:CType, ?e:Expr, ?isConst:Bool);
	EParent(e:Expr);
	EBlock(e:Array<Expr>);
	EField(e:Expr, f:String, s:Bool);
	EBinop(op:String, e1:Expr, e2:Expr);
	EUnop(op:String, prefix:Bool, e:Expr);
	ECall(e:Expr, params:Array<Expr>);
	EIf(cond:Expr, e1:Expr, ?e2:Expr);
	EWhile(cond:Expr, e:Expr);
	EFor(v:String, it:Expr, e:Expr);
	EBreak;
	EContinue;
	EFunction(args:Array<Argument>, e:Expr, ?name:String, ?ret:CType);
	EReturn(?e:Expr);
	EArray(e:Expr, index:Expr);
	EArrayDecl(e:Array<Expr>);
	ENew(cl:String, params:Array<Expr>);
	EThrow(e:Expr);
	ETry(e:Expr, v:String, t:Null<CType>, ecatch:Expr);
	EObject(fl:Array<ObjectDecl>);
	ETernary(cond:Expr, e1:Expr, e2:Expr);
	ESwitch(e:Expr, cases:Array<SwitchCase>, ?defaultExpr:Expr);
	EDoWhile(cond:Expr, e:Expr);
	EMeta(name:String, args:Array<Expr>, e:Expr);
	ECheckType(e:Expr, t:CType);
	EEnum(name:String, fields:Array<EnumType>);
	EDirectValue(value:Dynamic);
	EUsing(name:String);
}

typedef Argument = {name: String, ?t: CType, ?opt: Bool, ?value: Expr};
typedef Metadata = Array<{name: String, params: Array<Expr>}>;

@:structInit
class SwitchCase {
	public var values: Array<Expr>;
	public var expr: Expr;
	public var ifExpr: Null<Expr>;

	public function toString(): String {
		return Std.string({values: values, expr: expr, ifExpr: ifExpr});
	}
}

@:structInit
class ObjectDecl {
	public var name: String;
	public var e: Expr;

	public function toString(): String {
		return Std.string({name: name, e: e});
	}
}

typedef TypePath = {
	var pack: Array<String>;
	var name: String;
	var params: Array<CType>;
	var sub: String;
}

enum CType {
	CTPath(path: TypePath);
	CTFun(args: Array<CType>, ret: CType);
	CTAnon(fields: Array<{name: String, t: CType, ?meta: Metadata}>);
	CTExtend(t: Array<TypePath>, fields: Array<{name: String, t: CType, ?meta: Metadata}>);
	CTParent(t: CType);
	CTOpt(t: CType);
	CTNamed(n: String, t: CType);
	CTIntersection(types: Array<CType>);
}

#if hscriptPos
class Error {
	public var e: ErrorDef;
	public var pmin: Int;
	public var pmax: Int;
	public var origin: String;
	public var line: Int;

	public function new(e, pmin, pmax, origin, line) {
		this.e = e;
		this.pmin = pmin;
		this.pmax = pmax;
		this.origin = origin;
		this.line = line;
	}

	public function toString(): String {
		return Printer.errorToString(this);
	}
}

enum ErrorDef
#else
enum Error
#end
{
	EInvalidChar(c:Int);
	EUnexpected(s:String);
	EUnterminatedString;
	EUnterminatedComment;
	EInvalidPreprocessor(msg:String);
	EUnknownVariable(v:String);
	EInvalidIterator(v:String);
	EInvalidOp(op:String);
	EInvalidAccess(f:String);
	ECustom(msg:String);
}

enum ModuleDecl {
	DPackage(path: Array<String>);
	DImport(path: Array<String>, ?everything: Bool, ?as: String);
	DClass(c: ClassDecl);
	DTypedef(c: TypeDecl);
}

typedef ModuleType = {
	var name: String;
	var params: {}; // TODO : not yet parsed
	var meta: Metadata;
	var isPrivate: Bool;
}

typedef ClassDecl = {
	> ModuleType,
	var extend: Null<CType>;
	var implement: Array<CType>;
	var fields: Array<FieldDecl>;
	var isExtern: Bool;
}

typedef TypeDecl = {
	> ModuleType,
	var t: CType;
}

typedef FieldDecl = {
	var name: String;
	var meta: Metadata;
	var kind: FieldKind;
	var access: Array<FieldAccess>;
}

enum abstract FieldAccess(ByteUInt) {
	var APublic;
	var APrivate;
	var AInline;
	var AOverride;
	var AStatic;
	var AMacro;
}

enum FieldKind {
	KFunction(f: FunctionDecl);
	KVar(v: VarDecl);
}

typedef FunctionDecl = {
	var args: Array<Argument>;
	var expr: Expr;
	var ret: Null<CType>;
}

typedef VarDecl = {
	var get: Null<String>;
	var set: Null<String>;
	var expr: Null<Expr>;
	var type: Null<CType>;
}

enum EnumType {
	ESimple(name: String);
	EConstructor(name: String, args: Array<Argument>);
}
