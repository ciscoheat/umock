package mockingbird;

import haxe.rtti.Infos;
import haxe.rtti.CType;

import haxe.macro.Expr;
import haxe.macro.Context;

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
				field = "?";
		}
		
		return { expr: EConst(CString(field)), pos: Context.currentPos() };
	}	
}
 
class Mock<T>
{
	private var type : Class<Dynamic>;
	
	public function new(type : Class<Dynamic>)
	{
		this.type = type;
		this.mockObject = new MockObject(type);
	}
	
	private var mockObject : MockObject;
	public var object(getObject, null) : T;
	private function getObject() : T
	{
		return cast mockObject;
	}
	
	public function setup(field : String) : MockSetupContext<T>
	{
		return new MockSetupContext<T>(this, field);
	}	
}

private class MockSetupContext<T>
{
	private var mock : Mock<T>;
	private var field : String;
	
	public function new(mock : Mock<T>, field : String)
	{
		this.mock = mock;
		this.field = field;
	}
	
	public function returns(value : Dynamic) : MockSetupContext<T>
	{
		if (Reflect.isFunction(Reflect.field(mock.object, field)))
			Reflect.setField(mock.object, field, FunctionHelper.dynamicFunction(value));
		else
			Reflect.setField(mock.object, field, value);
			
		return this;
	}
	
	public function throws(value : Dynamic)
	{
		Reflect.setField(mock.object, field, throw value);
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
				case CClass(name, params):
					//trace(field.name);
					Reflect.setField(this, field.name, FunctionHelper.defaultClassValueFor(name));
					
				case CEnum(name, params):
					//trace(Type.resolveEnum(name));
					Reflect.setField(this, field.name, FunctionHelper.defaultEnumValueFor(name));
				
				case CFunction(args, ret):
					switch(ret)
					{
						case CClass(name, params):
							Reflect.setField(this, field.name, FunctionHelper.dynamicFunction(null) );
						
						default:
							"Function return value " + ret + " not supported by mockingbird.";
					}
					
					
				default:
					throw "Type " + field.type + " not supported by mockingbird.";
			}			
		}
	}
	
	private function resolve(field : String) : Dynamic
	{
		throw "RESOLVE: " + field;
	}
}

private class FunctionHelper
{
	//public static function dynamicFunction(args : List<{ t : CType, opt : Bool, name : String }>, ret : CType) : Dynamic
	public static function dynamicFunction(returns : Dynamic) : Dynamic
	{
		return Reflect.makeVarArgs(function(a : Array<Dynamic>) { return returns; } );
	}

	public static function defaultEnumValueFor(c : String) : Dynamic
	{
		//if (c == "Bool")
		//	return false;
			
		return null;
	}
	
	public static function defaultClassValueFor(c : String) : Dynamic
	{		
		/*
		if (c == "Float")
			return cast(0.0, Float);
			
		if (c == "Int")
			return cast(0, Int);
		*/
			
		return null;
	}	
}