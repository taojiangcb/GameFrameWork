package gFrameWork.tooltip
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;

	public class TooltipManager
	{
		
		private static var mInstance:TipMgr;
		
		
		//root;
		public static var rootStage:DisplayObjectContainer;
		
		public function TooltipManager()
		{
			
		}
		
		/**
		 * 注册一个Tip显示对像和内容 
		 * @param display
		 * @param tipData
		 * @param TipCls
		 * 
		 */		
		public static function registerTip(display:DisplayObject,tipData:Object,TipCls:Class=null):void
		{
			getInstance.registerTip(display,tipData,TipCls);
		}
		
		/**
		 * 注销一个Tip显示对像 
		 * @param display
		 * 
		 */		
		public static function unregisterTip(display:DisplayObject):void
		{
			getInstance.unregister(display);
		}
		
		private static function get getInstance():TipMgr
		{
			if(!mInstance)
			{
				mInstance = new TipMgr();
			}
			return mInstance;
		}
	}
}

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

import gFrameWork.IDisabled;

import gFrameWork.tooltip.DefaultTooltip;
import gFrameWork.tooltip.ITooltip;
import gFrameWork.tooltip.TooltipManager;



class TipMgr
{
	
	/**
	 * tip缓存列表 
	 */	
	private var tipItemDict:Dictionary;
	
	/**
	 * tip模板的引用计数器 
	 */	
	private var tipTempDict:Dictionary;
	
	
	public function TipMgr():void
	{
		tipItemDict = new Dictionary();
		tipTempDict = new Dictionary();
	}
	
	/**
	 * 注册一个Tooltip到显示对像 
	 * @param display		目标
	 * @param tipData		Tooltip数据
	 * @param TipCls		Tooltip的模板类
	 * 
	 */	
	public function registerTip(display:DisplayObject,tipData:Object,TipCls:Class=null):void
	{
		
		if(!display) return;
		if(!tipData) return;
		
		//设置当前要显示的模板类
		var tipTemp:TipTemp = TipCls ? getTipTemp(TipCls) : getTipTemp(DefaultTooltip);
		/*Tip显示项，包含可视交互对像，数据，Tip显示模板*/
		var tipItem:Object = new Object();
		
		//目标对像
		tipItem["target"] = display;
		//tooltip数据
		tipItem["data"] = tipData;
		//tooltip模板
		tipItem["temp"] = tipTemp;
		
		//缓存模板
		tipItemDict[display] = tipItem;
		listener(display);
	}
	
	/**
	 * 注销一个对像上的Tooltip 
	 * @param display
	 * 
	 */	
	public function unregister(display:DisplayObject):void
	{
		var tipItem:Object = tipItemDict[display];
		if(tipItem)
		{
			var tipTemp:TipTemp = tipItem["temp"];
			if(tipTemp.tipEntiy.parent)
			{
				if(TooltipManager.rootStage)
				{
					TooltipManager.rootStage.removeChild(tipTemp.tipEntiy as DisplayObject);
				}
			}
			tipTemp.removing();
			removeListener(display);
			delete tipItemDict[display];
			checkValidTemp(tipTemp);
		}
	}
	
	/**
	 * 检查有效的Tip显示模板，如果引用数为0的模板会直接剔除。 
	 * @param tipTemp
	 * 
	 */	
	private function checkValidTemp(tipTemp:TipTemp):void
	{
		if(tipTemp.count <= 0)
		{
			var clsName:String = getQualifiedClassName(tipTemp.tipEntiy);
			delete tipTempDict[clsName];
			tipTemp.dispose();
		}
	}
	
	/**
	 * 获取Tip的实体模版
	 * @param cls
	 * @return 
	 * 
	 */	
	private function getTipTemp(cls:Class):TipTemp
	{
		var clsName:String = getQualifiedClassName(cls);
		var tipTemp:TipTemp = null;
		if(tipTempDict[clsName])
		{
			tipTemp = tipTempDict[clsName] as TipTemp;
			tipTemp.count++
		}
		else
		{
			tipTemp = new TipTemp(cls);
			tipTempDict[clsName] = tipTemp;
		}
		return tipTemp;
	}
	
	/**
	 * 监听目标对像
	 * @param display
	 * 
	 */	
	private function listener(display:DisplayObject):void
	{
		var tipItem:Object = tipItemDict[display];
		if(tipItem)
		{
			display.addEventListener(MouseEvent.ROLL_OVER,rollOverHandler,false,0,true);
			display.addEventListener(MouseEvent.ROLL_OUT,rollOutHandler,false,0,true);
		}
	}
	
	/**
	 * 目标对像移除鼠标监听 
	 * @param display
	 * 
	 */	
	private function removeListener(display:DisplayObject):void
	{
		if(display)
		{
			display.removeEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
			display.removeEventListener(MouseEvent.ROLL_OUT,rollOutHandler);
		}	
	}
	
	private function rollOverHandler(event:MouseEvent):void
	{
		var display:DisplayObject = event.currentTarget as DisplayObject;
		var tipItem:Object = tipItemDict[display];
		showTipItem(tipItem);
	}
	
	private function rollOutHandler(event:MouseEvent):void
	{
		var display:DisplayObject = event.currentTarget as DisplayObject;
		var tipItem:Object = tipItemDict[display];
		hideTipItem(tipItem);
	}
	
	/**
	 * 显示Tooltip 
	 * @param tipItem
	 */	
	private function showTipItem(tipItem:Object):void
	{
		var root:DisplayObjectContainer = TooltipManager.rootStage;
		if(root)
		{
			var tipEntiy:ITooltip = tipItem["temp"].tipEntiy as ITooltip;
			if(tipEntiy)
			{
				tipEntiy.tip = tipItem["data"];
				tipEntiy.showTip();
			}
		}
	}
	
	/**
	 * 隐藏Tooltip 
	 * @param tipItem
	 * 
	 */	
	private function hideTipItem(tipItem:Object):void
	{
		var root:DisplayObjectContainer = TooltipManager.rootStage;
		if(root)
		{
			var tipEntiy:ITooltip = tipItem["temp"].tipEntiy as ITooltip;
			if(tipEntiy)
			{
				tipEntiy.hideTip();
			}
		}
	}
}

/**
 * TipCls的引用计数对像 
 * @author JT
 * 
 */
class TipTemp implements IDisabled
{
	/**
	 * Tip的实体对像 
	 */	
	public var tipEntiy:Object;
	/**
	 * Tip的引用计数器 
	 */	
	public var count:int = 0;
	
	public function TipTemp(tipCls:Class)
	{
		tipEntiy = new tipCls();
		count++;
	}
	
	public function removing():void
	{
		count--;
		if(count < 0)
		{
			count = 0;
		}
	}
	
	public function dispose():void
	{
		if(count == 0)
		{
			if(tipEntiy && tipEntiy is IDisabled)
			{
				IDisabled(tipEntiy).dispose();
				tipEntiy = null;
			}
		}
	}
	
}

