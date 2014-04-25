/*******************************************************************************
Copyright (c) 2010, Zdenek Vasicek (vasicek AT fit.vutbr.cz)
                    Marek Vavrusa  (marek AT vavrusa.com)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the organization nor the names of its
      contributors may be used to endorse or promote products derived from this
      software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE. 
*******************************************************************************/

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import map.Canvas;
import map.LngLat;
import map.MapService;
#if flash
import com.Button;

import com.ToolBar;
#end
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.geom.Point;
import map.Layer;
import map.QuadTree;
// #if flash
// import flash.utils.Timer;
// import flash.events.TimerEvent;
// #else
import TTimer in Timer;
//#end


class Example08 extends Sprite {

    var canvas:Canvas;
   #if flash var toolbar:ToolBar; #end
    var layer_osm:map.TileLayer;
    var vectorLayer:VectorLayer;
    var repere:LngLat;
    static public function main()
    { 
       flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
       var t:Example08 = new Example08();
       flash.Lib.current.stage.addEventListener(Event.RESIZE, t.stageResized);
       flash.Lib.current.stage.addChildAt(t,0);

    }


    function new()
    {
        super();
    this.addEventListener(Event.ADDED_TO_STAGE,function(e)trace("ADDED_TO_STAGE"));
       #if flash toolbar = new ToolBar();#end 
        canvas = new Canvas();


        #if flash toolbar.move(0, 0);#end
        canvas.move(0, 0);
        canvas.setCenter(new LngLat(15.5,49.5));
        layer_osm = new map.TileLayer(new OpenStreetMapService(12), 8);
      // canvas.addLayer(layer_osm);
          vectorLayer=new VectorLayer(new OpenStreetMapService(12));
          canvas.addLayer(vectorLayer);
           
        canvas.setZoom(-5);
        stageResized(null);

        addChild(canvas);

       #if flash initToolbar();  addChild(toolbar);#end

        canvas.initialize();
        canvas.sign.add(function(latlng:LngLat){

            trace("add"+latlng);
            repere=latlng;
            vectorLayer.addMock( latlng, new Mock() );
            Mock.click.add(onMockclick);
            });

        flash.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN,onKey);
        
    }
    function onMockclick(m:Mock)
    {
        trace(" onMockClick");
        var lay= new Layout();
        vectorLayer.addChild(lay);
        lay.x=m.x;
        lay.y=m.y;
    }
    function onKey(e:KeyboardEvent)

    {
        trace( "keydown"+repere);
        switch (e.keyCode) {
            case flash.ui.Keyboard.SPACE:
            trace("canvas.panTo");
            canvas.panTo(repere);
        }
    }

    public function stageResized(e:Event)
    {
        //trace("resize");
       #if flash  toolbar.setSize(flash.Lib.current.stage.stageWidth, 30); #end
        canvas.setSize(flash.Lib.current.stage.stageWidth, flash.Lib.current.stage.stageHeight);
    }
#if flash
    function initToolbar()
    {
        var me = this;
        toolbar.addButton(new ZoomOutButton(), "Zoom Out", function(b:CustomButton) { me.canvas.zoomOut(); });
        toolbar.addButton(new ZoomInButton(), "Zoom In",  function(b:CustomButton) { me.canvas.zoomIn(); });
        toolbar.addSeparator(30);

        //pan buttons
        toolbar.addButton(new UpButton(), "Move up",  function(b:CustomButton) { me.pan(1); });
        toolbar.addButton(new DownButton(), "Move down",  function(b:CustomButton) { me.pan(2); });
        toolbar.addButton(new LeftButton(), "Move left",  function(b:CustomButton) { me.pan(4); });
        toolbar.addButton(new RightButton(), "Move right",  function(b:CustomButton) { me.pan(8); });

        //layer buttons
        toolbar.addSeparator(50);
        var me = this;
        var tbosm = new TextButton("OSM Layer");
        tbosm.checked = true;
        toolbar.addButton(tbosm, "Open Street Map Layer",  
                          function(b:CustomButton) 
                          { 
                            tbosm.checked = !tbosm.checked;
                            if (tbosm.checked)
                               me.canvas.enableLayer(me.layer_osm); 
                            else 
                               me.canvas.disableLayer(me.layer_osm); 
                          });

    }
    #end

    function pan(direction:Int)
    {
        trace(" pan"+direction);
       var lt:LngLat = canvas.getLeftTopCorner();
       var br:LngLat = canvas.getRightBottomCorner();
       var p:LngLat  = canvas.getCenter();

       if (direction & 0x3 == 1) p.lat = lt.lat; //up
       if (direction & 0x3 == 2) p.lat = br.lat; //down
       if (direction & 0xC == 4) p.lng = lt.lng; //left
       if (direction & 0xC == 8) p.lng = br.lng; //right

       canvas.panTo(p);
    }

}



