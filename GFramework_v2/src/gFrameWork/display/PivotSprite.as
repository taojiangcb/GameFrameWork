package gFrameWork.display
{
	import flash.display.Sprite;
	
	import gFrameWork.IDisabled;
	
	/**
	 * 动态注册点可视显示对像 
	 * @author taojiang
	 * 
	 */	
	public class PivotSprite extends Sprite implements IDisabled
	{
		/**
		 * 注册点X 
		 */		
		private var mPiovtX:Number = 0;
		
		/**
		 * 注册点Y 
		 */		
		private var mPiovtY:Number = 0;
		
		/**
		 * 当前坐点X 
		 */		
		private var mX:Number = 0;
		
		/**
		 * 当前坐点Y 
		 */		
		private var mY:Number = 0;
		
		public function PivotSprite()
		{
			super();
			
			mouseChildren = false;
			mouseEnabled = false;
		}
		
		/**
		 * 注册点X 
		 * @param arg
		 * 
		 */		
		public function set piovtX(arg:Number):void
		{
			mPiovtX = arg;
			validateX();
		}
		
		/**
		 * 注册点x 
		 * @return 
		 * 
		 */		
		public function get piovtX():Number
		{
			return mPiovtX;
		}
		
		/**
		 * 注册点y 
		 * @param arg
		 * 
		 */		
		public function set piovtY(arg:Number):void
		{
			mPiovtY = arg;
			validateY();
		}
		
		/**
		 * 注册点y 
		 * @return 
		 * 
		 */		
		public function get piovtY():Number
		{
			return mPiovtY;
		}
		
		public override function set x(value:Number):void
		{
			mX = value;
			validateX();
		}
		
		public override function get x():Number
		{
			return mX;
		}
		
		public override function set y(value:Number):void
		{
			mY = value;
			validateY();
		}
		
		public override function get y():Number
		{
			return mY;
		}
		
		public override function set scaleX(value:Number):void
		{
			super.scaleX = value;
			validateX();
		}
		
		public override function set scaleY(value:Number):void
		{
			super.scaleY = value;
			validateY();
		}
		
		private function validateX():void
		{
			super.x = (mX - piovtX) * scaleX;
		}
		
		private function validateY():void
		{
			super.y = (mY - piovtY) * scaleY;
		}
		
		public function dispose():void
		{
			if(parent)
			{
				parent.removeChild(this);
			}
		}
	}
}
