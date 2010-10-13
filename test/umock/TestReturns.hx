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
	
	public function testEmptyObject()
	{
		var mock = new Mock<ITest>(ITest);

		Assert.isNull(mock.object.x);
		Assert.isNull(mock.object.y);
		Assert.isNull(mock.object.isOk);
		Assert.isNull(mock.object.e);
				
		// Calling methods on an object not implementing rtti.Infos throws an exception.
		// Javascript handles error in a different way and are not caught, but we can
		// at least test for null.
		#if !js
		Assert.raises(function() { mock.object.length(); }, String);
		Assert.raises(function() { mock.object.setDate(Date.now()); }, String);
		#else
		Assert.isNull(mock.object.length);
		Assert.isNull(mock.object.setDate);
		#end
	}

	#if !cpp
	public function testEmptyObjectWithInfos()
	{
		var mock = new Mock<ITestInfos>(ITestInfos);
		
		Assert.isNull(mock.object.x);
		Assert.isNull(mock.object.y);
		Assert.isNull(mock.object.isOk);
		Assert.isNull(mock.object.e);
		
		#if !php
		// Calling methods on an object implementing haxe.rtti.Infos is ok.
		// Unfortunately rtti.Infos does not work on php interfaces.
		Assert.isNull(mock.object.length());		
		mock.object.setDate(Date.now());
		#end
	}
	#end
	
	public function testClassWithInfos()
	{
		var mock = new Mock<ClassImplementsInfos>(ClassImplementsInfos);

		// If an object implements infos, umock should detect whether it's
		// an interface or a real object. So normal methods should be
		// callable.
		Assert.equals("123", mock.object.normalMethod(123));
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
		mock.setupField("y").returns(200);
		
		Assert.equals(200, mock.object.y);
		
		// Setting return value of a method
		mock.setupMethod("length").returns(300);		
		Assert.equals(300, mock.object.length());

		// If setup, the object method can be called.
		mock.setupMethod("setDate").returns(Void);
		mock.object.setDate(Date.now());
		
		mock.setupMethod("length").throws("Method exception!");
		Assert.raises(function() { mock.object.length(); }, String);

		// Throws cannot be set on fields.
		Assert.raises(function() { mock.setupField("y").throws("Field exception!"); }, String);

		#if withmacro
		// Testing if "The" works correctly
		mock.setup(The.field(mock.object.y)).returns(500);
		Assert.equals(500, mock.object.y);
		
		// Setting return value of a method
		mock.setup(The.method(mock.object.length)).returns(600);
		Assert.equals(600, mock.object.length());
		#end
	}
	
	#if !cpp
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
		mock.setupField("y").returns(200);
		
		Assert.equals(200, mock.object.y);
		
		// Setting return value of a method
		mock.setupMethod("length").returns(300);		
		Assert.equals(300, mock.object.length());

		// If setup, the object method can be called.
		mock.setupMethod("setDate").returns(Void);
		mock.object.setDate(Date.now());
		
		mock.setupMethod("length").throws("Method exception!");
		Assert.raises(function() { mock.object.length(); }, String);

		// Throws cannot be set on fields.
		Assert.raises(function() { mock.setupField("y").throws("Field exception!"); }, String);
	}
	#end
	
	public function testClassMock()
	{
		var mock = new Mock<MockMe>(MockMe);
		
		Assert.isNull(mock.object.x);
		Assert.equals("message was called", mock.object.message());
		
		// Setting a method on a real object is ok.
		mock.object.setDate(Date.now());
		
		mock.object.x = 100;
		Assert.equals(100, mock.object.x);
		
		mock.setupMethod("message").returns("call on me");
		Assert.equals("call on me", mock.object.message());
		
		mock.setupMethod("message").throws("Method exception!");
		Assert.raises(function() { mock.object.message(); }, String);

		// Throws cannot be set on fields.
		Assert.raises(function() { mock.setupField("x").throws("Field exception!"); }, String);
	}

	public function testNotLazyReturn()
	{
		var i = 20;
		var mock = new Mock<IMockFunction>(IMockFunction);
		
		mock.setupMethod("f").returns(function() { return ++i; } );
		
		Assert.equals(20, i);
		var output = mock.object.f();
		Assert.isTrue(Reflect.isFunction(output));
		Assert.equals(20, i);
		
		Assert.equals(21, output());
		Assert.equals(21, i);
	}
	
	public function testLazyReturn()
	{
		var i = 20;
		var mock = new Mock<MockMe>(MockMe);
		
		mock.setupMethod("message").returnsLazy(function() { return ++i; } );
		
		Assert.equals(20, i);
		Assert.equals(21, mock.object.message());
		Assert.equals(21, i);
	}
	
	public function testLazyThrow()
	{
		var i = 20;
		var mock = new Mock<MockMe>(MockMe);
		
		mock.setupMethod("message").throwsLazy(function() { return ++i; } );
		
		Assert.raises(function() { mock.object.message(); }, Int);
		Assert.equals(21, i);
	}
	
	public function testDefaultReturnValue()
	{
		var mock = new Mock<IParamReturn>(IParamReturn);
		
		mock.setupMethod("gimme").withParams("AAA", 4711).returns("67890");

		Assert.isNull(mock.object.gimme("WhatYouGot", 1337));

		// Set a default value (no withParams). From now on it should be returned 
		// when there is no match for the parameter constraints.
		mock.setupMethod("gimme").returns("12345");

		Assert.equals("12345", mock.object.gimme("WhatYouGot", 1337));
	}
}