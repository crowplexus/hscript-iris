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
import crowplexus.hscript.Types.ByteInt;
import haxe.Serializer;
import haxe.Unserializer;

enum abstract BytesExpr(ByteInt) from ByteInt to ByteInt {
	var EIdent = 0;
	var EVar = 1;
	var EConst = 2;
	var EParent = 3;
	var EBlock = 4;
	var EField = 5;
	var EBinop = 6;
	var EUnop = 7;
	var ECall = 8;
	var EIf = 9;
	var EWhile = 10;
	var EFor = 11;
	var EBreak = 12;
	var EContinue = 13;
	var EFunction = 14;
	var EReturn = 15;
	var EArray = 16;
	var EArrayDecl = 17;
	var ENew = 18;
	var EThrow = 19;
	var ETry = 20;
	var EObject = 21;
	var ETernary = 22;
	var ESwitch = 23;
	var EDoWhile = 24;
	var EMeta = 25;
	var ECheckType = 26;
	var EImport = 27;
	var EEnum = 28;
	var EDirectValue = 29;
	var EUsing = 30;
}

enum abstract BytesConst(ByteInt) from ByteInt to ByteInt {
	var CInt = 0;
	var CIntByte = 1;
	var CFloat = 2;
	var CString = 3;
	#if !haxe3
	var CInt32 = 4;
	#end
}

enum abstract BytesIntSize(ByteInt) from ByteInt to ByteInt {
	var I8;
	var I16;
	var I32;
	var N8;
	var N16;
	var N32;
}

class Bytes {
	var bin: haxe.io.Bytes;
	var bout: haxe.io.BytesBuffer;
	var pin: Int;
	var hstrings: #if haxe3 Map<String, Int> #else Hash<Int> #end;
	var strings: Array<String>;
	var nstrings: Int;

	var opMap: Map<String, Int>;

	function new(?bin) {
		this.bin = bin;
		pin = 0;
		bout = new haxe.io.BytesBuffer();
		hstrings = #if haxe3 new Map() #else new Hash() #end;
		strings = [null];
		nstrings = 1;

		opMap = new Map();
		opMap.set("+", 0);
		opMap.set("-", 1);
		opMap.set("*", 2);
		opMap.set("/", 3);
		opMap.set("%", 4);
		opMap.set("&", 5);
		opMap.set("|", 6);
		opMap.set("^", 7);
		opMap.set("<<", 8);
		opMap.set(">>", 9);
		opMap.set(">>>", 10);
		opMap.set("==", 11);
		opMap.set("!=", 12);
		opMap.set(">=", 13);
		opMap.set("<=", 14);
		opMap.set(">", 15);
		opMap.set("<", 16);
		opMap.set("||", 17);
		opMap.set("&&", 18);
		opMap.set("=", 19);
		opMap.set("??", 20);
		opMap.set("...", 21);
		// unary
		opMap.set("!", 22);
		opMap.set("~", 24);

		for (key => value in opMap)
			opMap.set(key, value << 1); // make place for the isAssign
	}

	function doEncodeOp(op: String) {
		var isAssign = !opMap.exists(op) && op.charCodeAt(op.length - 1) == "=".code;
		var _op = op;
		if (isAssign) {
			op = op.substr(0, op.length - 1);
		}
		var v = opMap.get(op);
		if (v == null)
			throw "Invalid operator " + _op;
		bout.addByte(v);
	}

	function doDecodeOp(): String {
		var v = bin.get(pin++);
		var isAssign = (v & 1) != 0;
		v >>= 1;
		for (key => value in opMap)
			if (value == v)
				return key + (isAssign ? "=" : "");
		throw "Invalid operator " + v;
	}

	function doEncodeString(v: String) {
		var vid = hstrings.get(v);
		if (vid == null) {
			if (nstrings == 256) {
				hstrings = #if haxe3 new Map() #else new Hash() #end;
				nstrings = 1;
			}
			hstrings.set(v, nstrings);
			bout.addByte(0);
			var vb = haxe.io.Bytes.ofString(v);
			bout.addByte(vb.length);
			bout.add(vb);
			nstrings++;
		} else
			bout.addByte(vid);
	}

