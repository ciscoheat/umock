package ;

import haxe.rtti.Infos;
import neko.Lib;
import mockingbird.Mock;

/**
 * ...
 * @author Andreas Soderlund
 */

interface PointProto implements Infos {
	var x : Int;
	var y : Int;
	function length() : Int;
	function lengthSquared(s : Int, s2 : Date) : Int;
	var isOk : Bool;
}
 
class Main 
{
	static var i : Int = 0;
	
	static function main() 
	{
		var mock = new Mock<PointProto>(PointProto);
		
		mock.setup(The.field(mock.object.y)).returns(40).callBack(function() { i++; } );
		mock.setup(The.field(mock.object.x)).returns(100).callBack(function() { i++; } );
		mock.setup(The.field(mock.object.lengthSquared)).returns(Date.now()).callBack(function() { i++; } );
		
		test(mock.object);
	}
	
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
}