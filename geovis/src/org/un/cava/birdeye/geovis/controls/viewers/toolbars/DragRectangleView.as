/* 
 * The MIT License
 *
 * Copyright (c) 2008
 * United Nations Office at Geneva
 * Center for Advanced Visual Analytics
 * http://cava.unog.ch
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
 
package org.un.cava.birdeye.geovis.controls.viewers.toolbars
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.Application;
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.geovis.core.Map;
	import org.un.cava.birdeye.geovis.events.MapEvent;
	import org.un.cava.birdeye.geovis.views.maps.world.WorldMap;
	
	public class DragRectangleView extends UIComponent
	{ 
	    private var map:Map;

		private var draggableRect:RectangleView;
		private var mapCopy:BitmapData;
		private var mapCopyCont:Bitmap;
		private var msk:Shape;
	    private var maskWidth:Number = NaN, maskHeight:Number = NaN;
		
		private var _scale:Number = 5;
		
		private var _backgroundColor:Number = RectUtils.BLACK;
		private var _borderColor:Number = RectUtils.RED;
		private var _dragRectangleColor:Number = RectUtils.YELLOW;
		private var _backgroundAlpha:Number = 0.5;
		private var _borderAlpha:Number = 0.5;
		private var _dragRectangleAlpha:Number = 0.5;
		
		private var _target:IBitmapDrawable;
		public function set target(val:IBitmapDrawable):void
		{
			_target = val;
		}
		
		public function get scale():Number
		{
			return _scale;
		}
		
		public function set backgroundColor(val:Number):void
		{
			_backgroundColor = val;
		}
		
		public function set borderColor(val:Number):void
		{
			_borderColor = val;
		}
		
		public function set dragRectangleColor(val:Number):void
		{
			_dragRectangleColor = val;
		}
		
		public function set backgroundAlpha(val:Number):void
		{
			if (val <= 1 && val >= 0)
				_backgroundAlpha = val;
		}

		public function set borderAlpha(val:Number):void
		{
			if (val <= 1 && val >= 0)
				_borderAlpha = val;
		}

		public function set dragRectangleAlpha(val:Number):void
		{
			if (val <= 1 && val >= 0)
				_dragRectangleAlpha = val;
		}

		/**
		 * Set the scale value. The final size of this controller will be based on the map size
		 * reduced by this value  
		 */
		public function set scale(val:Number):void
		{
			if (val >= 0)
				_scale = val;
		}

		public function DragRectangleView()
		{
			super(); 
		    Application.application.addEventListener(MapEvent.MAP_INSTANTIATED, init, true);
		    Application.application.addEventListener(MapEvent.MAP_CHANGED, init, true);
		}
		
		/**
		 * @Private
		 * Register the map object and calculate this.sizes  
		 */
		private function init(event:Event):void
		{
			// Add the resizing event handler.

			map = Map(event.target);
			
			if (!_target || _target == map.parent)
			{
				// calculate the this.width and this.height based on a scale of the original map size 
				width = map.width / scale;
				height = map.height / scale;
				drawAll();
			}
		}
	
		/**
		 * @Private
		 * Create draggableRect and its mask 
		 */
 		override protected function createChildren():void
		{
			super.createChildren();
			draggableRect = new RectangleView();
			
			msk = new Shape();
			draggableRect.mask = msk;
		}
		
		/**
		 * @Private
		 * Draw all graphics 
		 */
		private function drawAll():void
		{
			clearAll();
			
			// draw the rectangle mask so that the draggable rectangle 
			// is hidden when going out of the rectangle 
			msk.graphics.moveTo(0,0);
			msk.graphics.beginFill(0xffffff,0);
			msk.graphics.drawRect(0,0,width,height);
			msk.graphics.endFill();
			addChild(msk);

			// fill the rectangle 
			graphics.moveTo(0,0);
			graphics.beginFill(_backgroundColor,_backgroundAlpha);
			graphics.drawRect(0,0,width,height);
			graphics.endFill();

			var bmpSource:IBitmapDrawable;
			if (_target != null && _target is Map)
				bmpSource = Map(_target);
			else 
				bmpSource = map;

			// get the map-mask sizes, needed to size the draggable rectangle 
			var tempMask:DisplayObject = DisplayObject(map.mask);
			if (map.mask != null)
			{
				var maskBounds:Rectangle;
				maskBounds = map.mask.getBounds(map.mask);
				maskWidth = (maskBounds.width == 0) ? NaN : maskBounds.width;
				maskHeight = (maskBounds.height == 0) ? NaN : maskBounds.height;
			} else if (map.parent != null)
			{
				maskWidth = (map.parent.width == 0) ? NaN: map.parent.width;
				maskHeight = (map.parent.height == 0) ? NaN: map.parent.height;
			}
			
 			// map.mask must be temporarily set to null because otherwise the bitmapdata
 			// will cut the map on the top and left sides, probably because of a bug either 
 			// in the framework
 			map.mask = null;

			// create the bitmap of the map and scale using the scale property value 
			var sourceRect:Rectangle = new Rectangle(0,0,width,height);
			if (mapCopy != null)
				mapCopy.dispose();
			mapCopy = new BitmapData(sourceRect.width, sourceRect.height,true,0x000000);
			var matr:Matrix = new Matrix(1/scale,0,0,1/scale,0,0); 
			mapCopy.draw(map,matr,null,null,sourceRect,true);
			mapCopyCont = new Bitmap(mapCopy);
			addChild(mapCopyCont);
			map.mask = tempMask;

			// draws rectangle border  
			graphics.moveTo(0,0);
			graphics.lineStyle(2,_borderColor,_borderAlpha);
			graphics.lineTo(width,0);
			graphics.lineTo(width,height);
			graphics.lineTo(0,height);
			graphics.lineTo(0,0);
			
			draggableRect = new RectangleView();
			draggableRect.mask = msk;
			// calculate the draggableRect.width and draggableRect.height based on the original map-mask size
			// plus the scale property value and current map zoom value  
			var w:Number = maskWidth/map.zoom/scale;
			var h:Number = maskHeight/map.zoom/scale;
			draggableRect.graphics.moveTo(0,0);
			draggableRect.graphics.beginFill(_dragRectangleColor,_dragRectangleAlpha);
			if (!isNaN(maskWidth) && !isNaN(maskHeight))
				draggableRect.graphics.drawRect(0,0,w,h);
			else
				draggableRect.graphics.drawRect(0,0,width,height);
			draggableRect.graphics.endFill();

			draggableRect.width = w;
			draggableRect.height = h;
			draggableRect.x = Math.max(0,-map.x/map.zoom)/scale;
			draggableRect.y = Math.max(0,-map.y/map.zoom)/scale;
			draggableRect.addEventListener(RectangleView.DRAGGING, moveMap);
			addChild(draggableRect);

			// register listeners
			registerMapListeners();

			// if parent is the worldmap itself, than put this on top, so that it's viewable
			if (parent is WorldMap) 
				parent.setChildIndex(this, parent.numChildren-1);
 		}
 		
		/**
		 * @Private
		 * Register listeners 
		 */
		private function registerMapListeners():void
		{
			draggableRect.addEventListener(RectangleView.DRAGGING, moveMap);
			map.addEventListener(MapEvent.MAP_ZOOM_COMPLETE, updateValuesOnZoom);
			map.addEventListener(MapEvent.MAP_MOVING, updateValuesOnDragOrCentering);
		    map.addEventListener(MapEvent.MAP_CENTERED, updateValuesOnDragOrCentering);
		}

		/**
		 * @Private
		 * Remove and clear everything
		 */
 		private function clearAll():void
 		{
			for (var childIndex:Number = 0; childIndex <= numChildren-1; childIndex++)
				removeChildAt(childIndex);
			
			if (msk != null)
				msk.graphics.clear();
			graphics.clear();
			if (mapCopy != null)
				mapCopy.dispose();
			if (draggableRect != null)
				draggableRect.graphics.clear();
 		}

		/**
		 * @Private
		 * Move real map along with the rectangle dragging 
		 */
	    private function moveMap(e:Event):void
	    {
	    	var xPos:Number, yPos:Number;
	    	xPos = RectangleView(e.target).x;
	    	yPos = RectangleView(e.target).y;
	    	
	    	map.absoluteMoveMap(-xPos*scale*map.zoom,-yPos*scale*map.zoom);
	    }
	    
		/**
		 * @Private
		 * Update the zoom values according to the new map zoom value.
		 */
		private function updateValuesOnZoom(e:MapEvent):void
		{
			map = Map(e.target);
			if (isNaN(maskWidth) || isNaN(maskHeight)) {
				if (map.mask != null)
				{
					var maskBounds:Rectangle;
					maskBounds = map.mask.getBounds(map.mask);
					maskWidth = (maskBounds.width == 0) ? NaN : maskBounds.width;
					maskHeight = (maskBounds.height == 0) ? NaN : maskBounds.height;
				} else if (map.parent != null)
				{
					maskWidth = (map.parent.width == 0) ? NaN: map.parent.width;
					maskHeight = (map.parent.height == 0) ? NaN: map.parent.height;
				}
			}
			draggableRect.width = maskWidth/map.zoom/scale;
			draggableRect.height = maskHeight/map.zoom/scale;
			draggableRect.x = -map.x/map.zoom/scale;
			draggableRect.y = -map.y/map.zoom/scale;
		}
		
		/**
		 * @Private
		 * Update the position values according to the new map positioning.
		 */
		private function updateValuesOnDragOrCentering(e:MapEvent):void
		{
			map = Map(e.target);
			if (isNaN(maskWidth) || isNaN(maskHeight)) {
				if (map.mask != null)
				{
					var maskBounds:Rectangle;
					maskBounds = map.mask.getBounds(map.mask);
					maskWidth = (maskBounds.width == 0) ? NaN : maskBounds.width;
					maskHeight = (maskBounds.height == 0) ? NaN : maskBounds.height;
				} else if (map.parent != null)
				{
					maskWidth = (map.parent.width == 0) ? NaN: map.parent.width;
					maskHeight = (map.parent.height == 0) ? NaN: map.parent.height;
				}
			}
			draggableRect.x = -map.x/map.zoom/scale;
			draggableRect.y = -map.y/map.zoom/scale;
		}
	}
}


