package gFrameWork.extenders
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	
	import gFrameWork.GFrameWork;
	import gFrameWork.events.FlexTipNodeEvent;
	
	import mx.managers.IToolTipManagerClient;
	
	[Event(name="toolTipChanged", type="flash.events.Event")]
	public class FlexTooltipNode extends Sprite
	{
		/**
		 * tip信息 
		 */		
		private var mTip:String;
		
		/**
		 * 旧的tip信息  
		 */		
		private var mOldTip:String;
		
		public function FlexTooltipNode()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE,addToStageHandler,false,0,true);
		}
		
		private function addToStageHandler(event:Event):void
		{
			//removeEventListener(Event.ADDED_TO_STAGE,addToStageHandler);
			dispatch();
		}
		
		/**
		 *  @private
		 */
		public function set toolTip(value:String):void
		{
			mOldTip = mTip;
			mTip = value;
			if(stage)
			{
				dispatch();
			}
		}
		
		public function get toolTip():String
		{
			return mTip;
		}
		
		public function get oldTooltip():String
		{
			return mOldTip;
		}
		
		private function dispatch():void
		{
			if(stage)
			{
				stage.dispatchEvent(new FlexTipNodeEvent("toolTipChanged",false,false,this));
			}
		}
		
		
	}
}