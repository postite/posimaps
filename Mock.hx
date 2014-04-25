import flash.events.Event;
import flash.text.TextField;
import msignal.Signal.Signal1;
class Mock extends flash.display.Sprite{
	public var radius:Int=300;
	public var color:Int=0xB2182B;
	public var actif:Bool;
	var t:TextField;
	var count:Int=0;
	public static var click:Signal1<Mock>= new Signal1();
	public function new()
	{
		super();
		trace(" new");
		this.graphics.beginFill(0x00AAFF);
		this.graphics.drawRect(0,0,radius,radius);
		t= new TextField();
		this.addChild(t);
		t.text=Std.string(count);
		this.addEventListener(flash.events.MouseEvent.CLICK,onClick);
		//this.addEventListener(flash.events.Event.ENTER_FRAME,onframe);
	}

	function onClick(e:flash.events.MouseEvent)
	{
		//e.stopImmediatePropagation();
		
		click.dispatch(this);
	}
	function onframe(e:Event)
	{
		//this.rotation++;
		this.count=++count;
		t.text=Std.string(count);
	}
	public function active()
	{
		trace( "active");
		actif=true;
		this.addEventListener(flash.events.Event.ENTER_FRAME,onframe);
	}
	public function kill()
	{trace("kill");
	actif=false;
		this.removeEventListener(flash.events.Event.ENTER_FRAME,onframe);

	}
}