import mx.core.UIComponent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.display.Sprite;
import flash.events.Event;

class RectangleView extends Sprite
{
	// Offset positions used when moving the rectanlge inside the container on dragging/dropping
    private var offsetX:Number, offsetY:Number;
    // Keep the starting point position when dragging, if mouse goes out of the parents' view
    // than the toolbar will be repositioned to this point
    private var startDraggingPoint:Point;
    
    public static const DRAG_COMPLETE:String = "Rectangle drag completed"; 
    public static const DRAGGING:String = "Rectangle being dragged"; 

	public function RectangleView():void
	{
		super();
		addEventListener(MouseEvent.MOUSE_DOWN, moveRectangle);
	}
	
	// Resize panel event handler.
	public  function moveRectangle(event:MouseEvent):void
	{
  		startMovingRectangle(event);
  		stage.addEventListener(MouseEvent.MOUSE_UP, stopMovingRectangle);
	}
	
	// Start moving the toolbar
    private function startMovingRectangle(e:MouseEvent):void
    {
    	startDraggingPoint = new Point(this.x, this.y);
    	offsetX = e.stageX - this.x;
    	offsetY = e.stageY - this.y;
    	stage.addEventListener(MouseEvent.MOUSE_MOVE, dragRectangle);
    }
    
    // Stop moving the toolbar 
    private function stopMovingRectangle(e:MouseEvent):void
    {
    	stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragRectangle)
  		stage.removeEventListener(MouseEvent.MOUSE_UP, stopMovingRectangle);
  		dispatchEvent(new Event(RectangleView.DRAG_COMPLETE));
    }
    
    // Moving the toolbar while MOUSE_MOVE event is on
    private function dragRectangle(e:MouseEvent):void
    {
    	this.x = e.stageX - offsetX;
    	this.y = e.stageY - offsetY;
     	e.updateAfterEvent();
    	// dispatch moved toolbar event
  		dispatchEvent(new Event(RectangleView.DRAGGING));
    }
}

class RectUtils 
{
	public static const GREY:Number = 0x777777;
	public static const WHITE:Number = 0xffffff;
	public static const YELLOW:Number = 0xffd800;
	public static const RED:Number = 0xff0000;
	public static const BLUE:Number = 0x009cff;
	public static const GREEN:Number = 0x00ff54;
	public static const BLACK:Number = 0x000000;
	
	public static const size:Number = 40;
	public static const thick:Number = 2;
}
