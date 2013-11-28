package com.uiComponents.icon
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import com.uiComponents.icon.BitblitComponent;
	import com.uiComponents.icon.BitblitData;
	
	import mx.core.IToolTip;
	
	/**
	 * 图标渲染控件 
	 * @author JiangTao
	 * 
	 */	
	public class BitblitICON extends BitblitComponent
	{
		
		/**
		 * 图标图位索引 
		 */		
		protected var index:Dictionary = new Dictionary(true);

		public function BitblitICON(bitblitData:BitblitData)
		{
			super(bitblitData);
			initialitionIndex();
		}
		
		private var _iconType:String = "";
		public function set iconType(value:String):void
		{
			_iconType = value;
			invalidateDrawn();
		}
		public function get iconType():String
		{
			return _iconType;
		}
		
		protected override function updateDrawn():void
		{
			if(bitmapData)
			{
				bitmapData.unlock();
				try
				{
					bitmapData.fillRect(new Rectangle(0,0,bitblit.width,bitblit.height),0x000000);
					bitmapData.copyPixels(bitblit.spriteSheet,new Rectangle(0,index[iconType]*bitblit.height,bitblit.width,bitblit.height),new Point(0,0));
				}
				catch(e:Error){}
				bitmapData.lock();
			}
		}
		
		/**
		 * 获取当前渲染的区域 
		 * @return 
		 * 
		 */		
		public function getBitmapData():BitmapData
		{
			return bitmapData;
		}

		/**
		 * 初始化图标占位索引 
		 */		
		protected function initialitionIndex():void
		{
			
		}
		
		public override function dispose():void
		{
			index = null;
			super.dispose();
		}
		
	}
}