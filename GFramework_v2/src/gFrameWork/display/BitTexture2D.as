package gFrameWork.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * 位图贴图
	 * @author JT
	 * 
	 */	
	public class BitTexture2D
	{
		/**
		 * 位图数据源 
		 */		
		private var mBitSource:BitmapData;
		
		public function BitTexture2D(bitmapDrawable:IBitmapDrawable)
		{
			if(bitmapDrawable is BitmapData)
			{
				mBitSource = bitmapDrawable as BitmapData;
			}
			else if(bitmapDrawable is Bitmap)
			{
				mBitSource = Bitmap(bitmapDrawable).bitmapData;	
			}
			else
			{
				var displayObj:DisplayObject = DisplayObject(bitmapDrawable);
				mBitSource = new BitmapData(displayObj.width,displayObj.height,true,0);
				mBitSource.draw(displayObj);
			}
		}
		
		public function getRectBitmapData(rect:Rectangle):BitmapData
		{
			if(rect.x + rect.width > mBitSource.width || rect.y + rect.height > mBitSource.height)
			{
				throw new Error("Beyond the area.");
			}
			else
			{
				var bit:BitmapData = new BitmapData(rect.width,rect.height,true,0);
				bit.draw(mBitSource,null,null,null,rect);
				return bit;
			}
		}
		
		/**
		 * 切分到一维列表中 
		 * @param row					行数
		 * @param column				列数
		 * @param limited				限制的次数，如果此值 >0表示切分的次数，为0时不作限制。
		 * @return 
		 * 
		 */				
		public function splitterToArray(row:int,column:int,limited:int = 0):Vector.<BitmapData>
		{
			var count:int = 0;
			var sw:int = mBitSource.width / column;
			var sh:int = mBitSource.height / row;
			
			var i:int = 0;
			var j:int = 0;
			var bitList:Vector.<BitmapData> = null;
			
			for(i = 0; i < column; i++)
			{
				for(j = 0; j < row; j++)
				{
					count++;
					
					if(!bitList)
					{
						bitList = new Vector.<BitmapData>();
					}
					
					var rect:Rectangle = new Rectangle(i * sw,j * sh,sw,sh);
					var bitData:BitmapData = new BitmapData(rect.width,rect.height,true,0);
					bitData.copyPixels(mBitSource,rect,new Point(0,0));
					bitList.push(bitData);
					
					if(limited > 0 && count == limited)
					{
						return bitList;
					}
				}
			}
			return bitList;
		}
	}
}