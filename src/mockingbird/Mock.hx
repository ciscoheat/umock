package mockingbird;

import haxe.rtti.Infos;
import haxe.rtti.CType;
import neko.Lib;

import haxe.macro.Expr;
import haxe.macro.Context;

import mockingbird.rtti.RttiUtil;

/**
 * Gives typesafe information about fields and methods that can be used in Mock.setup()
 * @author Andreas Soderlund
 * @example mock.setup(The.field(mock.object.a)).returns(123);
 */
class The
{
	@:macro public static function field(e : Expr)
	{
		switch(e.expr)
		{
			case EField(e, f):
				// Return a string to notify Mock.setup() that it's a field.
				return { expr: EConst(CString(f)), pos: Context.currentPos() };
				
			default:
				// If no match, return itself to get intellisense.
				return e;
		}
	}
	
	@:macro public static function method(e : Expr)
	{
		switch(e.expr)
		{
			case EField(e, f):
				// To notify Mock.setup() that this is a method call,
				// return an anonymous method that returns the fieldname as a string.
				var cPos = Context.currentPos();
				return { expr: EFunction( {expr: { expr: EReturn( { expr: EConst(CString(f)), pos : cPos } ), pos : cPos }, args: [], ret: null } ), pos: cPos };
				
			default:
				// If no match, return itself to get intellisense.
				return e;
		}
	}	
}

/**
 * Verifies if a method has been called the correct number of times.
 */
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
 
/**
 * The mock object that handles all setup and verification.
 */
class Mock<T>
{	
	public var funcCalls : Hash<Int>;

	private var mockObject : Dynamic;
	public var object(getObject, null) : T;
	private function getObject() : T
	{
		return cast mockObject;
	}

	/**
	 * Instantiates a new mock object
	 * @param	type Class/Interface type for the mock.
	 * @example var mock = new Mock<IPoint>(IPoint);
	 */
	public function new(type : Class<Dynamic>)
	{
		this.mockObject = Std.is(type, Infos) ? new MockObject(type) : Type.createEmptyInstance(type);
		this.funcCalls = new Hash<Int>();
	}

	/**
	 * Setup a field (or method) so that it returns a specific value.
	 * @param	field 'String' for setting up a field, 'Void -> String' to setup a method. The method should return the fieldname.
	 * @return  A context object that will be used to define behavior.
	 * @example mock.setup(The.method(mock.object.getDate)).returns(Date.now());
	 */
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
			throw "Only 'String' or 'Void -> String' are allowed arguments for setup()";
		
		return new MockSetupContext<T>(this, fieldName, isFunc);
	}
	
	/**
	 * Verifies that a method has been called a specific number of times.
	 * @param	methodName name of method
	 * @param	?times Verification object. Use the static Times class to create constraints.
	 * @example mock.verify(The.method(mock.object.getDate), Times.Once());
	 * @throws  MockException if the verification fails.
	 */
	public function verify(field : Dynamic, ?times : Times)
	{
		var fieldName : String;
		
		if (Reflect.isFunction(field))
			fieldName = field();
		else if(Std.is(field, String))
			fieldName = field;
		else
			throw "Only 'String' or 'Void -> String' are allowed arguments for setup()";
		
		if (times == null)
			times = Times.AtLeastOnce();
		
		var count = funcCalls.exists(fieldName) ? funcCalls.get(fieldName) : 0;
		
		if (!times.isValid(count))
			throw new MockException("Mock verification failed: Expected " + times + " to function " + fieldName + ", but was " + count + " call"  + (count == 1 ? "" : "s") + ".");
	}
	
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
	}
	
	/**
	 * Specifies what value a mocked field should return
	 * @param	value Return value.
	 * @return  The same context object for method chaining.
	 */
	public function returns(value : Dynamic) : MockSetupContext<T>
	{
		var fieldName = this.fieldName;
		
		if (isFunc)
		{
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
	
	/**
	 * Specifies that a field should throw an exception.
	 * @param	value Exception to throw.
	 */
	public function throws(value : Dynamic)
	{
		Reflect.setField(mock.object, fieldName, throw value);
		return this;
	}
	
	/**
	 * A callback method that is executed on field invocation.
	 * @param	f A callback function
	 * @return  The same context object for method chaining.
	 */
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
		
		for (field in RttiUtil.getFields(type))
		{
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
