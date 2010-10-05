package umock;

import haxe.rtti.Infos;
import utest.Assert;

import umock.Mock;

import umock.TestAll;

class TestReturns 
{
	public function new() 
	{
		
	}
	
	public function setup()
	{
	}
	
	public function testEmptyObject()
	{
		var mock = new Mock<ITest>(ITest);

		Assert.isNull(mock.object.x);
		Assert.isNull(mock.object.y);
		Assert.isNull(mock.object.isOk);
		Assert.isNull(mock.object.e);
		
		// Calling methods on an object not implementing rtti.Infos throws an exception.
		Assert.raises(function() { mock.object.length(); }, String);
		Assert.raises(function() { mock.object.setDate(Date.now()); }, String);
	}
	
	public function testEmptyObjectWithInfos()
	{
		var mock = new Mock<ITestInfos>(ITestInfos);
		
		Assert.isNull(mock.object.x);
		Assert.isNull(mock.object.y);
		Assert.isNull(mock.object.isOk);
		Assert.isNull(mock.object.e);
		
		// Calling methods on an object implementing haxe.rtti.Infos is ok.
		Assert.isNull(mock.object.length());
		mock.object.setDate(Date.now());		
	}
	
	public function testObjectReturns()
	{
		var mock = new Mock<ITest>(ITest);
		
		// Setting a field directly
		mock.object.x = 100;
		mock.object.e = MyEnum.Second("mock");
		
		Assert.equals(100, mock.object.x);
		
		switch(mock.object.e)
		{
			case First:
				Assert.fail("Incorrect enum value.");
				
			case Second(s):
				Assert.equals("mock", s);
		}
		
		// Setting a getter-only is done through mock.setup()
		mock.setup(The.field(mock.object.y)).returns(200);
		
		Assert.equals(200, mock.object.y);
		
		// Setting return value of a method
		mock.setup(The.method(mock.object.length)).returns(300);		
		Assert.equals(300, mock.object.length());

		// If setup, the object method can be called.
		mock.setup(The.method(mock.object.setDate)).returns(Void);
		mock.object.setDate(Date.now());
	}
	
	public function testObjectReturnsWithInfos()
	{
		var mock = new Mock<ITestInfos>(ITestInfos);
		
		// Setting a field directly
		mock.object.x = 100;
		mock.object.e = MyEnum.Second("mock");
		
		Assert.equals(100, mock.object.x);
		
		switch(mock.object.e)
		{
			case First:
				Assert.fail("Incorrect enum value.");
				
			case Second(s):
				Assert.equals("mock", s);
		}
		
		// Setting a getter-only is done through mock.setup()
		mock.setup(The.field(mock.object.y)).returns(200);
		
		Assert.equals(200, mock.object.y);
		
		// Setting return value of a method
		mock.setup(The.method(mock.object.length)).returns(300);		
		Assert.equals(300, mock.object.length());

		// If setup, the object method can be called.
		mock.setup(The.method(mock.object.setDate)).returns(Void);
		mock.object.setDate(Date.now());
	}
	
	public function testClassMock()
	{
		var mock = new Mock<MockMe>(MockMe);
		
		Assert.isNull(mock.object.x);
		Assert.equals("message was called", mock.object.message());
		
		// Setting a method on a real object is ok.
		mock.object.setDate(Date.now());
		
		mock.object.x = 100;
		Assert.equals(100, mock.object.x);
		
		mock.setup(The.method(mock.object.message)).returns("call on me");
		Assert.equals("call on me", mock.object.message());
	}
}