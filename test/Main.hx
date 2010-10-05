package ;

import utest.MacroRunner;

class Main 
{
	static function main() 
	{
		#if neko
		Main.runTests();
		#end
	}
	
	@:macro static function runTests()
	{
		return MacroRunner.run(new umock.TestAll());
	}
}