class VectorLayer extends Layer
{
    public var data:QuadTree;
    var ftimer:Timer;
    var mocks:Array<Mock>=[];
    public static var COLORS = [0xB2182B, 0xD6604D, 0xF4A582, 0xFDDBC7, 0xE0E0E0, 0xBABABA, 0x878787, 0x4D4D4D];
    public function addMock(ll:LngLat,m:Mock)
    {
        trace( "addMock");
        data.push(ll.lng,ll.lat,m);
        //mocks.push(m);
        trace(" mockslength"+mocks.length);
    }
    public function new(map_service:MapService = null)
    { 
        super(map_service, false);

        ftimer = new Timer(100, 1);
        ftimer.prun=redraw;
        

        //ftimer.addEventListener(TimerEvent.TIMER_COMPLETE, redraw);

        data = new QuadTree();
        for (i in 0...100000)
        {
            //trace(" p");
            var lng:Float = -30 + Math.random()*100;
            var lat:Float = Math.random()*80; 
            var clr:Int = Math.floor(Math.random()*8);
            var r:Int = 5 + (1 << Math.floor(i / 10000));
            data.push(lng,lat, {color: COLORS[clr], radius: r});
            //data.push(lng,lat, new Mock());
        }
    }

    function isMock(d:Dynamic):Bool
    {
        //return  ( d.radius==400);
        return ( Std.is (d,Mock));
    }

    override function updateContent(forceUpdate:Bool=false)
    {
        //trace( "updateContent");
        forceUpdate=true;
        if (ftimer.running)
           ftimer.pause();

        if (forceUpdate)
           redraw();
        else
           ftimer.start();
         
    }

    function redraw()
    {
        ftimer.pause();
       // trace( "redraw");
        
        var zz:Int = this.mapservice.zoom_def + this.zoom;
        var scale:Float = Math.pow(2.0, this.zoom);
        var l2pt = this.mapservice.lonlat2XY;

        #if neko
        var cpt:Point= null;
        if( center==null)
        cpt=new Point(0,0);
        else
        cpt = l2pt(center.lng, center.lat, zz);
        #else
        var cpt = l2pt(center.lng, center.lat, zz);
        #end
        var pt:Point;

        graphics.clear();
       
        var lt:LngLat = getLeftTopCorner();
        var rb:LngLat = getRightBottomCorner();

 	//var data:Array<QuadData> = data.getData(lt.lng, rb.lat, rb.lng, lt.lat);

        var minsz:Float = 1.0/scale;
        var presents=[];
        var data:Array<QuadData> = data.getFilteredData(lt.lng, rb.lat, rb.lng, lt.lat, function(q:QuadData):Bool { if( isMock(q.data)) presents.push(q.data); return q.data.radius > minsz;}); //return scale*q.data.radius > 0.8;});
         
         for (m in mocks){
            //trace( "mock in mocks"+m);
            if (!Lambda.has(presents,m)){
            m.kill();
            this.removeChild(m);
            mocks.remove(m);
            m=null;
            }
         }

    //trace( "data length="+data.length);
        var r:Float;
        for (d in data)
        {
            pt = l2pt(d.x, d.y, zz);
            r = scale*d.data.radius;

            if (isMock(d.data)){
            //trace("type="+ Type.typeof(d.data));
           //trace("" d.data.radius);
          
            var mock:Mock=cast d.data;
            if( !mock.actif){
            this.addChild(mock);
            mocks.push(mock);
            mock.active();
           
            }
             mock.x=pt.x- cpt.x;
            mock.y=pt.y-cpt.y;
            mock.scaleX=scale;
            mock.scaleY=scale;
            continue;
                    }
            
            
            graphics.lineStyle(r/2.0, d.data.color);
            graphics.drawRect((pt.x - cpt.x), (pt.y - cpt.y), r, r);
            
        }
        

    }
}