	function doDecodeString() {
		var id = bin.get(pin++);
		if (id == 0) {
			var len = bin.get(pin);
			var str = #if (haxe_ver < 3.103) bin.readString(pin + 1, len); #else bin.getString(pin + 1, len); #end
			pin += len + 1;
			if (strings.length == 255)
				strings = [null];
			strings.push(str);
			return str;
		}
		return strings[id];
	}

	function doEncodeInt(v: Int) {
		var isNeg = v < 0;
		if (isNeg)
			v = -v;
		if (v >= 0 && v <= 255) {
			bout.addByte(isNeg ? N8 : I8);
			bout.addByte(v);
		} else if (v >= 0 && v <= 65535) {
			bout.addByte(isNeg ? N16 : I16);
			bout.addByte(v & 0xFF);
			bout.addByte((v >> 8) & 0xFF);
		} else {
			bout.addByte(isNeg ? N32 : I32);
			bout.addInt32(v);
		}
	}

	function doEncodeBool(v: Bool) {
		bout.addByte(v ? 1 : 0);
	}

	function doEncodeConst(c: Const) {
		switch (c) {
			case CInt(v):
				if (v >= 0 && v <= 255) {
					bout.addByte(CIntByte);
					bout.addByte(v & 0xFF);
				} else {
					bout.addByte(CInt);
					doEncodeInt(v);
				}
			case CFloat(f):
				bout.addByte(CFloat);
				doEncodeString(Std.string(f));
			case CString(s):
				bout.addByte(CString);
				doEncodeString(s);
			#if !haxe3
			case CInt32(v):
				bout.addByte(CInt32);
				var mid = haxe.Int32.toInt(haxe.Int32.and(v, haxe.Int32.ofInt(0xFFFFFF)));
				bout.addByte(mid & 0xFF);
				bout.addByte((mid >> 8) & 0xFF);
				bout.addByte(mid >> 16);
				bout.addByte(haxe.Int32.toInt(haxe.Int32.ushr(v, 24)));
			#end
		}
	}

	function doDecodeInt() {
		var size = cast(bin.get(pin++), BytesIntSize);
		var i = switch (size) {
			case I8 | N8: bin.get(pin++);
			case I16 | N16: bin.get(pin++) | bin.get(pin++) << 8;
			case I32 | N32: bin.getInt32(pin);
		}
		switch (size) {
			case I8 | N8:
			case I16 | N16:
			case I32 | N32:
				pin += 4;
		}
		switch (size) {
			case N8 | N16 | N32:
				i = -i;
			default:
		}
		return i;
	}

	function doDecodeConst(): Const {
		return switch (bin.get(pin++)) {
			case CIntByte:
				CInt(bin.get(pin++));
			case CInt:
				var i = doDecodeInt();
				CInt(i);
			case CFloat:
				CFloat(Std.parseFloat(doDecodeString()));
			case CString:
				CString(doDecodeString());
			#if !haxe3
			case CInt32:
				var i = bin.get(pin) | (bin.get(pin + 1) << 8) | (bin.get(pin + 2) << 16);
				var j = bin.get(pin + 3);
				pin += 4;
				CInt32(haxe.Int32.or(haxe.Int32.ofInt(i), haxe.Int32.shl(haxe.Int32.ofInt(j), 24)));
			#end
			default:
				throw "Invalid code " + bin.get(pin - 1);
		}
	}

	function doDecodeArg(): Argument {
		var name = doDecodeString();
		var opt = doDecodeBool();
		return {
			name: name,
			opt: opt,
			t: null
		};
	}

