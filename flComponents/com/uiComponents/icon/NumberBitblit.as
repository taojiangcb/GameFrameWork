package com.uiComponents.icon
{
	
	import com.gskinner.motion.GTween;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import gameLib_JT.components.JT_UIComponent;
	
	import mx.events.TweenEvent;

	/**
	 * 数字渲染控件 
	 * @author JiangTao
	 * 
	 */	
	public class NumberBitblit extends JT_UIComponent
	{
		
		//----------------------------------属性变量------------------------------------
		
		/*渲染位图数据*/
		public var bitblit:BitblitData = null;
		
		//数据列表
		private var numList:Vector.<Bitmap>;
		
		//数字的值
		private var _value:String = "0";
		
		//各字符之间显示的附加像素数。如果为正值，则会在正常间距的基础上增加字符间距；如果为负值，则减小此间距。 默认值为 0.
		private var _letterSpacing:int = 0;
		
		//数据增量动画开关
		private var _easing:Boolean = false;
		
		//原来老的数值
		private var oldNumber:int = 0;
		
		//当前的数值
		private var _number:int = 0;
		
		//------------------内部构造-------------------
		public function NumberBitblit(bitblitData:BitblitData)
		{
			bitblit = bitblitData;
			numList = new Vector.<Bitmap>();
		}
		
		//---------------------------内部逻辑处理---------------------------------------
		/**
		 * 刷新绘制新的数字
		 */		
		protected function updateDrawn():void 
		{
			var n:int = _value.length;
			var bitmap:Bitmap;
			for(var i:int = 0;i< n;i++)
			{
				var number:int = int(_value.substr(i,1)) == 0 ? 10 : int(_value.substr(i,1));
				var bitmapData:BitmapData = new BitmapData(bitblit.width,bitblit.height,true,0);
				bitmap = new Bitmap(bitmapData,"auto",true);
				bitmapData.copyPixels(bitblit.spriteSheet,new Rectangle(0,(number-1)*bitblit.height,bitblit.width,bitblit.height),new Point());
				numList.push(bitmap);
				
				bitmap.x = i * (bitblit.width + letterSpacing);
				bitmap.y = 0;
				
				addChild(bitmap);
			}
		}
		
		public function invalidateDrawn():void 
		{
			clearNum();
			width = number.toString().length * bitblit.width + letterSpacing * (number.toString().length - 1);
			height = bitblit.height;
			
			addEventListener(Event.ENTER_FRAME,nextFrameHandler);
		}
		
		private function nextFrameHandler(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME,nextFrameHandler);
			try
			{
				updateDrawn();
			}
			catch(e:Error){}
		}
		
		/**
		 * 清除原来的数字 
		 */		
		private function clearNum():void
		{
			while(numList.length > 0)
			{
				if(numList[0].parent)
					numList[0].parent.removeChild(numList[0]);
				numList[0].bitmapData.dispose();
				numList.shift()
			}
		}
		
		/**
		 * 释放资源 
		 * 
		 */		
		public override function dispose():void
		{
			super.dispose();
			
			if(numList)
			{
				while(numList.length > 0)
				{
					if(numList[0].parent)
						numList[0].parent.removeChild(numList[0]);
					numList[0].bitmapData.dispose();
					numList.shift();
				}
				numList = null;
			}
			
			if(bitblit && bitblit.spriteSheet)
				bitblit.spriteSheet.dispose();
		}
		
		/**
		 * 数字量动画效果 
		 */		
		private function easingHandler():void
		{
			if(easing)
			{
				value = oldNumber;
				var gt:GTween = new GTween(this,0.3,{value:number});
				gt.onComplete = tweenEndHandler;
				gt.onChange = tweenUpdateHandler;
			}
			else
			{
				value = number;
				this.invalidateDrawn();	
			}
		}
		
		private function tweenUpdateHandler(gt:GTween):void
		{
			this.invalidateDrawn();	
		}
		
		private function tweenEndHandler(gt:GTween):void
		{
			oldNumber = value;
			gt.paused = true;
		}
		
		//---------------------------------相关的属性设定-------------------------------------
		
		/**
		 * 渲染的数字 
		 * @param num
		 */		
		public function set number(val:int):void
		{
			_number = val;
			easingHandler();
		}
		
		public function get number():int
		{
			return _number;
		}
		
		/**
		 * 当前渲染的值,只是内部调用 
		 * @param num
		 * 
		 */		
		private function set value(num:int):void
		{
			_value = Math.abs(num).toString();
		}
		
		private function get value():int
		{
			return int(_value);
		}
		
		/**
		 * 数字之间的水平间隔 
		 * @param value
		 */		
		public function set letterSpacing(value:int):void
		{
			_letterSpacing = value;
			invalidateDrawn();
		}
		
		public function get letterSpacing():int
		{
			return _letterSpacing;			
		}
		
		/**
		 * 数量增量的动画效果开关 
		 * @param value
		 * 
		 */		
		public function set easing(value:Boolean):void
		{
			_easing = value;
			easingHandler();
		}
		
		public function get easing():Boolean
		{
			return _easing;
		}
		
	}
}