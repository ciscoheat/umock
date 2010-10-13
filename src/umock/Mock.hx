package umock;

import haxe.rtti.Infos;
import haxe.rtti.CType;

import umock.rtti.RttiUtil;
import umock.ParameterConstraint;

#if withmacro
import haxe.macro.Expr;
import haxe.macro.Context;

/**
 * Gives typesafe information about fields and methods that can be used in Mock.setup()
 * @author Andreas Soderlund
 * @example mock.setupField("x")).returns(123);
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
#end

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
	
	public static function once() {	return new Times(1); }
	
	public static function never() { return new Times(0); }

	public static function atLeastOnce() { return new Times(1, false, true); }

	public static function atMostOnce() { return new Times(1, true, false);	}

	public static function atLeast(calls : Int) { return new Times(calls, false, true);	}

	public static function atMost(calls : Int) { return new Times(calls, true, false); }

	public static function exactly(calls : Int) { return new Times(calls, false, false); }

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

class It
{
	var typeConstraint : Class<Dynamic>;
	var valueConstraint : Dynamic;
	var regexConstraint : EReg;
	var isNull : Bool;
	
	public function new(?typeConstraint : Class<Dynamic>, ?valueConstraint : Dynamic, ?regexConstraint : EReg, ?isNull : Bool)
	{
		this.typeConstraint = typeConstraint;
		this.valueConstraint = valueConstraint;
		this.regexConstraint = regexConstraint;
		this.isNull = isNull;
	}
	
	public function isAnyIt() // Strange name because of PHP limitation.
	{
		return typeConstraint != null && valueConstraint == null && regexConstraint == null && isNull == null;
	}
	
	public static function IsNull() : It
	{
		return new It(null, null, null, true);
	}
	
	public static function IsAny(type : Class<Dynamic>) : It
	{
		return new It(type);
	}
	
	public static function IsRegex(regex : EReg) : It
	{
		return new It(null, null, regex);
	}
	
	public function matches(value : Dynamic)
	{
		if (isNull == true) return value == null;
		
		if (typeConstraint != null && !Std.is(value, typeConstraint))
			return false;
		
		if (valueConstraint != null && value != valueConstraint)
			return false;
			
		if (regexConstraint != null && !regexConstraint.match(Std.string(value)))
			return false;
			
		return true;
	}
}

/**
 * The mock object that handles all setup and verification.
 */
class Mock<T>
{	
	public var funcCalls(default, null) : Hash<Int>;
	var funcParameters : Hash<Array<ParameterConstraint>>;
	
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
		var name = Type.getClassName(type);
		var cls = Type.resolveClass(name);

		if (cls == null)
		{
			// No class defined, make it a mock object.
			//trace(name + " becomes a MockObject");
			mockObject = new MockObject(type);
		}
		else
		{
			// Class exists, make an empty instance to keep methods.
			//trace(name + " becomes an EmptyInstance");
			#if php
			mockObject = new MockObject(type, Type.createEmptyInstance(cls));
			#else
			mockObject = Type.createEmptyInstance(cls);
			#end
		}

		if (!Std.is(mockObject, MockObject) && Reflect.hasField(type, "__rtti"))
		{
			// If an type implements rtti, test all fields on object. If all fields are null
			// it's probably an interface so then we can create a MockObject to simulate all methods.
			var object = this.mockObject;
			var notNullFields = Lambda.filter(Type.getInstanceFields(type), function(field : String) { return Reflect.field(object, field) != null; } );
			
			if (notNullFields.length == 0)
			{
				//trace(Type.getClassName(type) + " is redefined from EmptyInstance to MockObject");
				mockObject = new MockObject(type);
			}
		}
				