	function doEncodeExprType(t: BytesExpr) {
		/*switch (t) {
			case EIdent:
				bout.addString("EIdent");
			case EVar:
				bout.addString("EVar");
			case EConst:
				bout.addString("EConst");
			case EParent:
				bout.addString("EParent");
			case EBlock:
				bout.addString("EBlock");
			case EField:
				bout.addString("EField");
			case EBinop:
				bout.addString("EBinop");
			case EUnop:
				bout.addString("EUnop");
			case ECall:
				bout.addString("ECall");
			case EIf:
				bout.addString("EIf");
			case EWhile:
				bout.addString("EWhile");
			case EFor:
				bout.addString("EFor");
			case EBreak:
				bout.addString("EBreak");
			case EContinue:
				bout.addString("EContinue");
			case EFunction:
				bout.addString("EFunction");
			case EReturn:
				bout.addString("EReturn");
			case EArray:
				bout.addString("EArray");
			case EArrayDecl:
				bout.addString("EArrayDecl");
			case ENew:
				bout.addString("ENew");
			case EThrow:
				bout.addString("EThrow");
			case ETry:
				bout.addString("ETry");
			case EObject:
				bout.addString("EObject");
			case ETernary:
				bout.addString("ETernary");
			case ESwitch:
				bout.addString("ESwitch");
			case EDoWhile:
				bout.addString("EDoWhile");
			case EMeta:
				bout.addString("EMeta");
			case ECheckType:
				bout.addString("ECheckType");
			case EImport:
				bout.addString("EImport");
			case EEnum:
				bout.addString("EEnum");
			case EDirectValue:
				bout.addString("EDirectValue");
		}*/
		bout.addByte(t);
	}

	function doEncodeArg(a: Argument) {
		doEncodeString(a.name);
		doEncodeBool(a.opt);
		// doEncode(a.t);
	}

