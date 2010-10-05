package umock;
import utest.Runner;

import haxe.rtti.Infos;

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
	var y(default, null) : Int;
	function length() : Int;
	function setDate(d : Date) : Int;
	var isOk : Bool;
	var e : MyEnum;
}

interface ITestInfos implements Infos {
	var x : Int;
	var y(default, null) : Int;
	function length() : Int;
	function setDate(d : Date) : Int;
	var isOk : Bool;
	var e : MyEnum;
}

class MockMe
{
	public var x : Int;
	public var publicD(default, null) : Date;
	
	var d : Date;
	
	public function new() { }
	
	public function setDate(d : Date)
	{
		this.d = d;
		this.publicD = d;
	}
	
	public function message()
	{
		return "message was called";
	}
}

class ClassImplementsInfos implements Infos
{
	public function new() { }
	
	public function normalMethod(a : Int)
	{
		return Std.string(a);
	}
}
 
class TestAll 
{
	public function new() 
	{
		
	}
	
	public function addTests(runner : Runner)
	{
		//runner.addCase(new TestReturns());
		runner.addCase(new TestVerify());
		runner.addCase(new TestCallback());
	}
}