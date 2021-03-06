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
 
package org.un.cava.birdeye.qavis.charts.polarSeries
{
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.paint.SolidFill;
	
	import mx.collections.CursorBookmark;
	
	import org.un.cava.birdeye.qavis.charts.axis.PolarCoordinateTransform;
	import org.un.cava.birdeye.qavis.charts.data.DataItemLayout;
	import org.un.cava.birdeye.qavis.charts.interfaces.INumerableAxis;
	import org.un.cava.birdeye.qavis.charts.renderers.DiamondRenderer;

	public class PolarAreaSeries extends PolarSeries
	{
		private var _plotRadius:Number = 5;
		public function set plotRadius(val:Number):void
		{
			_plotRadius = val;
			invalidateDisplayList();
		}
		
		public function PolarAreaSeries()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();

			if (! itemRenderer)
				itemRenderer = DiamondRenderer;
		}

		protected var poly:Polygon;
		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override protected function drawSeries():void
		{
			var dataFields:Array = [];
			var items:Array = [];

			poly = new Polygon();
			poly.data = "";

			var angle:Number, radius:Number;

			gg = new DataItemLayout();
			gg.target = this;
			graphicsCollection.addItem(gg);

			cursor.seek(CursorBookmark.FIRST);
			while (!cursor.afterLast)
			{
				if (angleAxis)
				{
					angle = angleAxis.getPosition(cursor.current[angleField]);
					dataFields[0] = angleField;
				} else if (polarChart.angleAxis) {
					angle = polarChart.angleAxis.getPosition(cursor.current[angleField]);
					dataFields[0] = angleField;
				}
				
				if (radiusAxis)
				{
					radius = radiusAxis.getPosition(cursor.current[radiusField]);
					dataFields[1] = radiusField;
				} else if (polarChart.radiusAxis) {
					radius = polarChart.radiusAxis.getPosition(cursor.current[radiusField]);
					dataFields[1] = radiusField;
				}

				if (radarAxis)
				{
					angle = radarAxis.angleAxis.getPosition(cursor.current[angleField]);
					radius = INumerableAxis(radarAxis.radiusAxes[
										cursor.current[radarAxis.angleCategory]
										]).getPosition(cursor.current[radiusField]);
					dataFields[0] = angleField;
					dataFields[1] = radiusField;
				} else if (polarChart.radarAxis) {
					angle = polarChart.radarAxis.angleAxis.getPosition(cursor.current[angleField]);
					radius = INumerableAxis(polarChart.radarAxis.radiusAxes[
										cursor.current[polarChart.radarAxis.angleCategory]
										]).getPosition(cursor.current[radiusField]);
					dataFields[0] = angleField;
					dataFields[1] = radiusField;
				}

				var xPos:Number = PolarCoordinateTransform.getX(angle, radius, polarChart.origin);
				var yPos:Number = PolarCoordinateTransform.getY(angle, radius, polarChart.origin); 

				// if showdatatips than create a new GeometryGroup and set its 
				// tooltip along with the hit area and events
				createTTGG(cursor.current, dataFields, xPos, yPos, NaN, _plotRadius);
				
				items.push(cursor.current);

				poly.data += String(xPos) + "," + String(yPos) + " ";

 				cursor.moveNext();
			}
			
			if (poly.data)
			{
				poly.fill = fill;
				poly.stroke = stroke;
				gg.geometryCollection.addItem(poly);
			}
		}
	}
}