	function doEncode(e: Expr) {
		#if hscriptPos
		doEncodeString(e.origin);
		doEncodeInt(e.line);
		var e = e.e;
		#end
		switch (e) {
			case EIgnore(_):
			case EConst(c):
				doEncodeExprType(EConst);
				doEncodeConst(c);
			case EIdent(v):
				doEncodeExprType(EIdent);
				doEncodeString(v);
			case EVar(n, _, e, c):
				doEncodeExprType(EVar);
				doEncodeString(n);
				if (e == null)
					bout.addByte(255);
				else
					doEncode(e);
				doEncodeBool(c);
			case EParent(e):
				doEncodeExprType(EParent);
				doEncode(e);
			case EBlock(el):
				doEncodeExprType(EBlock);
				doEncodeInt(el.length);
				for (e in el)
					doEncode(e);
			case EField(e, f, s):
				doEncodeExprType(EField);
				doEncode(e);
				doEncodeString(f);
				doEncodeBool(s);
			case EBinop(op, e1, e2):
				doEncodeExprType(EBinop);
				doEncodeOp(op);
				doEncode(e1);
				doEncode(e2);
			case EUnop(op, prefix, e):
				doEncodeExprType(EUnop);
				doEncodeOp(op);
				doEncodeBool(prefix);
				doEncode(e);
			case ECall(e, el):
				doEncodeExprType(ECall);
				doEncode(e);
				bout.addByte(el.length);
				for (e in el)
					doEncode(e);
			case EIf(cond, e1, e2):
				doEncodeExprType(EIf);
				doEncode(cond);
				doEncode(e1);
				if (e2 == null)
					bout.addByte(255);
				else
					doEncode(e2);
			case EWhile(cond, e):
				doEncodeExprType(EWhile);
				doEncode(cond);
				doEncode(e);
			case EDoWhile(cond, e):
				doEncodeExprType(EDoWhile);
				doEncode(cond);
				doEncode(e);
			case EFor(v, it, e):
				doEncodeExprType(EFor);
				doEncodeString(v);
				doEncode(it);
				doEncode(e);
			case EBreak:
				doEncodeExprType(EBreak);
			case EContinue:
				doEncodeExprType(EContinue);
			case EFunction(params, e, name, _):
				doEncodeExprType(EFunction);
				bout.addByte(params.length);
				for (p in params)
					doEncodeArg(p);
				doEncode(e);
				doEncodeString(name == null ? "" : name);
			case EReturn(e):
				doEncodeExprType(EReturn);
				if (e == null)
					bout.addByte(255);
				else
					doEncode(e);
			case EArray(e, index):
				doEncodeExprType(EArray);
				doEncode(e);
				doEncode(index);
			case EArrayDecl(el):
				doEncodeExprType(EArrayDecl);
				doEncodeInt(el.length);
				for (e in el)
					doEncode(e);
			case ENew(cl, params):
				doEncodeExprType(ENew);
				doEncodeString(cl);
				bout.addByte(params.length);
				for (e in params)
					doEncode(e);
			case EThrow(e):
				doEncodeExprType(EThrow);
				doEncode(e);
			case ETry(e, v, _, ecatch):
				doEncodeExprType(ETry);
				doEncode(e);
				doEncodeString(v);
				doEncode(ecatch);
			case EObject(fl):
				doEncodeExprType(EObject);
				doEncodeInt(fl.length);
				for (f in fl) {
					doEncodeString(f.name);
					doEncode(f.e);
				}
			case ETernary(cond, e1, e2):
				doEncodeExprType(ETernary);
				doEncode(cond);
				doEncode(e1);
				doEncode(e2);
			case ESwitch(e, cases, def):
				doEncodeExprType(ESwitch);
				doEncode(e);
				for (c in cases) {
					if (c.values.length == 0)
						throw "assert";
					for (v in c.values)
						doEncode(v);
					bout.addByte(255);
					doEncode(c.expr);
					doEncode(c.ifExpr);
				}
				bout.addByte(255);
				if (def == null)
					bout.addByte(255)
				else
					doEncode(def);
			case EMeta(name, args, e):
				doEncodeExprType(EMeta);
				doEncodeString(name);
				bout.addByte(args == null ? 0 : args.length + 1);
				if (args != null)
					for (e in args)
						doEncode(e);
				doEncode(e);
			case ECheckType(e, _):
				doEncodeExprType(ECheckType);
				doEncode(e);
			case EEnum(name, fields):
				doEncodeExprType(EEnum);
				doEncodeString(name);
				bout.addByte(fields.length);
				for (f in fields)
					switch (f) {
						case ESimple(name):
							bout.addByte(0);
							doEncodeString(name);
						case EConstructor(name, args):
							bout.addByte(1);
							doEncodeString(name);
							bout.addByte(args.length);
							for (a in args)
								doEncodeArg(a);
					}
			case EDirectValue(value):
				doEncodeExprType(EDirectValue);
				doEncodeString(Serializer.run(value));
			case EImport(v, as):
				doEncodeExprType(EImport);
				doEncodeString(v);
				doEncodeString(as);
			case EUsing(name):
				doEncodeExprType(EUsing);
				doEncodeString(name);
		}
		// bout.addString("__||__");
	}

	function doDecodeBool(): Bool {
		return bin.get(pin++) != 0;
	}

