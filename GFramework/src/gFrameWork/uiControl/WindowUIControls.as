package gFrameWork.uiControl
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
	import gFrameWork.JT_internal;

	public class WindowUIControls extends UserInterControls
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
		 * 关闭窗口时是否从可视列表中移除 
		 */		
		protected var mCanRemove:Boolean = false;
		
		
		/**
		 * 可接受鼠标托动的区域 
		 */		
		private var mDragArea:DisplayObject;
		
		
		/**
		 * 可以拖动的区域 
		 */		
		private var dragRectangel:Rectangle = null;
		
		
		/**
		 * 置顶执行的ID 
		 */		
		private var toHotID:int = 0;
		
		use namespace JT_internal;
		
		public function WindowUIControls()
		{
			super();
			mUIMutualID = DEFAULT_GROUP_ID;
			mUIMutualGroups = [DEFAULT_GROUP_ID];
		}
		
		public override function internalInit(gui:DisplayObject):void
		{
			super.internalInit(gui);
			mGUI.addEventListener(Event.ADDED_TO_STAGE,firstToStageHandler,false,0,true);
		}
		
		/**
		 * 第一次添加到主场景中时调用 
		 * @param event
		 * 
		 */		
		private function firstToStageHandler(event:Event):void
		{
			mGUI.removeEventListener(Event.ADDED_TO_STAGE,firstToStageHandler);
			if(mGUI.hasOwnProperty("dragArea"))
			{
				mDragArea = Object(mGUI).dragArea as DisplayObject;
				mGUI.addEventListener(MouseEvent.MOUSE_DOWN,theMouseDownHandler,false,0,true);
				dragRectangel = new Rectangle(getSpace().x,getSpace().y,getSpace().width - mGUI.width,getSpace().height - mGUI.height);
			}
		}
		
		/**
		 * 鼠标按下时处理，是拖拽窗口还是置顶窗口
		 * @param event
		 */		
		private function theMouseDownHandler(event:MouseEvent):void
		{
			if(mCanDrag && mDragArea && mDragArea.hitTestPoint(GFrameWork.getInstance().root.mouseX,GFrameWork.getInstance().root.mouseY))
			{
				//拖拽
				mGUI.stage.removeEventListener(MouseEvent.MOUSE_UP,dragStop);
				mGUI.stage.addEventListener(MouseEvent.MOUSE_UP,dragStop,false,0,true);
				Sprite(mGUI).startDrag(false,new Rectangle(getSpace().x,getSpace().y,getSpace().width - mGUI.width,getSpace().height - mGUI.height));
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
			getSpace().setChildIndex(mGUI,getSpace().numChildren - 1);
		}
		
		/**
		 * 停止拖拽 
		 * @param event
		 */		
		private function dragStop(event:MouseEvent):void
		{
			Sprite(mGUI).stopDrag();
			mPosition.x = mGUI.x;
			mPosition.y = mGUI.y;
		}
		
		/**
		 * 打开显示窗口 
		 */		
		public override function show(isPop:Boolean=false, point:Point=null):void
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
			if(mGUI)
			{
				if(!mGUI.parent)
				{
					getSpace().addChild(mGUI);
				}
				else
				{
					mGUI.visible = true;
				}
				state = UIStates.SHOW;
			}
			mGUI.alpha = 1;
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
				mGUI.removeEventListener(MouseEvent.MOUSE_DOWN,theMouseDownHandler);
				if(mGUI.stage)
				{
					mGUI.stage.removeEventListener(MouseEvent.MOUSE_UP,dragStop);
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
			if(state == UIStates.SHOW)
			{
				if(mGTween)
				{
					mGTween.paused = true;
					mGTween.target = null;
					mGTween = null;
				}
				mGTween = new GTween(mGUI,0.3,{alpha:0},{ease:Sine.easeOut});
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
			if(mGUI)
			{
				if(mCanRemove)
				{
					var guiParent:DisplayObjectContainer = mGUI.parent;
					if(guiParent)
					{
						guiParent.removeChild(mGUI);
					}
				}
				else 
				{
					mGUI.visible = false;
				}
			}
		}
	}
}