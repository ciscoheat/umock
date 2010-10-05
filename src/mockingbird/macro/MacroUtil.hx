package mockingbird.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import neko.Lib;

/**
 * ...
 * @author Andreas Soderlund
 */

class MacroUtil 
{
	@:macro public static function toString(e : Expr) : Expr
	{
		return { expr: EConst(CString(toStringInternal(e))), pos: Context.currentPos() };
	}
	
	@:macro public static function dumpString(e : Expr) : Expr
	{
		Lib.println(toStringInternal(e));
		return { expr: EConst(CType("Void")), pos: Context.currentPos() };
	}
	
	static function toStringInternal(e : Expr)
	{
		var o = Std.string(e.expr);
		
		var posReplace = ~/#pos[^:]+:[0-9]+: characters [0-9]+-[0-9]+[)]/g;
		o = posReplace.replace(o, "Context.currentPos()");
		
		var nameReplace = ~/name => ([A-Za-z]+)/g;
		o = nameReplace.replace(o, "name => \"$1\"");

		var cStringReplace = ~/CString[(]([^)]+)[)]/g;
		o = cStringReplace.replace(o, "CString(\"$1\")");

		o = StringTools.replace(o, " =>", ":");
		
		return "{ expr: " + o + ", pos: Context.currentPos() }";
	}
}