package umock;

/**
 * ...
 * @author Andreas Soderlund
 */

class MockException 
{
	public var message(default, null) : String;
	
	public function new(message : String)
	{
		this.message = message;
	}	
}