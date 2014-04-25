import haxe.Timer;

class TTimer extends Timer{
    @:isVar public var prun(default,set):Void->Void;
    public var running:Bool;
    public var paused:Bool;
    var time:Int;
    // public function addEventListener(t:TimerEvent,fun:TimerEvent->Void){

    // }
    override public function run()
    {
        var t="p";
    }
    override public function new(time_ms : Int,?repeat:Int=0)
    {
        //trace(haxe.CallStack.callStack());
        super(time_ms);
        time=time_ms;
       // trace("new" );
    }
  	function set_prun(t:Void->Void):Void->Void{
        //trace(" prun="+t);
        run=t;
        running=true;
        return prun=t;
    }
    override public function stop(){
        super.stop();
        running=false;
    }
    public function pause(){
        running=false;
        paused=true;
        #if js
       untyped clearInterval(id);
        #end
        #if flash
        run = null;
        #end
    }
   public function unPause(){
    #if js
    if( paused) id = untyped setInterval(function() prun(),time);
    #end
        running=true;
        paused=false;
        run = prun;
    }
    public function start(){
       unPause();
    }
    
    
}

// class TTimerEvent{

// }