#if !display import flash.display.Sprite;#end

class Layout #if !display extends Sprite #end{

public function new()
{
	super();
	#if flash
	trace(" new");
	this.graphics.beginFill(0xcc3300);
	this.graphics.drawRect(0,0,400,400);
	#end 
	#if js
	var doc=js.Browser.document;
	var div=doc.createElement("div");
	div.innerHTML="<p>popopeozpozepoz</>";
	//div("popup");
	div.classList.add("popup");
	doc.body.appendChild(div);


	#end
}

public function display()
{
	
}


}