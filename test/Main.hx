package ;

import haxe.rtti.Infos;
import mockingbird.macro.MacroUtil;
import neko.Lib;
import mockingbird.Mock;

import utest.MacroRunner;

/**
 * ...
 * @author Andreas Soderlund
 */

interface PointProto {
	var x : Int;
	var y : Int;
	function length() : Int;
	function lengthSquared(s : Int, s2 : Date) : Int;
	var isOk : Bool;
}
 
class Main 
{
	@:macro static function runTests()
	{
		return MacroRunner.run(new mockingbird.TestReturns());
	}

	static function main() 
	{
		Main.runTests();
		
		/*
		var mock = new Mock<PointProto>(PointProto);
		
		mock.setup(The.field(mock.object.y)).returns(40).callBack(function() { i++; } );
		mock.setup(The.field(mock.object.x)).returns(100).callBack(function() { i++; } );
		
		mock.setup(The.method(mock.object.lengthSquared)).returns(Date.now()).callBack(function() { i++; } );
		mock.setup(The.method(mock.object.length)).returns(null);
		
		mock.setup(The.method(function() { return "MOCK"; })).returns(Date.now()).callBack(function() { i++; } );
		mock.setup(The.field(mock.object.lengthSquared)).returns(Date.now()).callBack(function() { i++; } );
		
		test(mock.object);
		
		mock.verify(The.field(mock.object.lengthSquared), Times.AtLeastOnce());
		*/
	}

	/*
	static function test(p : PointProto)
	{
		trace(p.x);
		trace(p.y);
		trace(p.isOk);
		
		trace(p.lengthSquared(5, Date.now()));
		
		trace(p.x);
		p.x = 20;
		trace(p.x);
		
		trace(p.length());
		
		trace(i);
	}
	*/
}