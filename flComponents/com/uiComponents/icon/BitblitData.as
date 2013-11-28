package com.uiComponents.icon
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	/**
	 * bitblitData 　位图渲染的基本数据
	 * 
	 * ------------------属性变量-------------------
	 * width 渲染的宽度
	 * height 渲染的高度
	 * spriteSheet:BitmapData渲染的位图的数据
	 */
	
	public class BitblitData
	{

		public var width:int;

		public var height:int;

		public var spriteSheet:BitmapData;
		
		public function BitblitData(refCls:Class,width:int,height:int) 
		{
			try
			{
				var displayObject:DisplayObject = DisplayObject(new refCls());
				
				var rect:Rectangle = new Rectangle();
				rect.width = displayObject.width == 0 ? width : displayObject.width;
				rect.height = displayObject.height == 0 ? height : displayObject.height;
				
				spriteSheet = new BitmapData(rect.width,rect.height,true,0x00000000);
				spriteSheet.draw(displayObject);
				this.width = width;
				this.height = height;
				displayObject = null;
			}
			catch(e:Error)
			{
				throw new Error("refCls is Not Bitbitmap");
			}
		}
		
		public function dispose():void
		{
			if(spriteSheet)
			{
				spriteSheet.dispose();
				spriteSheet = null;
			}
		}
		
	} // end class
} // end package