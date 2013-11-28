package com.uiComponents.image {
	
	import flash.display.MovieClip;
	import fl.containers.UILoader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Bitmap;
	import flide.events.FlexTipNodeEvent;

	public class Image extends UILoader 
	{
		private var mSource:Object = null;
		
		private var mIsSmoothing:Boolean = false;
		
		public function Image() 
		{
			super();
			addEventListener(Event.COMPLETE,loadPicComplete,false,0,true);
			addEventListener(Event.ADDED_TO_STAGE,addToStageHandler,false,0,true);			
		}
		private function addToStageHandler(event:Event):void
		{
			dispatch();		
			
		}
		
		private function loadPicComplete(event:Event):void
		{
			invalidate("smoothingChange");
		}
		
		protected override function draw():void
		{
			if(invalidHash["smoothingChange"])
			{
				validateSmoothing();
			}
			super.draw();
		}
		
		[Inspectable(name="source", type="String",defaultValue="")]
		public override function set source(value:Object):void
		{
			if(mSource == value)
			{
				return;
			}
			mSource = value;
			super.source = mSource;
		}
		
		public override function get source():Object
		{
			return mSource;
		}
		
		[Inspectable(defaultValue=true)]
		public function set smoothing(val:Boolean)
		{
			mIsSmoothing = val;
			invalidate("smoothingChange");
		}
		
		public function get smoothing():Boolean
		{
			return mIsSmoothing;
		}
		
		private function validateSmoothing():void
		{
			if(content)
			{
				var image:Bitmap = Bitmap(content);
				image.smoothing = smoothing;
			}
		}
		/**
		 * tip信息 
		 */		
		private var mTip:String;
		
		/**
		 * 旧的tip信息  
		 */		
		private var mOldTip:String;
		
		
		/**
		 *  @private
		 */
		 [Inspectable(name="toolTip", type="String",defaultValue="")]
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
