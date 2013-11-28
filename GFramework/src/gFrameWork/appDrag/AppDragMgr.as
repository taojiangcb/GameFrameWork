package gFrameWork.appDrag
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * 
	 * 应用中对像移位交互的管理控制处理 
	 * @author JT
	 * 
	 */	
	public class AppDragMgr
	{
		/**
		 * 单例 
		 */		
		private static var mInstance:AppDragManager;
		
		/**
		 * 事件派发 
		 */		
		private static var eventDispatch:EventDispatcher;
		
		/**
		 * 鼠标粘贴
		 */		
		public static const CLINGY:int = 1;
		
		/**
		 * 鼠标拖拽 
		 */		
		public static const DRAG:int = 2;
		
		
		public function AppDragMgr()
		{
			
		}
		
		/**
		 * 要被移动的对像 
		 * @param targetObj			被移动的原型
		 * @param itemData			被移动的原型的数据
		 * @param dragImg			被移动时显示的图形,如果此值为空则以原型的外观复本显示
		 * @param mode				//移动的方式，1粘贴，2拖拽。
		 */		
		public static function clingyItem(targetObj:DisplayObject,
										  itemData:Object = null,
										  dragImg:DisplayObject = null,
										  mode:int = 1):void
		{
			instance.clingyItem(targetObj,itemData,dragImg,mode);
		}
		
		public static function addEventListener(type:String,callFunc:Function,useCapture:Boolean=false,priority:int = 0,useWeakReference:Boolean=false):void
		{
			edispatch.addEventListener(type,callFunc,useCapture,priority,useWeakReference);
		}
		
		public static function removeEventListener(type:String,listener:Function,useCapture:Boolean = false):void
		{
			edispatch.removeEventListener(type,listener,useCapture);
		}
		
		public static function dispatchEvent(event:AppDragEvent):void
		{
			edispatch.dispatchEvent(event);
		}
		
		private static function get instance():AppDragManager
		{
			if(!mInstance)
			{
				mInstance = new AppDragManager();
			}
			return mInstance;
		}
		
		private static function get edispatch():EventDispatcher
		{
			if(!eventDispatch)
			{
				eventDispatch = new EventDispatcher();
			}
			return eventDispatch;
		}
		
	}
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import gFrameWork.appDrag.AppDragEvent;
import gFrameWork.appDrag.AppDragMgr;


class AppDragManager
{
	
	/**
	 * 是否正在执行操作中 
	 */	
	private var mDragIn:Boolean = false;
	
	/**
	 * 正在粘住的对像 
	 */	
	private var mClingyDisplay:DisplayObject;
	
	/**
	 * 相关的数据信息 
	 */	
	private var mItemData:Object = null;
	
	/**
	 * 绘制当前被粘住的对像 
	 */	
	private var mDrawClingy:Sprite = null;
	
	
	private var mDelayID:int = 0;
	
	public function AppDragManager()
	{
		
	}
	
	/**
	 * 
	 * 鼠标移动目标对像 
	 * @param targetObj			被移动的原型
	 * @param itemData			被移动的原型的数据
	 * @param dragImg			被移动时显示的图形,如果此值为空则以原型的外观复本显示
	 * @param mode				移动的方式,1鼠标粘住，2鼠标拖拽
	 */ 	
	public function clingyItem(targetObj:DisplayObject,itemData:Object = null,dragImg:DisplayObject = null,mode:int = 1):void
	{
		if(mDragIn) return;
		if(targetObj)
		{
			if(mClingyDisplay == targetObj) return;
			mDragIn = true;
			mClingyDisplay = targetObj;
			mItemData = itemData;
			drawClingy(dragImg);
			if(mode == 1)
			{
				invlaidateListMouseClingy();
			}
			else
			{
				invalidateMouseDrag();
			}
		}
	}
	
	/**
	 * 拖拽处理 
	 */	
	private function invalidateMouseDrag():void
	{
		var func:Function = function():void
		{
			appMain.addEventListener(MouseEvent.MOUSE_UP,enterDragHandler,false,0,true);
		}
		
		if(mDelayID > 0)
		{
			clearTimeout(mDelayID);
			mDelayID = 0;
		}
		mDelayID = setTimeout(func,1000 / 24);
	}
	
	
	/**
	 *  
	 * 粘贴处理
	 */	
	private function invlaidateListMouseClingy():void
	{
		var func:Function = function():void
		{
			appMain.addEventListener(MouseEvent.CLICK,enterClingyHandler,false,0,true);
		}
		
		if(mDelayID > 0)
		{
			clearTimeout(mDelayID);
			mDelayID = 0;
		}
		mDelayID = setTimeout(func,1000 / 24);
	}
	
	/**
	 * 绘制被粘住的对像 
	 */	
	private function drawClingy(dragImg:DisplayObject):void
	{
		
		if(!mDrawClingy)
		{
			mDrawClingy = new Sprite();
			mDrawClingy.alpha = 0.5;
		}
		
		if(dragImg)
		{
			mDrawClingy.addChild(dragImg);
			mDrawClingy.x = appMain.mouseX - dragImg.width / 2;
			mDrawClingy.y = appMain.mouseY - dragImg.height / 2;
		}
		else
		{
			var bitData:BitmapData = new BitmapData(mClingyDisplay.width,mClingyDisplay.height,true,0);
			bitData.draw(mClingyDisplay);
			
			var bitMap:Bitmap = new Bitmap(bitData);
			
			mDrawClingy.addChild(bitMap);
			mDrawClingy.x = appMain.mouseX - dragImg.width / 2;
			mDrawClingy.y = appMain.mouseY - dragImg.height / 2;
		}
		
		mDrawClingy.startDrag();
		appMain.addChild(mDrawClingy);
		
	}
	
	/**
	 * 确认当前被击点的对像处理
	 * @param event
	 * 
	 */	
	private function enterClingyHandler(event:MouseEvent):void
	{
		var appDragEvent:AppDragEvent = new AppDragEvent(AppDragEvent.CLINGY,
			mClingyDisplay,
			mItemData,new Point(event.stageX,event.stageY));
		
		AppDragMgr.dispatchEvent(appDragEvent);
		
		if(mDrawClingy)
		{
			appMain.removeChild(mDrawClingy);
			mDrawClingy = null;
		}
		
		appMain.removeEventListener(MouseEvent.CLICK,enterClingyHandler);
		mClingyDisplay = null;
		mItemData = null;
		mDragIn = false;
	}
	
	/**
	 * 确认当前被拖拽的对像处理 
	 * @param event
	 * 
	 */	
	private function enterDragHandler(event:MouseEvent):void
	{
		var appDragEvent:AppDragEvent = new AppDragEvent(AppDragEvent.DRAG,
			mClingyDisplay,
			mItemData,new Point(event.stageX,event.stageY));
		
		AppDragMgr.dispatchEvent(appDragEvent);
		
		if(mDrawClingy)
		{
			appMain.removeChild(mDrawClingy);
			mDrawClingy = null;
		}
		
		appMain.removeEventListener(MouseEvent.MOUSE_UP,enterDragHandler);
		mClingyDisplay = null;
		mItemData = null;
		mDragIn = false;
	}
	
	private function get appMain():DisplayObjectContainer
	{
		return mClingyDisplay.stage;
	}
}