package umock;

import haxe.rtti.Infos;
import utest.Assert;

import umock.Mock;
import umock.TestAll;

class TestParams
{
	public function new() 
	{
		
	}
	
	public function testSyntax()
	{
		var mock = new Mock<IParamReturn>(IParamReturn);
		
		mock.setupMethod("gimme").withParams(It.IsAny(String)).returns("1");
		mock.setupMethod("gimme").withParams(It.IsAny(String), 123).returns("123");
		mock.setupMethod("gimme").withParams(It.IsRegex(~/[0-9][A-Z][0-9]/), 1234).returns("1234");
		
		Assert.isNull(mock.object.gimme("Hello", 0));		
		Assert.isNull(mock.object.gimme("Hello", 1234));
		Assert.isNull(mock.object.gimme("1A2", 4321));
		
		Assert.equals("1", mock.object.gimme("Hello"));
		Assert.equals("123", mock.object.gimme("Hello", 123));
		Assert.equals("1234", mock.object.gimme("1A2", 1234));
	}
	
	public function testIsAnySort()
	{
		var mock = new Mock<IParamReturn>(IParamReturn);
		
		// Even though a IsAny is used, it should work with the more specific cases.
		mock.setupMethod("gimme").withParams("12").returns("12");
		mock.setupMethod("gimme").withParams(It.IsAny(String)).returns("1");
		mock.setupMethod("gimme").withParams("123").returns("123");
		
		Assert.equals("1", mock.object.gimme("Hello"));
		Assert.equals("123", mock.object.gimme("123"));
		Assert.equals("12", mock.object.gimme("12"));
	}
	
	public function testNull()
	{
		var mock = new Mock<IParamReturn>(IParamReturn);
		
		// Even though a IsAny is used, it should work with the more specific cases.
		mock.setupMethod("gimme").withParams(It.IsNull()).returns("null");
		mock.setupMethod("gimme").withParams("123", It.IsNull()).returns("123");
		
		Assert.equals("null", mock.object.gimme(null));
		Assert.equals("123", mock.object.gimme("123", null));
		
		// A limitation in optional arguments makes this return 123.
		// The prefered result would be null.
		Assert.equals("123", mock.object.gimme("123"));
	}
}