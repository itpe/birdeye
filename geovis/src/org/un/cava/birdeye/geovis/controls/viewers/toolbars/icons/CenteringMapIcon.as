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
 package org.un.cava.birdeye.geovis.controls.viewers.toolbars.icons
{
	public class CenteringMapIcon extends BaseIcon
	{
		public function CenteringMapIcon():void
		{
			super();
			width = IconsUtils.size;
			height = IconsUtils.size;
		}
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			with (graphics)
			{
				moveTo(IconsUtils.size/2,IconsUtils.size/2);
				beginFill(c,1);
				drawRect(0,0,IconsUtils.size, IconsUtils.size);
				endFill();
				
				moveTo(0,IconsUtils.size/2);
				lineStyle(2,IconsUtils.BLACK,1);
				lineTo(IconsUtils.size,IconsUtils.size/2);
		
				moveTo(IconsUtils.size/2,0);
				lineStyle(2,IconsUtils.BLACK,1);
				lineTo(IconsUtils.size/2,IconsUtils.size);
			}
		}
	}
}