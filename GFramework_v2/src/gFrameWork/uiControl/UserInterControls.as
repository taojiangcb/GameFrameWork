package gFrameWork.uiControl
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import gFrameWork.GFrameWork;
	import gFrameWork.IDisabled;
	import gFrameWork.JTinternal;
	
	import mx.core.EventPriority;
	
	use namespace JTinternal;
	
	public class UserInterControls extends EventDispatcher implements IDisabled
	{
		/**
		 * 标识ID  
		 */		
		public var mGUI_ID:uint = 0;
		
		/**
		 *  销毁清理的检测时间以毫秒为单位，如果此值为0时表示该UI不会被回收。
		 */		
		protected var mDieTime:uint = 60000;
		
		/**
		 * 清理检测的ID
		 */		
		protected var mDieInterID:uint = 0;

		/**
		 * GUI组件 
		 */		
		protected var mGUI:DisplayObject;
		
		/**
		 * 当前窗口的位置 
		 */		
		protected var mPosition:Point;
		
		/**
		 * 窗口当前的状态
		 */		
		public var state:uint = UIStates.NORMAL;
		
		/**
		 * 在打开当前UI界面时先下载相关的资源文件处理 
		 */		
		public var uiElementLoading:UIPreloader;
		
		/**
		 * 是否可以使用的标识
		 */		
		JTinternal var mCanUse:Boolean = false;
		
		
		public function UserInterControls()
		{
			
		}
		
		/**
		 * ui被打开显示后调用的数据刷新函数 
		 */		
		protected function openRefresh():void
		{
			
		}
		
		/**
		 * 初始化 
		 */		
		public function internalInit(gui:DisplayObject):void
		{
			if(!gui) throw new Error("gui 不能为空");
			mGUI = gui;
			uiElementLoading = new UIPreloader(this);
		}
		
		/**
		 * 添加到场景显示 
		 */		
		protected  function addToUiSpace():void
		{
			if(mGUI)
			{
				if(!mGUI)
				{
					getSpace().addChild(mGUI);
				}
				state = UIStates.SHOW;
			}
		}
		
		/**
		 * 从场景中移动当前UI显示
		 */		
		protected function removeFromeUiSpace():void
		{
			if(mGUI)
			{
				var guiParent:DisplayObjectContainer = mGUI.parent;
				if(guiParent)
				{
					guiParent.removeChild(mGUI);
				}
				
				if(mDieTime > 0)
				{
					clearTimeout(mDieInterID);
					mDieInterID = setTimeout(validateDieUI,mDieTime);
				}
			}
		}
		
		/**
		 * 
		 * 当前UI弹出后，验之鼠标当前点中碰撞的位置是否了生在UI之上。如果不在UI之上则有关闭UI显示的处理。 
		 * @param event
		 * 
		 */		
		protected function validatePopupClick(event:MouseEvent):void
		{
			if(mGUI.stage)
			{
				if(!mGUI.hitTestPoint(event.stageX,event.stageY))
				{
					UserInterfaceManager.close(mGUI_ID);
				}
			}
		}
		
		/**
		 * 
		 * 开启此UI,如果isPop为true时那下次鼠标点击没有在此UI的区域上则会关闭此UI
		 * @param isPop		//是否以弹出形显示开启此UI
		 * @param point		//开启时UI的显示位置
		 * 
		 */		
		public function show(isPop:Boolean = false,point:Point = null):void
		{
			if(mCanUse)
			{
				if(point)
				{
					mPosition = point;
				}
				else
				{
					if(!mPosition)
					{
						mPosition = new Point((getSpace().width - mGUI.width) / 2,(getSpace().height - mGUI.height) / 2);
					}
				}
				
				mPosition.x = Math.round(mPosition.x);
				mPosition.y = Math.round(mPosition.y);
				mGUI.x = mPosition.x;
				mGUI.y = mPosition.y;
				
				addToUiSpace();
				openRefresh();
				if(isPop)
				{
					getRoot().addEventListener(MouseEvent.CLICK,validatePopupClick,true,EventPriority.CURSOR_MANAGEMENT,true);			
				}
			}
			else
			{
				throw new Error("please call open function from JT_UserInterFaceManager");
			}
		}
		
		
		public function hide():void
		{
			if(mCanUse)
			{
				getRoot().removeEventListener(MouseEvent.CLICK,validatePopupClick);
				removeFromeUiSpace();
			}
			else
			{
				throw new Error("please call close function from JT_UserInterFaceManager");
			}
			
		}
		
		public function dispose():void
		{
			if(mGUI)
			{
				getRoot().removeEventListener(MouseEvent.CLICK,validatePopupClick,true);
				removeFromeUiSpace();
				
				if(uiElementLoading)
				{
					uiElementLoading.stopAndClear();
				}
				
				if(mGUI is IDisabled)
				{
					IDisabled(mGUI).dispose();
				}
				mGUI = null;
			}
		}
		
		/**
		 *
		 *  检测是否销毁此UI 
		 * 
		 */		
		protected function validateDieUI():void
		{
			if(state == UIStates.HIDE)
			{
				UserInterfaceManager.retireUI(mGUI_ID);
			}
		}
		
		/**
		 * ui 
		 * @return 
		 * 
		 */		
		public function getGui():DisplayObject
		{
			return mGUI;
		}
		
		/**
		 * ui的空间显示层 
		 * @return 
		 * 
		 */		
		public function getSpace():DisplayObjectContainer
		{
			return GFrameWork.getInstance().root;
		}
		
		/**
		 * 获取当前UI加载阶段时被指定的资源 
		 * @return 
		 * 
		 */		
		public function  getUiLoadFiles():Vector.<String>
		{
			return null;
		}
		
		protected function getRoot():DisplayObjectContainer
		{
			return GFrameWork.getInstance().root;
		}
		
		
		
	}
}