		funcCalls = new Hash<Int>();
		funcParameters = new Hash<Array<ParameterConstraint>>();
	}

	/**
	 * Setup a field (or method) so that it returns a specific value.
	 * @param	field 'String' for setting up a field, 'Void -> String' to setup a method. The method should return the fieldname.
	 * @return  A context object that will be used to define behavior.
	 * @example mock..setupMethod("getDate")).returns(Date.now());
	 */
	public function setup(field : Dynamic) : MockSetupParamContext<T>
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
					
		return new MockSetupParamContext<T>(this, fieldName, isFunc);
	}
	
	public function setupField(fieldName : String)
	{
		return setup(fieldName);
	}
	
	public function setupMethod(methodName : String)
	{
		return setup(function() { return methodName; });
	}

	
	/**
	 * Verifies that a method has been called a specific number of times.
	 * @param	methodName name of method
	 * @param	?times Verification object. Use the static Times class to create constraints.
	 * @example mock.verify("getDate", Times.Once());
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
			times = Times.atLeastOnce();
		
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
	
	private function addParams(field : String, params : ParameterConstraint) : Void
	{
		if (!funcParameters.exists(field))
			funcParameters.set(field, [params]);
		else
		{
			var parameters = funcParameters.get(field);

			// There can only be one catch-all constraint.
			if (params.parameters.length == 0)
			{
				for (p in parameters)
					if (p.parameters.length == 0)
						parameters.remove(p);
			}
			
			parameters.push(params);
			
			// Sort the parameter arrays so the arrays with most parameters comes first.
			// If equal parameters, sort the It.IsAny() parameters last.
			parameters.sort(function(x : ParameterConstraint, y : ParameterConstraint) {
				var test = y.parameters.length - x.parameters.length;
				return test == 0 ? sortIsAny(x, y) : test;
			});
		}
	}
	
	private static function sortIsAny(x : ParameterConstraint, y : ParameterConstraint) : Int
	{
		var xCount = 0;
		var yCount = 0;
		
		// Two constraints with equal number of parameters. Least number of It.IsAny goes first.
		for (i in 0 ... x.parameters.length)
		{
			var x = x.parameters[i];
			var y = y.parameters[i];
			
			if (Std.is(x, It) && cast(x, It).isAnyIt()) xCount++;
			if (Std.is(y, It) && cast(y, It).isAnyIt()) yCount++;
		}
		
		return xCount - yCount;
	}
		
	private function returnValue(field : String, args : Array<Dynamic>) : Dynamic
	{
		var parameters = validParameters(field, args);
		
		for (p in parameters)
		{
			var output = p.returnIfMatches(args);
			if (output != null) return output;
		}
		
		// If no match, use the catch-all (last parameter) if it exists.
		var catchAll = catchAll(field);		
		return catchAll != null ? catchAll.returnIfMatches(args) : null;
	}
		
	/**
	 * Get the catch-all parameter if it exists, which is the one without a withParams() call.
	 * @param	field
	 */
	private function catchAll(field : String)
	{
		var params = funcParameters.get(field);
		
		var catchAll = params[params.length - 1];
		return catchAll.parameters.length == 0 ? catchAll : null;
	}
	
	private function validParameters(field : String, args : Array<Dynamic>) : List<ParameterConstraint>
	{
		// Because optional arguments are specified by null, two rules must be made to
		// differ between cases, otherwise the constraints will mismatch.
		var allParameters = funcParameters.get(field);		
		var argsLength = args.length;
		
		// If args are without null, get only the constraints that are exactly that length.
		// If not, get all constraints up to that length.
		if (Lambda.exists(args, function(arg : Dynamic) { return arg == null; } ))
		{
			return Lambda.filter(allParameters, function(param : ParameterConstraint) { return param.parameters.length <= argsLength; } );
		}
		else
		{
			return Lambda.filter(allParameters, function(param : ParameterConstraint) { return param.parameters.length == argsLength; } );
		}
	}
}

private class MockSetupParamContext<T> extends MockSetupContext<T>
{
	public function new(mock : Mock<T>, fieldName : String, isFunc : Bool)
	{
		super(mock, fieldName, isFunc);
	}

	public function withParams(p1 : Dynamic, ?p2 : Dynamic, ?p3 : Dynamic, ?p4 : Dynamic, ?p5 : Dynamic, ?p6 : Dynamic, ?p7 : Dynamic, ?p8 : Dynamic) : MockSetupContext<T>
	{
		if (!isFunc)
			throw "withParams() isn't allowed on properties.";

		parameters = [p1];
		if (p2 != null) parameters.push(p2);
		if (p3 != null) parameters.push(p3);
		if (p4 != null) parameters.push(p4);
		if (p5 != null) parameters.push(p5);
		if (p6 != null) parameters.push(p6);
		if (p7 != null) parameters.push(p7);
		if (p8 != null) parameters.push(p8);
		
		return this;
	}
}

private typedef MockFriend = {
	private function addCallCount(field : String) : Void;
	private function addParams(field : String, params : ParameterConstraint) : Void;
	private function returnValue(field : String, args : Array<Dynamic>) : Dynamic;
};

private class MockSetupContext<T>
{
	private var mock : Mock<T>;
	private var fieldName : Dynamic;
	private var isFunc : Bool;
	private var callBacks : Array<Array<Dynamic> -> Void>;
	private var parameters : Array<Dynamic>;
	private var isLazy : Bool;
	private var isThrow : Bool;
	
