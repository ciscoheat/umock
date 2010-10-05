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
	
	public function isValid(callCount : Int, ?max : Bool, ?min : Bool)
	{
		if (max == true)
			return callCount <= count;
		
		if (min == true)
			return callCount >= count;
			
		return callCount == count;
	}
}
 
class Mock<T>
{
	private var type : Class<Dynamic>;	
	
	public function new(type : Class<Dynamic>)
	{
		this.type = type;
		this.mockObject = new MockObject(type);
		this.funcCalls = new Hash<Int>();
		
		watchFunctions();
	}
	
	private var mockObject : Dynamic;
	public var object(getObject, null) : T;
	private function getObject() : T
	{
		return cast mockObject;
	}
	
	public function setup(field : String) : MockSetupContext<T>
	{
		return new MockSetupContext<T>(this, field);
	}
	
	public function verify(field : String, ?times : Times)
	{
		// TODO
	}
	
	private function watchFunctions()
	{
		for (field in Type.getInstanceFields(type))
		{			
			if (Reflect.isFunction(Reflect.field(mockObject, field)))
			{
				setup(field).returns(null);
			}
		}
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
	private var field : String;
	
	public function new(mock : Mock<T>, field : String)
	{
		this.mock = mock;
		this.field = field;
	}
	
	public function returns(value : Dynamic) : MockSetupContext<T>
	{
		if (Reflect.isFunction(Reflect.field(mock.object, field)))
		{
			//trace("SetupContext: " + field + " is func");
			
			var self = this;
			var p : { private function addCallCount(field : String) : Void; } = mock;
			
			var returnFunction = Reflect.makeVarArgs(function(args : Array<Dynamic>) {
				p.addCallCount(self.field);
				return value;
			});		
			
			Reflect.setField(mock.object, field, returnFunction);
		}
		else
		{
			Reflect.setField(mock.object, field, value);
		}
			
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
					Reflect.setField(this, field.name, null);
					
				case CEnum(name, params):
					//trace(Type.resolveEnum(name));
					Reflect.setField(this, field.name, null);
				
				case CFunction(args, ret):
					Reflect.setField(this, field.name, Reflect.makeVarArgs(function(a : Array<Dynamic>) {} ));
					
				default:
					throw "Type " + field.type + " not supported by mockingbird.";
			}			
		}
	}
}
