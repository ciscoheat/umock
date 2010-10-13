package umock;

import umock.Mock;

/**
 * ...
 * @author Andreas Soderlund
 */

enum ConstraintAction
{
	returnAction(v : Dynamic);
	throwAction(v : Dynamic);
}

class ParameterConstraint 
{
	public var parameters(default, null) : Array<Dynamic>;
	public var action(default, null) : ConstraintAction;
	public var isLazy(default, null) : Bool;
	
	public function new(action : ConstraintAction, parameters : Array<Dynamic>, isLazy : Bool)
	{
		this.parameters = parameters == null ? [] : parameters;
		this.action = action;
		this.isLazy = isLazy == true ? true : false;
	}
	
	private function returnValue() : Dynamic
	{
		switch(action)
		{
			case returnAction(v):
				return isLazy ? v() : v;
				
			case throwAction(v):
				throw isLazy ? v() : v;
		}		
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
		//trace(parameters);
		
		// If arguments to the method are less than the parameter constraints, it will fail.
		if (args.length < parameters.length) return null;
		
		for (i in 0 ... parameters.length)
		{
			//trace("Testing " + args[i]);

			if (Std.is(parameters[i], It))
			{
				var it = cast(parameters[i], It);
				if (!it.matches(args[i])) 
				{
					//trace("'It' did not match.");
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