	function doDecode(): Expr {
	#if hscriptPos
	if (bin.get(pin) == 255) {
		pin++;
		return null;
	}
	var origin = doDecodeString();
	var line = doDecodeInt();
	return {
		e: _doDecode(),
		pmin: 0,
		pmax: 0,
		origin: origin,
		line: line
	};
	} function _doDecode(): ExprDef {
	#end
		var type: BytesExpr = bin.get(pin++);
		return switch (type) {
			case EConst:
				EConst(doDecodeConst());
			case EIdent:
				EIdent(doDecodeString());
			case EVar:
				var v = doDecodeString();
				var e = doDecode();
				var c = doDecodeBool();
				EVar(v, e, c);
			case EParent:
				EParent(doDecode());
			case EBlock:
				var a = new Array();
				var len = doDecodeInt();
				for (i in 0...len)
					a.push(doDecode());
				EBlock(a);
			case EField:
				var e = doDecode();
				var name = doDecodeString();
				var s = doDecodeBool();
				EField(e, name, s);
			case EBinop:
				var op = doDecodeOp();
				var e1 = doDecode();
				EBinop(op, e1, doDecode());
			case EUnop:
				var op = doDecodeOp();
				var prefix = doDecodeBool();
				EUnop(op, prefix, doDecode());
			case ECall:
				var e = doDecode();
				var params = new Array();
				for (i in 0...bin.get(pin++))
					params.push(doDecode());
				ECall(e, params);
			case EIf:
				var cond = doDecode();
				var e1 = doDecode();
				EIf(cond, e1, doDecode());
			case EWhile:
				var cond = doDecode();
				EWhile(cond, doDecode());
			case EDoWhile:
				var cond = doDecode();
				EDoWhile(cond, doDecode());
			case EFor:
				var v = doDecodeString();
				var it = doDecode();
				EFor(v, it, doDecode());
			case EBreak:
				EBreak;
			case EContinue:
				EContinue;
			case EFunction:
				var params = new Array<Argument>();
				for (i in 0...bin.get(pin++))
					params.push(doDecodeArg());
				var e = doDecode();
				var name = doDecodeString();
				EFunction(params, e, (name == "") ? null : name);
			case EReturn:
				EReturn(doDecode());
			case EArray:
				var e = doDecode();
				EArray(e, doDecode());
			case EArrayDecl:
				var el = new Array();
				var len = doDecodeInt();
				for (i in 0...len)
					el.push(doDecode());
				EArrayDecl(el);
			case ENew:
				var cl = doDecodeString();
				var el = new Array();
				for (i in 0...bin.get(pin++))
					el.push(doDecode());
				ENew(cl, el);
			case EThrow:
				EThrow(doDecode());
			case ETry:
				var e = doDecode();
				var v = doDecodeString();
				ETry(e, v, null, doDecode());
			case EObject:
				var fl: Array<ObjectDecl> = [];
				var len = doDecodeInt();
				for (i in 0...len) {
					var name = doDecodeString();
					var e = doDecode();
					fl.push({name: name, e: e});
				}
				EObject(fl);
			case ETernary:
				var cond = doDecode();
				var e1 = doDecode();
				var e2 = doDecode();
				ETernary(cond, e1, e2);
			case ESwitch:
				var e = doDecode();
				var cases: Array<SwitchCase> = [];
				while (true) {
					var v = doDecode();
					if (v == null)
						break;
					var values = [v];
					while (true) {
						v = doDecode();
						if (v == null)
							break;
						values.push(v);
					}
					var expr = doDecode();
					var ifExpr = doDecode();
					cases.push({values: values, expr: expr, ifExpr: ifExpr});
				}
				var def = doDecode();
				ESwitch(e, cases, def);
			case EMeta:
				var name = doDecodeString();
				var count = bin.get(pin++);
				var args = count == 0 ? null : [for (i in 0...count - 1) doDecode()];
				EMeta(name, args, doDecode());
			case ECheckType:
				ECheckType(doDecode(), CTPath({
					pack: [],
					params: null,
					sub: null,
					name: "Void"
				}));
			case EEnum:
				var name = doDecodeString();
				var fields: Array<EnumType> = [];
				for (i in 0...bin.get(pin++)) {
					switch (bin.get(pin++)) {
						case 0:
							var name = doDecodeString();
							fields.push(ESimple(name));
						case 1:
							var name = doDecodeString();
							var args: Array<Argument> = [];
							for (i in 0...bin.get(pin++))
								args.push(doDecodeArg());
							fields.push(EConstructor(name, args));
						default:
							throw "Invalid code " + bin.get(pin - 1);
					}
				}
				EEnum(name, fields);
			case EDirectValue:
				var value = doDecodeString();
				EDirectValue(Unserializer.run(value));
			case EImport:
				var v = doDecodeString();
				var as = doDecodeString();
				EImport(v, as);
			case EUsing:
				var name = doDecodeString();
				EUsing(name);
			case 255:
				null;
				// default:
				//	throw "Invalid code " + bin.get(pin - 1);
		}
	}

	public static function encode(e: Expr): haxe.io.Bytes {
		var b = new Bytes();
		b.doEncode(e);
		return b.bout.getBytes();
	}

	public static function decode(bytes: haxe.io.Bytes): Expr {
		var b = new Bytes(bytes);
		return b.doDecode();
	}
}
