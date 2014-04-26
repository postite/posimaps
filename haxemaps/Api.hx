@:expose("Mapi")
@:keepSub
class Api
{	
	public var pop:String="paf";
	static var _instance:Api;
	public var polo:Int=12;
	private function new()
	{
		trace("yo");
	}
	public static  inline function getInstance():Api
	{
		if (_instance==null) _instance=new Api();
		return _instance;
	}
	public  static function test()
	{
		return "op";
	}
	
}