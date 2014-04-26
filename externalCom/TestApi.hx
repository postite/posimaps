
//import Api;


extern class Mapi{
	public static function test():String;
	public static function getInstance():#if display Api #else Dynamic #end;
}

class TestApi
{

	function new()
	{
		trace(" hello");
		trace(" ------------" +Mapi.getInstance().polo);
	}

	static public function main()
{
		var app = new TestApi();
	}
}