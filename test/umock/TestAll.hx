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

interface IParamReturn {
	function gimme(s : String, ?i : Int) : String;
	function nullTest(s : String) : Int;
}

interface ITest {
	var x : Int;
	var y(default, null) : Int;
	function length() : Int;
	function setDate(d : Date) : Int;
	var isOk : Bool;
	var e : MyEnum;
}

#if !cpp
// C++ doesn't support interfaces that implements Infos
interface ITestInfos implements Infos {
	var x : Int;
	var y(default, null) : Int;
	function length() : Int;
	function setDate(d : Date) : Int;
	var isOk : Bool;
	var e : MyEnum;
}
#end

interface IMockFunction
{
	function f() : Void -> Int;
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
	public function messageNever() { return "never called ..."; }
	public function messageOnce() { return "once called ..."; }
	public function messageTwice() { return "twice called ..."; }
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
		runner.addCase(new TestReturns());
		runner.addCase(new TestVerify());
		runner.addCase(new TestCallback());
		runner.addCase(new TestParams());
	}
}