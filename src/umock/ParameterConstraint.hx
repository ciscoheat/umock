package umock;

import umock.Mock;

/**
 * ...
 * @author Andreas Soderlund
 */

class ParameterConstraint 
{
	public var parameters(default, null) : Array<Dynamic>;
	public var returns(default, null) : Dynamic;
	public var isLazy(default, null) : Bool;
	
	public function new(returns : Dynamic, parameters : Array<Dynamic>, isLazy : Bool)
	{
		this.parameters = parameters == null ? [] : parameters;
		this.returns = returns;
		this.isLazy = isLazy == true ? true : false;
	}
	
	private function returnValue() : Dynamic
	{
		return (isLazy && Reflect.isFunction(returns)) ? returns() : returns;
	}
	
	public function returnIfMatches(args : Array<Dynamic>) : Dynamic
	{
		if (parameters.length == 0)
		{
			//trace("No parameters.");
			return returnValue();
		}
		
		//trace("=== " + parameters.length + " - " + args.length);
		//trace(args);
		
		// If arguments to the method are less than the parameter constraints, it will fail.
		if (args.length < parameters.length) return null;
		
		for (i in 0 ... parameters.length)
		{
			if (Std.is(parameters[i], It))
			{
				//trace("It: " + args[i]);
				
				var it = cast(parameters[i], It);
				if (!it.matches(args[i])) 
				{
					//trace("Did not match.");
					return null;
				}
			}
			else if (parameters[i] != args[i])
			{
				//trace(parameters[i] + " != " + args[i]);
				return null;
			}
		}

		var output = returnValue();
		//trace("Returning: " + output);		
		return output;
	}	
}