package mockingbird;

import haxe.rtti.Infos;
import haxe.rtti.CType;
import neko.Lib;

import haxe.macro.Expr;
import haxe.macro.Context;

import mockingbird.rtti.RttiUtil;

/**
 * ...
 * @author Andreas Soderlund
 */
class The
{
	private static function const(e : Expr) : Constant
	{
		//trace(e);
		
		switch(e.expr)
		{
			case EField(e, field):
				//trace(field);
				return const(e);
				
			case EConst(c):
				return c;
				
			default:
				throw "Not supported expression: " + e.expr;
		}
	}
	
	@:macro public static function field(e : Expr)
	{
		var field : String = null;
		
		switch(e.expr)
		{
			case EField(e, f):
				field = f;
				
			default:
				return e;
		}
		
		return { expr: EConst(CString(field)), pos: Context.currentPos() };
	}
	
	@:macro public static function method(e : Expr)
	{
		var field : String = null;
		
		//toString(e);		
		// src/mockingbird/Mock.hx:70: EFunction({ expr => { expr => EBlock([{ expr => EReturn({ expr => EConst(CString(MOCK)), pos => #pos(test/Main.hx:31: characters 44-50) }), pos => #pos(test/Main.hx:31: characters 37-50) }]), pos => #pos(test/Main.hx:31: characters 35-53) }, args => [], ret => null })
		
		switch(e.expr)
		{
			case EField(e, f):
				// Return an anonymous method that returns the fieldname as value.
				return { expr: EFunction( {expr: { expr: EReturn( { expr: EConst(CString(f)), pos : Context.currentPos() } ), pos : Context.currentPos() }, args: [], ret: null } ), pos: Context.currentPos() };
				
			default:
				return e;
		}
	}
	
	@:macro public static function exprToString(e : Expr)
	{
		toString(e);
		return { expr: EConst(CType("Void")), pos: Context.currentPos() };
	}
	
	public static function toString(e : Expr)
	{
		trace(e.expr);
		
		var o = Std.string(e.expr);
		var posReplace = ~/#pos.*?characters [0-9]+-[0-9+]./g;
		o = posReplace.replace(o, "Context.currentPos()");
		
		o = StringTools.replace(o, "=>", ":");
		
		Lib.println(o);
	}
}

class Times
{
	private var count : Int;
	private var max : Bool;
	private var min : Bool;
	
	public function new(count : Int, ?max : Bool, ?min : Bool)
	{
		this.count = count;
		this.max = max;
		this.min = min;
	}
	
	public static function Once()
	{
		return new Times(1);
	}
	
	public static function Never()
	{
		return new Times(0);
	}

	public static function AtLeastOnce()
	{
		return new Times(1, false, true);
	}

	public static function AtMostOnce()
	{
		return new Times(1, true, false);
	}

	public static function AtLeast(calls : Int)
	{
		return new Times(calls, false, true);
	}

	public static function AtMost(calls : Int)
	{
		return new Times(calls, true, false);
	}

	public static function Exactly(calls : Int)
	{
		return new Times(calls, false, false);
	}

	public function isValid(callCount : Int)
	{
		if (max == true)
			return callCount <= count;
		
		if (min == true)
			return callCount >= count;
			
		return callCount == count;
	}
	
	public function toString()
	{
		if (max == true)
			return "at most " + count + " call" + (count == 1 ? "" : "s");
			
		if (min == true)
			return "at least " + count + " call" + (count == 1 ? "" : "s");
			
		return "exactly " + count + " call" + (count == 1 ? "" : "s");
	}
}
 
class Mock<T>
{
	private var type : Class<Dynamic>;	
	
	public function new(type : Class<Dynamic>)
	{
		this.type = type;
		this.mockObject = Std.is(type, Infos) ? new MockObject(type) : Type.createEmptyInstance(type);
		this.funcCalls = new Hash<Int>();
	}
	
	private var mockObject : Dynamic;
	public var object(getObject, null) : T;
	private function getObject() : T
	{
		return cast mockObject;
	}
	
	public function setup(field : Dynamic) : MockSetupContext<T>
	{
		var fieldName : String;
		var isFunc : Bool = false;
		
		if (Reflect.isFunction(field))
		{
			fieldName = field();
			isFunc = true;
		}
		else if(Std.is(field, String))
			fieldName = field;
		else
			throw "Only 'String' or 'Void -> String' are allowed arguments to setup()";
		
		return new MockSetupContext<T>(this, fieldName, isFunc);
	}
	
	public function verify(methodName : String, ?times : Times)
	{
		if (times == null)
			times = new Times(1, false, true);
		
		var count = funcCalls.exists(methodName) ? funcCalls.get(methodName) : 0;
		
		if (!times.isValid(count))
			throw new MockException("Mock verification failed: Expected " + times + " to function " + methodName + ", but was " + count + " call"  + (count == 1 ? "" : "s") + ".");
	}
	
	public var funcCalls : Hash<Int>;

	private function addCallCount(field : String) : Void
	{
		if (!funcCalls.exists(field))
			funcCalls.set(field, 1);
		else
			funcCalls.set(field, funcCalls.get(field) + 1);
	}	
}

private class MockSetupContext<T>
{
	private var mock : Mock<T>;
	private var fieldName : Dynamic;
	private var isFunc : Bool;
	
	public function new(mock : Mock<T>, fieldName : String, isFunc : Bool)
	{
		this.mock = mock;
		this.fieldName = fieldName;
		this.isFunc = isFunc;
		
		//trace("MockContext: " + fieldName);
	}
	
	public function returns(value : Dynamic) : MockSetupContext<T>
	{
		var fieldName = this.fieldName;
		
		if (isFunc)
		{
			//trace("SetupContext: " + fieldName + " is func, returns field " + fieldName);
			
			var p : { private function addCallCount(field : String) : Void; } = mock;
			
			var returnFunction = Reflect.makeVarArgs(function(args : Array<Dynamic>) {
				p.addCallCount(fieldName);
				return value;
			});		
			
			Reflect.setField(mock.object, fieldName, returnFunction);
		}
		else
		{
			Reflect.setField(mock.object, fieldName, value);
		}
			
		return this;
	}
	
	public function throws(value : Dynamic)
	{
		Reflect.setField(mock.object, fieldName, throw value);
		return this;
	}
	
	public function callBack(f : Void -> Void) : MockSetupContext<T>
	{
		f();
		return this;
	}
}

private class MockObject implements Dynamic
{
	public function new(type : Class<Dynamic>)
	{
		if (untyped type.__rtti == null)
			throw "haxe.rtti.Infos must be implemented on " + Type.getClassName(type) + " to mock it.";
		
		var self = this;
			
		for (field in RttiUtil.getFields(type))
		{
			//trace(field);			
			switch(field.type)
			{
				case CFunction(args, ret):
					Reflect.setField(this, field.name, Reflect.makeVarArgs(function(a : Array<Dynamic>) {} ));
					
				default:
					Reflect.setField(this, field.name, null);
			}			
		}
	}
}
