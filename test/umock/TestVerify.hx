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

		mock.verify(The.method(mock.object.length), Times.never());
		Assert.raises(function() { mock.verify(The.method(mock.object.length), Times.once()); }, MockException);
	}
	
	public function testEmptyObjectWithInfos()
	{
		var mock = new Mock<ITestInfos>(ITestInfos);

		mock.verify(The.method(mock.object.length), Times.never());
		Assert.raises(function() { mock.verify(The.method(mock.object.length), Times.once()); }, MockException);
	}
	
	public function testObjectVerify()
	{
		var mock = new Mock<ITest>(ITest);
		
		mock.setup(The.method(mock.object.length)).returns(123);
		
		mock.verify(The.method(mock.object.length), Times.never());
		mock.verify(The.method(mock.object.length), Times.exactly(0));
		
		mock.object.length();
		mock.verify(The.method(mock.object.length), Times.once());
		mock.verify(The.method(mock.object.length), Times.atMostOnce());
		mock.verify(The.method(mock.object.length), Times.atLeastOnce());
		mock.verify(The.method(mock.object.length), Times.exactly(1));
		
		mock.object.length();
		mock.verify(The.method(mock.object.length), Times.atLeast(1));
		mock.verify(The.method(mock.object.length), Times.exactly(2));
		mock.verify(The.method(mock.object.length), Times.atLeast(2));
		mock.verify(The.method(mock.object.length), Times.atMost(2));
		mock.verify(The.method(mock.object.length), Times.atMost(3));

		Assert.raises(function() { mock.verify(The.method(mock.object.length), Times.never()); }, MockException);
		Assert.raises(function() { mock.verify(The.method(mock.object.length), Times.once()); }, MockException);
	}
	
	public function testObjectReturnsWithInfos()
	{
		var mock = new Mock<ITestInfos>(ITestInfos);		
		
		mock.setup(The.method(mock.object.length)).returns(123);
		
		mock.verify(The.method(mock.object.length), Times.never());
		mock.verify(The.method(mock.object.length), Times.exactly(0));
		
		mock.object.length();
		mock.verify(The.method(mock.object.length), Times.once());
		mock.verify(The.method(mock.object.length), Times.atMostOnce());
		mock.verify(The.method(mock.object.length), Times.atLeastOnce());
		mock.verify(The.method(mock.object.length), Times.exactly(1));
		
		mock.object.length();
		mock.verify(The.method(mock.object.length), Times.atLeast(1));
		mock.verify(The.method(mock.object.length), Times.exactly(2));
		mock.verify(The.method(mock.object.length), Times.atLeast(2));
		mock.verify(The.method(mock.object.length), Times.atMost(2));
		mock.verify(The.method(mock.object.length), Times.atMost(3));
		
		Assert.raises(function() { mock.verify(The.method(mock.object.length), Times.never()); }, MockException);
		Assert.raises(function() { mock.verify(The.method(mock.object.length), Times.once()); }, MockException);		
	}
	
	public function testClassMock()
	{
		var mock = new Mock<MockMe>(MockMe);
		
		mock.setup(The.method(mock.object.message)).returns("call on me");
		
		mock.verify(The.method(mock.object.message), Times.never());
		mock.verify(The.method(mock.object.message), Times.exactly(0));
		
		mock.object.message();
		mock.verify(The.method(mock.object.message), Times.once());
		mock.verify(The.method(mock.object.message), Times.atMostOnce());
		mock.verify(The.method(mock.object.message), Times.atLeastOnce());
		mock.verify(The.method(mock.object.message), Times.exactly(1));
		
		mock.object.message();
		mock.verify(The.method(mock.object.message), Times.atLeast(1));
		mock.verify(The.method(mock.object.message), Times.exactly(2));
		mock.verify(The.method(mock.object.message), Times.atLeast(2));
		mock.verify(The.method(mock.object.message), Times.atMost(2));
		mock.verify(The.method(mock.object.message), Times.atMost(3));
		
		Assert.raises(function() { mock.verify(The.method(mock.object.message), Times.never()); }, MockException);
		Assert.raises(function() { mock.verify(The.method(mock.object.message), Times.once()); }, MockException);		
	}
	
	public function testClassMockParams()
	{
		var mock = new Mock<MockMe>(MockMe);
		var aDate = Date.fromString("2010-01-01 00:00:00");

		// For verifying a method on an object, returns() must be called.
		mock.setup(The.method(mock.object.setDate)).returns(aDate);
		
		mock.verify(The.method(mock.object.setDate), Times.never());
		mock.verify(The.method(mock.object.setDate), Times.exactly(0));
		
		mock.object.setDate(Date.now());
		mock.verify(The.method(mock.object.setDate), Times.once());
		mock.verify(The.method(mock.object.setDate), Times.atMostOnce());
		mock.verify(The.method(mock.object.setDate), Times.atLeastOnce());
		mock.verify(The.method(mock.object.setDate), Times.exactly(1));
		
		mock.object.setDate(Date.now());
		mock.verify(The.method(mock.object.setDate), Times.atLeast(1));
		mock.verify(The.method(mock.object.setDate), Times.exactly(2));
		mock.verify(The.method(mock.object.setDate), Times.atLeast(2));
		mock.verify(The.method(mock.object.setDate), Times.atMost(2));
		mock.verify(The.method(mock.object.setDate), Times.atMost(3));
		
		Assert.raises(function() { mock.verify(The.method(mock.object.setDate), Times.never()); }, MockException);
		Assert.raises(function() { mock.verify(The.method(mock.object.setDate), Times.once()); }, MockException);		
	}
}