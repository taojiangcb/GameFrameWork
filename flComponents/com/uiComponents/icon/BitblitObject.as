package com.uiComponents.icon {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import gameLib_JT.components.JT_UIComponent;
	
	import com.uiComponents.icon.BitblitData;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;

	/**
	 * bitblitObject 位图渲染的基本对像
	 * 
	 * -------------------------------变量属性-------------------------------------
	 * bitblit:BitblitData
	 * 渲染的源数据
	 * 
	 * bitmapData:BitmapData
	 * 渲染对像的数据
	 * 
	 * bitblitSheet:Bitmap
	 * 渲染的显示对像
	 * 
	 * 
	 * --------------------------------方法------------------------------------------
	 * 
	 * get rect():Rectangle
	 * 获取显示对像的占用区域
	 * 
	 * dispose():void
	 * 释放用来存储 BitmapData 对象的内存。
	 * 
	 * colorTransform(rect: Rectangle, colorTransform: ColorTransform): void
	 * 使用 ColorTransform 对象调整位图图像的指定区域中的颜色值。
	 * 
	 * Stepixels(rect: Rectangle, inputByteArray: ByteArray): void
	 * 将字节数组转换为像素数据的矩形区域。
	 * 
	 * Stepixel32(x: int, y: int, color: uint): void
	 * 设置 BitmapData 对象单个像素的颜色和 Alpha 透明度值。
	 * 
	 * Stepixel(x:int, y:int, color:uint):void
	 * 设置 BitmapData 对象的单个像素。
	 * 
	 * fillRect(rect: Rectangle, color: uint): void
	 * 使用指定的 ARGB 颜色填充一个矩形像素区域。
	 * 
	 * updateDrawn():void
	 * 绘刷渲染的对像
	 * 
	 * invalidateDrawn():void
	 * 等待在刷新显示对像时处理
	 * 
	 * -updateEnterFrameHandler(event:Event):void
	 * 刷新显示对像的处理
	 * 
	 */
	public class BitblitObject extends JT_UIComponent
	{
		
		/**
		 * 渲染的源数据 
		 */		
		protected var bitblit:BitblitData = null;
		
		/**
		 * 当前渲染输出的显示块图位 
		 */		
		protected var bitblitSheet:Bitmap = null;
		
		/**
		 *当前渲染输出的显示数据源 
		 */		
		protected var bitmapData:BitmapData = null;
		
		/**
		 * 渲染块输入的数据源对像 
		 * @param _bitblitData
		 * 
		 */		
		public function BitblitObject(_bitblitData:BitblitData):void
		{
			super();
			bitblit = _bitblitData;
			width = bitblit.width;
			height = bitblit.height;
			addEventListener(FlexEvent.CREATION_COMPLETE, createCompleteHandler,false,0,true);
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			bitmapData = new BitmapData(bitblit.width,bitblit.height,true,0x00000000);
			bitblitSheet = new Bitmap(bitmapData,PixelSnapping.AUTO,true);
			addChild(bitblitSheet);
		}
		
		protected function createCompleteHandler(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, createCompleteHandler);
			invalidateDrawn();
		}
		
		public override function dispose():void 
		{
			
			removeEventListener(FlexEvent.CREATION_COMPLETE, createCompleteHandler);
			removeEventListener(Event.ENTER_FRAME,nextFrameHandler);
			
			if(bitblitSheet)
			{
				if(bitblitSheet.parent)
				{
					bitblitSheet.parent.removeChild(bitblitSheet);
				}
				bitblitSheet = null;
			}
			
			if(bitblit)
			{
				bitblit.dispose();
				bitblit = null;
			}
			
			if(bitmapData)
			{
				bitmapData.dispose();
				bitmapData = null;
			}
			
			super.dispose();
			
		}

		public function colorTransform(rect:Rectangle, colorTransform:ColorTransform):void 
		{
			bitmapData.colorTransform(rect, colorTransform);
		}

		public function setPixels(rect:Rectangle, inputByteArray:ByteArray):void 
		{
			bitmapData.setPixels(rect,inputByteArray);
		}

		public function setPixel32(x:int, y:int, color:uint):void 
		{
			bitmapData.setPixel32(x,y,color);
		}

		public function setPixel(x:int, y:int, color:uint):void 
		{
			bitmapData.setPixel(x,y,color);
		}

		public function fillRect(rect:Rectangle, color:uint):void 
		{
			bitmapData.fillRect(rect,color);	
		}
		
		/**
		 * 刷新绘制当前渲染输出块
		 */		
		protected function updateDrawn():void 
		{
			
		}

		/**
		 * 延迟刷新显示块 
		 */		
		public function invalidateDrawn():void 
		{
			addEventListener(Event.ENTER_FRAME,nextFrameHandler,false,0,true);
		}
		
		private function nextFrameHandler(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME,nextFrameHandler);
			updateDrawn();
		}
		
		public function get rect():Rectangle 
		{
			return new Rectangle(x,y,width,height);
		}
		
	} // end class
} // end package