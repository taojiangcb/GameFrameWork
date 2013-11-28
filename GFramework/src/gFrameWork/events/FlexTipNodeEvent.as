package gFrameWork.events
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class FlexTipNodeEvent extends Event
	{
		
		/**
		 * tip的目标对像 
		 */		
		private var mTipNode:DisplayObject;
		
		public function FlexTipNodeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,tipNode:DisplayObject = null)
		{
			super(type, bubbles, cancelable);
			mTipNode = tipNode;
		}
		
		public function get tipNode():DisplayObject
		{
			return mTipNode;
		}
		
	}
}