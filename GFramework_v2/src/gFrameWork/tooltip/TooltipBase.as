package gFrameWork.tooltip
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.Sine;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	
	/**
	 * 被扩展的Tooltip显示对的基础类库 
	 * @author JT
	 * 
	 */	
	public class TooltipBase extends Sprite implements ITooltip
	{
		
		/**
		 * 显示的动画缓动 
		 */		
		private var mGTween:GTween;
		
		/**
		 * 移动时的ID 
		 */		
		private var mMoveInterID:int = 0;
		
		public function TooltipBase()
		{
			addEventListener(Event.ADDED_TO_STAGE,addToStageHandler,false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE,removeStageHandler,false,0,true);
		}
		
		private function addToStageHandler(event:Event):void
		{
			addMove();
		}
		
		private function removeStageHandler(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME,nextFrameHandler);
			clearMove();
		}
		
		/**
		 * Tip移动时的跟随的坐标位置定位处理 
		 */		
		protected function tipMove():void
		{
			var mx:int = stage.mouseX;
			var my:int = stage.mouseY;
			
			var dx:int = mx + 20;
			var dy:int = my + 20;
			
			if(dx + width > stage.stageWidth)
			{
				dx = mx - width - 20;
			}
			
			if(dy + height > stage.stageHeight)
			{
				dy = mx - height - 20;
			}
			
			x = dx;
			y = dy;
		}
		
		/**
		 * 去除移动跟随 
		 */		
		private function clearMove():void
		{
			if(mMoveInterID > 0)
			{
				clearInterval(mMoveInterID);
				mMoveInterID = 0;
			}
		}
		
		/**
		 * tip跟随鼠标移动控制 
		 */		
		private function addMove():void
		{
			var fps:Number = 1000 / stage.frameRate;
			if(mMoveInterID > 0)
			{
				clearInterval(mMoveInterID);
				mMoveInterID = 0;
			}
			mMoveInterID = setInterval(tipMove,fps);
		}
		
		/**
		 * 缓冲到下帧刷新显示 
		 */		
		private function invalidateUpdate():void
		{
			addEventListener(Event.ENTER_FRAME,nextFrameHandler,false,0,true);
		}
		
		private function nextFrameHandler(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME,nextFrameHandler);
			commitproperties();
			updateDisplay();
			tipMove();
		}
		
		/**
		 * 更新参数显示 
		 * 
		 */		
		protected function commitproperties():void
		{
		}
		
		/**
		 * 重新刷新或布局当前的显示对像 
		 * 
		 */		
		protected function updateDisplay():void
		{
		}
		
		/**
		 * 显示Tooltip 
		 * 
		 */		
		public function showTip():void
		{
			if(mGTween)
			{
				mGTween.paused = true;
				mGTween = null;
			}
			mGTween = new GTween(this,0.4,{alpha:1},{ease:Sine.easeOut});
			
			if(!parent)
			{
				invalidateUpdate();
				if(TooltipManager.rootStage)
				{
					TooltipManager.rootStage.addChild(this);
				}
			}
			else
			{
				addMove();
				invalidateUpdate();
			}
		}
		
		/**
		 * 隐藏Tip显示 
		 */		
		public function hideTip():void
		{
			if(mGTween)
			{
				mGTween.paused = true;
				mGTween = null;
			}
			mGTween = new GTween(this,0.4,{alpha:0},{ease:Sine.easeOut,onComplete:hideComplete});
			clearMove();
		}
		
		private function hideComplete(g:GTween):void
		{
			if(parent)
			{
				TooltipManager.rootStage.removeChild(this);
			}
		}
		
		public function dispose():void
		{
			removeEventListener(Event.ENTER_FRAME,nextFrameHandler);
			removeEventListener(Event.ADDED_TO_STAGE,addToStageHandler);
			removeEventListener(Event.REMOVED_FROM_STAGE,removeStageHandler);
			clearMove();
			
			if(mGTween)
			{
				mGTween.paused = true;
				mGTween.target = null;
				mGTween = null;
			}
			
			while(numChildren > 0)
			{
				removeChildAt(0);
			}
		}
		
		public function set tip(val:Object):void
		{
			
		}
		
		public function get tip():Object
		{
			return null;
		}
		
	}
}