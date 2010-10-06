package umock;

import haxe.rtti.Infos;
import utest.Assert;

import umock.Mock;
import umock.TestAll;

class TestVerify
{
	public function new() 
	{
		
	}
	
	public function setup()
	{
	}
	
	public function testVerifyEmptyObject()
	{
		var mock = new Mock<ITest>(ITest);

		mock.verify("length", Times.never());
		Assert.raises(function() { mock.verify("length", Times.once()); }, MockException);
		
		#if withmacro
		// Test if "The" works correctly.
		mock.verify(The.method(mock.object.length), Times.never());
		#end
	}
	
	public function testEmptyObjectWithInfos()
	{
		var mock = new Mock<ITestInfos>(ITestInfos);

		mock.verify("length", Times.never());
		Assert.raises(function() { mock.verify("length", Times.once()); }, MockException);
	}
	
	public function testObjectVerify()
	{
		var mock = new Mock<ITest>(ITest);
		
		mock.setupMethod("length").returns(123);
		
		mock.verify("length", Times.never());
		mock.verify("length", Times.exactly(0));
		
		mock.object.length();
		mock.verify("length", Times.once());
		mock.verify("length", Times.atMostOnce());
		mock.verify("length", Times.atLeastOnce());
		mock.verify("length", Times.exactly(1));
		
		mock.object.length();
		mock.verify("length", Times.atLeast(1));
		mock.verify("length", Times.exactly(2));
		mock.verify("length", Times.atLeast(2));
		mock.verify("length", Times.atMost(2));
		mock.verify("length", Times.atMost(3));

		Assert.raises(function() { mock.verify("length", Times.never()); }, MockException);
		Assert.raises(function() { mock.verify("length", Times.once()); }, MockException);
	}
	
	public function testObjectReturnsWithInfos()
	{
		var mock = new Mock<ITestInfos>(ITestInfos);		
		
		mock.setupMethod("length").returns(123);
		
		mock.verify("length", Times.never());
		mock.verify("length", Times.exactly(0));
		
		mock.object.length();
		mock.verify("length", Times.once());
		mock.verify("length", Times.atMostOnce());
		mock.verify("length", Times.atLeastOnce());
		mock.verify("length", Times.exactly(1));
		
		mock.object.length();
		mock.verify("length", Times.atLeast(1));
		mock.verify("length", Times.exactly(2));
		mock.verify("length", Times.atLeast(2));
		mock.verify("length", Times.atMost(2));
		mock.verify("length", Times.atMost(3));
		
		Assert.raises(function() { mock.verify("length", Times.never()); }, MockException);
		Assert.raises(function() { mock.verify("length", Times.once()); }, MockException);		
	}
	
	public function testClassMock()
	{
		var mock = new Mock<MockMe>(MockMe);
		
		mock.setupMethod("message").returns("call on me");
		
		mock.verify("message", Times.never());
		mock.verify("message", Times.exactly(0));
		
		mock.object.message();
		mock.verify("message", Times.once());
		mock.verify("message", Times.atMostOnce());
		mock.verify("message", Times.atLeastOnce());
		mock.verify("message", Times.exactly(1));
		
		mock.object.message();
		mock.verify("message", Times.atLeast(1));
		mock.verify("message", Times.exactly(2));
		mock.verify("message", Times.atLeast(2));
		mock.verify("message", Times.atMost(2));
		mock.verify("message", Times.atMost(3));
		
		Assert.raises(function() { mock.verify("message", Times.never()); }, MockException);
		Assert.raises(function() { mock.verify("message", Times.once()); }, MockException);		
	}
	
	public function testClassMockParams()
	{
		var mock = new Mock<MockMe>(MockMe);
		var aDate = Date.fromString("2010-01-01 00:00:00");

		// For verifying a method on an object, returns() must be called.
		mock.setupMethod("setDate").returns(aDate);
		
		mock.verify("setDate", Times.never());
		mock.verify("setDate", Times.exactly(0));
		
		mock.object.setDate(Date.now());
		mock.verify("setDate", Times.once());
		mock.verify("setDate", Times.atMostOnce());
		mock.verify("setDate", Times.atLeastOnce());
		mock.verify("setDate", Times.exactly(1));
		
		mock.object.setDate(Date.now());
		mock.verify("setDate", Times.atLeast(1));
		mock.verify("setDate", Times.exactly(2));
		mock.verify("setDate", Times.atLeast(2));
		mock.verify("setDate", Times.atMost(2));
		mock.verify("setDate", Times.atMost(3));
		
		Assert.raises(function() { mock.verify("setDate", Times.never()); }, MockException);
		Assert.raises(function() { mock.verify("setDate", Times.once()); }, MockException);		
	}
}