package gFrameWork.appDrag
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	
	/**
	 * 粘贴事件 
	 * @author JT
	 * 
	 */	
	
	public class AppDragEvent extends Event
	{
		
		/**
		 * 粘贴的对像 
		 */		
		public static const CLINGY:String = "clingy";
		
		
		/**
		 * 拖拽 
		 */		
		public static const DRAG:String ="drag";
		
		
		/**
		 * 移动的目标对像 
		 */		
		private var mTargetObj:DisplayObject = null;
		
		/**
		 * 移动的目标数据 
		 */		
		private var mItemObj:Object = null;
		
		/**
		 * 碰撞的坐标点 
		 */		
		private var mHitPoint:Point = null;
		
		
		public function AppDragEvent(type:String,targetObj:DisplayObject,itemObj:Object,hitPoint:Point,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			mTargetObj = targetObj;
			mItemObj = itemObj;
			mHitPoint = hitPoint;
		}
		
		public function get targetObj():DisplayObject
		{
			return mTargetObj;
		}
		
		public function get itemData():Object
		{
			return mItemObj;
		}
		
		public function get hitPoint():Point
		{
			return mHitPoint;
		}
		
	}
}