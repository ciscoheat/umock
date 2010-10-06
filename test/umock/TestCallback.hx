package umock;

import haxe.rtti.Infos;
import utest.Assert;

import umock.Mock;
import umock.TestAll;

class TestCallback
{
	public function new() 
	{
		
	}
	
	public function setup()
	{
	}
	
	public function testCallbackEmpty()
	{
		var mock = new Mock<ITest>(ITest);
		var i = 0;

		// Cannot set callbacks on fields.
		Assert.raises(function() { mock.setupField("x").callBack(function() { i++; } ); }, String);
		
		mock.setupMethod("length").callBack(function() { i++; } );
		Assert.equals(0, i);
		mock.object.length();
		Assert.equals(1, i);
		mock.object.length();
		Assert.equals(2, i);
	}
}