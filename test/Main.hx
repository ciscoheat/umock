package ;

import umock.TestAll;
import utest.MacroRunner;
import utest.Runner;

class Main 
{
	static function main() 
	{
		#if neko
		Main.runTests();
		#else
		var runner = new Runner();
		new TestAll().addTests(runner);
		utest.ui.Report.create(runner);
		runner.run();
		#end
	}
	
	@:macro static function runTests()
	{
		return MacroRunner.run(new umock.TestAll());
	}
}