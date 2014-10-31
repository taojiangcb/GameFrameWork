package gFrameWork.moudle
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.Sine;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import gFrameWork.GFrameWork;
	import gFrameWork.JTinternal;

	/**
	 * 模块应用控制器 
	 * @author JT
	 * 
	 */	
	public class UIWindowMoudle extends MoudleBase
	{
		
		/**
		 * 默认的UI组; 
		 */		
		public static const DEFAULT_GROUP_ID:uint = 0;
		
		/**
		 * 窗口是否可以拖拽 
		 */		
		private var mCanDrag:Boolean = true;
		
		/**
		 * 窗口是否在拖拽中 
		 */		
		private var mDraging:Boolean = true;
		
		/**
		 * 打开窗口和半闭窗口时的动画控制
		 */		
		private var mGTween:GTween;
		
		/**
		 * UI互斥组
		 */		
		public var mUIMutualGroups:Array = [];
		
		/**
		 * UI互斥ID 
		 */		
		public var mUIMutualID:uint = DEFAULT_GROUP_ID;
				
		/**
		 * 可接受鼠标托动的区域 
		 */		
		private var mDragArea:Rectangle;
		
		
		/**
		 * 可以拖动的区域 
		 */		
		private var dragRectangel:Rectangle = null;
		
		/**
		 * 置顶执行的ID 
		 */		
		private var toHotID:int = 0;
		
		use namespace JTinternal;
		
		public function UIWindowMoudle()
		{
			super();
			moudleType = MoudleType.WINDOW;
			mUIMutualID = DEFAULT_GROUP_ID;
			mUIMutualGroups = [DEFAULT_GROUP_ID];
		}
		
		protected override function internalInit():void
		{
			super.internalInit();
			
			if(moudleContent)
			{
				//鼠标拖拽
				mDragArea = new Rectangle(0,0,moudleContent.width,Math.min(35,moudleContent.height));
				moudleContent.addEventListener(MouseEvent.MOUSE_DOWN,theMouseDownHandler,false,0,true);
				dragRectangel = new Rectangle(getSpace().x,getSpace().y,getSpace().width - moudleContent.width,getSpace().height - moudleContent.height);
			}
		}
		
			
		/**
		 * 鼠标按下时处理，是拖拽窗口还是置顶窗口
		 * @param event
		 */		
		private function theMouseDownHandler(event:MouseEvent):void
		{
			var localPt:Point = new Point(event.localX,event.localY);
			
			if(mCanDrag 
				&& mDragArea 
				&& localPt.x >= mDragArea.x 
				&& localPt.x <= mDragArea.width 
				&& localPt.y >= mDragArea.y
				&& localPt.y <= mDragArea.height)
			{
				//拖拽
				moudleContent.stage.removeEventListener(MouseEvent.MOUSE_UP,dragStop);
				moudleContent.stage.addEventListener(MouseEvent.MOUSE_UP,dragStop,false,0,true);
				Sprite(moudleContent).startDrag(false,new Rectangle(getSpace().x,
					getSpace().y,
					getSpace().width - moudleContent.width,
					getSpace().height - moudleContent.height));
				hotDisplay();
			}
			else
			{
				hotDisplay();
			}
		}
		
		/**
		 * 置顶显示 
		 * 
		 */		
		public function hotDisplay():void
		{
			getSpace().setChildIndex(moudleContent,getSpace().numChildren - 1);
		}
		
		/**
		 * 停止拖拽 
		 * @param event
		 */		
		private function dragStop(event:MouseEvent):void
		{
			Sprite(moudleContent).stopDrag();
			mPosition.x = moudleContent.x;
			mPosition.y = moudleContent.y;
		}
		
		/**
		 * 打开显示窗口 
		 */		
		public override function show(isPop:Boolean=false, point:Point=null,data:Object = null):void
		{
			super.show();
			if(mDieInterID > 0)
			{
				clearTimeout(mDieInterID);
				mDieInterID = 0;
			}
		}
		
		/**
		 * 
		 * 添加到场景显示 
		 * 
		 */		
		protected override function addToUiSpace():void
		{
			if(moudleContent)
			{
				if(!moudleContent.parent)
				{
					getSpace().addChild(moudleContent);
				}
				state = MoudleStates.SHOW;
			}
			
			moudleContent.alpha = 1;
			
			if(toHotID > 0)
			{
				clearTimeout(toHotID);
				toHotID = 0;
			}
			toHotID = setTimeout(hotDisplay,1000 / 24);
		}
		
		
		/**
		 * 隐藏关闭窗口 
		 */		
		public override function hide():void
		{
			super.hide();
			GFrameWork.getInstance().root.stage.focus = GFrameWork.getInstance().root; 
		}
		
		/**
		 * 从场景中剔除此窗口的显示处理 
		 */		
		protected override function removeFromeUiSpace():void
		{
			if(mDragArea)
			{
				moudleContent.removeEventListener(MouseEvent.MOUSE_DOWN,theMouseDownHandler);
				if(moudleContent.stage)
				{
					moudleContent.stage.removeEventListener(MouseEvent.MOUSE_UP,dragStop);
				}
				else
				{
					dragStop(null);
				}
			}
			hideEffect();
		}
		
		/**
		 * 
		 * 关闭窗口时显示的动画效果 
		 * 
		 */		
		private function hideEffect():void
		{
			if(state == MoudleStates.SHOW)
			{
				if(mGTween)
				{
					mGTween.paused = true;
					mGTween.target = null;
					mGTween = null;
				}
				mGTween = new GTween(moudleContent,0.3,{alpha:0},{ease:Sine.easeOut});
				mGTween.onComplete = hideEffectEnd;
			}
			else
			{
				hideComplete();
			}
		}
		
		private function hideEffectEnd(g:GTween):void
		{
			g.paused = true;
			g.target = null;
			g = null;
			hideComplete();
		}
		
		/**
		 * 关闭窗口完成 
		 */		
		private function hideComplete():void
		{
			if(moudleContent)
			{
				var guiParent:DisplayObjectContainer = moudleContent.parent;
				if(guiParent)
				{
					guiParent.removeChild(moudleContent);
				}			
			}
		}
	}
}