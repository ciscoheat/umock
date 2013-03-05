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

	#if !cpp
	public function testEmptyObjectWithInfos()
	{
		var mock = new Mock<ITestInfos>(ITestInfos);

		mock.verify("length", Times.never());
		Assert.raises(function() { mock.verify("length", Times.once()); }, MockException);
	}
	#end
	
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
	
	#if !cpp
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
	#end
	
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
	
	public function testVerifyAll()
	{
		var mock = new Mock<MockMe>(MockMe);
		
		mock.setupMethod("messageNever")
			.returns("never called mock method...")
			.repeat.never();

		mock.setupMethod("messageOnce")
			.returns("once called mock method...")
			.repeat.once();

		mock.setupMethod("messageTwice")
			.returns("twice called mock method...")
			.repeat.exactly(2);

		Assert.equals("once called mock method...", mock.object.messageOnce());
		Assert.equals("twice called mock method...", mock.object.messageTwice());
		Assert.equals("twice called mock method...", mock.object.messageTwice());
		
		mock.verifyAll();
	}
	
	public function testVerifyAllWithIncorrectRepeating()
	{
		var mock = new Mock<MockMe>(MockMe);
		
		mock.setupMethod("messageNever")
			.returns("should not never called mock method...")
			.repeat.never();

		mock.setupMethod("messageOnce")
			.returns("once called mock method...")
			.repeat.once();

		mock.setupMethod("messageTwice")
			.returns("twice called mock method...")
			.repeat.atLeast(2);

		Assert.equals("should not never called mock method...", mock.object.messageNever()); // <-- incorrect !
		Assert.equals("once called mock method...", mock.object.messageOnce());
		Assert.equals("twice called mock method...", mock.object.messageTwice());
		Assert.equals("twice called mock method...", mock.object.messageTwice());
		
		Assert.raises(function() { mock.verifyAll(); }, MockException);
	}
}