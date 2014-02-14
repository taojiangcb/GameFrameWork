package gFrameWork.uiModel
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
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
	
	/**
	 * 模块的基类 
	 * @author taojiang
	 * 
	 */	
	public class UIModelBase extends EventDispatcher implements IDisabled
	{
		
		/**
		 * 调用show时传入的函数 
		 */		
		private var openingData:Object = null;
		
		/**
		 * 是合被完全初始化过 
		 */		
		private var isInited:Boolean = false;
		
		/**
		 * UI类型 
		 */		
		public var modelType:uint = UIModelType.DEFAULT;
		
		/**
		 * 模块ID  
		 */		
		public var modeID:uint = 0;
		
		/**
		 * 窗口当前的状态
		 */		
		public var state:uint = UIModelStates.NORMAL;
		
		/**
		 * 在打开当前UI界面时先下载相关的资源文件处理 
		 */		
		public var preload:UIModelPreloader;
		
		
		/**
		 *  销毁清理的检测时间以毫秒为单位，如果此值为0时表示该UI不会被回收。
		 */		
		protected var mDieTime:uint = 60000;
		
		/**
		 * 清理检测的ID
		 */		
		protected var mDieInterID:uint = 0;

		/**
		 * 显示的模块的容器
		 */		
		protected var modelContent:DisplayObject;
		
		/**
		 * 当前窗口的位置 
		 */		
		protected var mPosition:Point;
		
		
		/**
		 * 是否可以使用的标识
		 */		
		JTinternal var mCanUse:Boolean = false;
		
		
		
		public function UIModelBase()
		{
			
		}
		
		/**
		 * ui被打开显示后调用的数据刷新函数 
		 */		
		protected function openRefresh():void
		{
			
		}
		
		/**
		 * 当前模块第一次调用show()函数的时候，会进入一个模块初始化过程中
		 */		
		protected function internalInit():void
		{
			modelContent = new Sprite();
			preload = new UIModelPreloader(this);
		}
		
		/**
		 * 添加到场景显示 
		 */		
		protected  function addToUiSpace():void
		{
			if(modelContent)
			{
				if(!modelContent)
				{
					getSpace().addChild(modelContent);
				}
				state = UIModelStates.SHOW;
			}
		}
		
		/**
		 * 从场景中移动当前UI显示
		 */		
		protected function removeFromeUiSpace():void
		{
			if(modelContent)
			{
				var guiParent:DisplayObjectContainer = modelContent.parent;
				if(guiParent)
				{
					guiParent.removeChild(modelContent);
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
			if(modelContent.stage)
			{
				if(!modelContent.hitTestPoint(event.stageX,event.stageY))
				{
					UIModelManager.close(modeID);
				}
			}
		}
		
		/**
		 *
		 *  检测是否销毁此UI 
		 * 
		 */		
		protected function validateDieUI():void
		{
			if(state == UIModelStates.HIDE)
			{
				UIModelManager.retireModel(modeID);
			}
		}
		
		/**
		 * 获取显示层级的根 
		 * @return 
		 * 
		 */		
		protected function getRoot():DisplayObjectContainer
		{
			return GFrameWork.getInstance().root;
		}

		
		/**
		 * 
		 * 开启此UI,如果isPop为true时那下次鼠标点击没有在此UI的区域上则会关闭此UI
		 * @param isPop		//是否以弹出形显示开启此UI
		 * @param point		//开启时UI的显示位置
		 * 
		 */		
		public function show(isPop:Boolean = false,point:Point = null,data:Object = null):void
		{
			
			openingData = data;
			
			if(mCanUse)
			{
				
				if(!isInited)
				{
					internalInit();
					isInited = true;
				}
				
				if(point)
				{
					mPosition = point;
				}
				else
				{
					if(!mPosition)
					{
						mPosition = new Point((getSpace().width - modelContent.width) / 2,(getSpace().height - modelContent.height) / 2);
					}
				}
				
				mPosition.x = Math.round(mPosition.x);
				mPosition.y = Math.round(mPosition.y);
				modelContent.x = mPosition.x;
				modelContent.y = mPosition.y;
				
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
			
			getRoot().removeEventListener(MouseEvent.CLICK,validatePopupClick,true);
			removeFromeUiSpace();
			
			if(preload)
			{
				preload.stopAndClear();
			}
			
			if(modelContent)
			{
				if(modelContent is IDisabled)
				{
					IDisabled(modelContent).dispose();
				}
				modelContent = null;
			}
		}
		
				
		/**
		 * 模块的显示的容器
		 * @return 
		 * 
		 */		
		public function getModelContent():DisplayObject
		{
			return modelContent;
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
		
		/**
		 * 是否完成初始化工作 
		 * @return 
		 */		
		public function get initialize():Boolean
		{
			return initialize;
		}		
		
	}
}