	public function new(mock : Mock<T>, fieldName : String, isFunc : Bool)
	{
		this.mock = mock;
		this.fieldName = fieldName;
		this.isFunc = isFunc;
		this.isLazy = false;
		this.callBacks = new Array<Array<Dynamic> -> Void>();
	}
	
	/**
	 * Returns a value through a callback function.
	 * @param	f callback function
	 * @return	The same context object for method chaining.
	 */
	public function returnsLazy(f : Void -> Dynamic) : MockSetupContext<T>
	{
		isLazy = true;
		return returns(f);
	}

	/**
	 * Throws a value through a callback function.
	 * @param	f callback function
	 * @return	The same context object for method chaining.
	 */
	public function throwsLazy(f : Void -> Dynamic) : MockSetupContext<T>
	{
		isLazy = true;
		return throws(f);
	}

	/**
	 * Specifies what value a mocked field should return
	 * @param	value Return value.
	 * @return  The same context object for method chaining.
	 */
	public function returns(value : Dynamic) : MockSetupContext<T>
	{
		return createConstraint(ConstraintAction.returnAction(value));
	}
	
	public function createConstraint(value : ConstraintAction) : MockSetupContext<T>
	{
		var fieldName = this.fieldName;
		var calls = this.callBacks;
		
		if (isFunc)
		{
			var constraint = new ParameterConstraint(value, parameters, isLazy);
			var p : MockFriend = mock;
			p.addParams(fieldName, constraint);
			
			//trace("Added constraint: " + constraint);
			
			var returnFunction = Reflect.makeVarArgs(function(args : Array<Dynamic>) {
				p.addCallCount(fieldName);
				for (f in calls) f(args);
				return p.returnValue(fieldName, args);
			});		
			
			Reflect.setField(mock.object, fieldName, returnFunction);
		}
		else
		{
			// Properties are simpler, just return the field.
			var fieldValue : Dynamic;
			
			switch(value)
			{
				case returnAction(v):
					fieldValue = v;
					
				case throwAction(v):
					fieldValue = v;
			}
			
			Reflect.setField(mock.object, fieldName, fieldValue);
		}
			
		return this;
	}
	
	/**
	 * Specifies that a field should throw an exception.
	 * @param	value Exception to throw.
	 * @return  The same context object for method chaining.
	 */
	public function throws(value : Dynamic) : MockSetupContext<T>
	{
		if (!isFunc)
			throw "throws() isn't allowed on properties.";
			
		return createConstraint(ConstraintAction.throwAction(value));

		/*
		var p : MockFriend = mock;
		var field = this.fieldName;
		
		p.addParams(field, new ParameterConstraint(value, parameters, isLazy));

		var thrower = Reflect.makeVarArgs(function(args : Array<Dynamic>) { 
			return p.parameterThrow(field, args) ? throw value : null;
		});
		
		Reflect.setField(mock.object, field, thrower);
		return this;
		*/
	}

	/**
	 * A callback method that is executed on field invocation, with method parameters as argument.
	 * @param	f A callback function
	 * @return  The same context object for method chaining.
	 */
	public function callBackArgs(f : Array<Dynamic> -> Void) : MockSetupContext<T>
	{
		if (!isFunc)
			throw "callBack() isn't allowed on properties.";
			
		// If no function is specified, create a default
		if (Reflect.field(mock.object, fieldName) == null)
			returns(null);
		
		callBacks.push(f);
		return this;		
	}

	/**
	 * A callback method that is executed on field invocation.
	 * @param	f A callback function
	 * @return  The same context object for method chaining.
	 */
	public function callBack(f : Void -> Void) : MockSetupContext<T>
	{
		return callBackArgs(function(args : Array<Dynamic>) { f(); } );
	}
}

private class MockObject implements Dynamic
{
	public function new(type : Class<Dynamic>, ?realObject : Dynamic)
	{
		if (realObject != null)
		{
			// A PHP workaround - Methods cannot be redefined on an object so a MockObject has to be created.
			for (field in Type.getInstanceFields(Type.getClass(realObject)))
			{
				Reflect.setField(this, field, Reflect.field(realObject, field));
			}			
		}
		else if (!Reflect.hasField(type, "__rtti"))
		{
			for (field in Type.getInstanceFields(type))
			{
				Reflect.setField(this, field, null);
			}
		}
		else
		{
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
}
