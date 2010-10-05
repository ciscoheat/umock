package mockingbird;

import haxe.rtti.Infos;
import utest.Assert;

/**
 * ...
 * @author Andreas Soderlund
 */

enum MyEnum {
	First;
	Second(s : String);
}
 
interface ITest {
	var x : Int;
	var y : Int;
	function length() : Int;
	function setDate(s2 : Date) : Int;
	var isOk : Bool;
	var e : MyEnum;
}

interface ITestInfos implements Infos {
	var x : Int;
	var y : Int;
	function length() : Int;
	function setDate(s2 : Date) : Int;
	var isOk : Bool;
	var e : MyEnum;
}

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
}