package mockingbird;

import haxe.rtti.Infos;
import utest.Assert;

import mockingbird.Mock;
import mockingbird.TestAll;

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

		mock.verify(The.method(mock.object.length), Times.Never());
		Assert.raises(function() { mock.verify(The.method(mock.object.length), Times.Once()); }, MockException);
	}
	
	public function testEmptyObjectWithInfos()
	{
		var mock = new Mock<ITestInfos>(ITestInfos);

		mock.verify(The.method(mock.object.length), Times.Never());
		Assert.raises(function() { mock.verify(The.method(mock.object.length), Times.Once()); }, MockException);
	}
	
	public function testObjectVerify()
	{
		var mock = new Mock<ITest>(ITest);
		
		mock.setup(The.method(mock.object.length)).returns(123);
		
		mock.verify(The.method(mock.object.length), Times.Never());
		mock.verify(The.method(mock.object.length), Times.Exactly(0));
		
		mock.object.length();
		mock.verify(The.method(mock.object.length), Times.Once());
		mock.verify(The.method(mock.object.length), Times.AtMostOnce());
		mock.verify(The.method(mock.object.length), Times.AtLeastOnce());
		mock.verify(The.method(mock.object.length), Times.Exactly(1));
		
		mock.object.length();
		mock.verify(The.method(mock.object.length), Times.AtLeast(1));
		mock.verify(The.method(mock.object.length), Times.Exactly(2));
		mock.verify(The.method(mock.object.length), Times.AtLeast(2));
		mock.verify(The.method(mock.object.length), Times.AtMost(2));
		mock.verify(The.method(mock.object.length), Times.AtMost(3));

		Assert.raises(function() { mock.verify(The.method(mock.object.length), Times.Never()); }, MockException);
		Assert.raises(function() { mock.verify(The.method(mock.object.length), Times.Once()); }, MockException);
	}
	
	public function testObjectReturnsWithInfos()
	{
		var mock = new Mock<ITestInfos>(ITestInfos);		
		
		mock.setup(The.method(mock.object.length)).returns(123);
		
		mock.verify(The.method(mock.object.length), Times.Never());
		mock.verify(The.method(mock.object.length), Times.Exactly(0));
		
		mock.object.length();
		mock.verify(The.method(mock.object.length), Times.Once());
		mock.verify(The.method(mock.object.length), Times.AtMostOnce());
		mock.verify(The.method(mock.object.length), Times.AtLeastOnce());
		mock.verify(The.method(mock.object.length), Times.Exactly(1));
		
		mock.object.length();
		mock.verify(The.method(mock.object.length), Times.AtLeast(1));
		mock.verify(The.method(mock.object.length), Times.Exactly(2));
		mock.verify(The.method(mock.object.length), Times.AtLeast(2));
		mock.verify(The.method(mock.object.length), Times.AtMost(2));
		mock.verify(The.method(mock.object.length), Times.AtMost(3));
		
		Assert.raises(function() { mock.verify(The.method(mock.object.length), Times.Never()); }, MockException);
		Assert.raises(function() { mock.verify(The.method(mock.object.length), Times.Once()); }, MockException);		
	}
	
	public function testClassMock()
	{
		var mock = new Mock<MockMe>(MockMe);
		
		mock.setup(The.method(mock.object.message)).returns("call on me");
		
		mock.verify(The.method(mock.object.message), Times.Never());
		mock.verify(The.method(mock.object.message), Times.Exactly(0));
		
		mock.object.message();
		mock.verify(The.method(mock.object.message), Times.Once());
		mock.verify(The.method(mock.object.message), Times.AtMostOnce());
		mock.verify(The.method(mock.object.message), Times.AtLeastOnce());
		mock.verify(The.method(mock.object.message), Times.Exactly(1));
		
		mock.object.message();
		mock.verify(The.method(mock.object.message), Times.AtLeast(1));
		mock.verify(The.method(mock.object.message), Times.Exactly(2));
		mock.verify(The.method(mock.object.message), Times.AtLeast(2));
		mock.verify(The.method(mock.object.message), Times.AtMost(2));
		mock.verify(The.method(mock.object.message), Times.AtMost(3));
		
		Assert.raises(function() { mock.verify(The.method(mock.object.message), Times.Never()); }, MockException);
		Assert.raises(function() { mock.verify(The.method(mock.object.message), Times.Once()); }, MockException);		
	}
	
	public function testClassMockParams()
	{
		var mock = new Mock<MockMe>(MockMe);
		var aDate = Date.fromString("2010-01-01 00:00:00");

		// For verifying a method on an object, returns() must be called.
		mock.setup(The.method(mock.object.setDate)).returns(aDate);
		
		mock.verify(The.method(mock.object.setDate), Times.Never());
		mock.verify(The.method(mock.object.setDate), Times.Exactly(0));
		
		mock.object.setDate(Date.now());
		mock.verify(The.method(mock.object.setDate), Times.Once());
		mock.verify(The.method(mock.object.setDate), Times.AtMostOnce());
		mock.verify(The.method(mock.object.setDate), Times.AtLeastOnce());
		mock.verify(The.method(mock.object.setDate), Times.Exactly(1));
		
		mock.object.setDate(Date.now());
		mock.verify(The.method(mock.object.setDate), Times.AtLeast(1));
		mock.verify(The.method(mock.object.setDate), Times.Exactly(2));
		mock.verify(The.method(mock.object.setDate), Times.AtLeast(2));
		mock.verify(The.method(mock.object.setDate), Times.AtMost(2));
		mock.verify(The.method(mock.object.setDate), Times.AtMost(3));
		
		Assert.raises(function() { mock.verify(The.method(mock.object.setDate), Times.Never()); }, MockException);
		Assert.raises(function() { mock.verify(The.method(mock.object.setDate), Times.Once()); }, MockException);		
	}
}