/**
 *
 * UI控制管理
 *  
 */

package gFrameWork.uiControl
{
	import flash.geom.Point;
	
	import mx.core.UIComponent;

	public class UserInterfaceManager
	{
		
		/**
		 * 单例 
		 */		
		private static var mInstance:UserInternalManager;
		
		/**
		 * 开启某个UI显示 
		 * @param ui_id
		 * @param isPop
		 * @param position
		 * @return 
		 * 
		 */		
		public static function open(ui_id:uint,isPop:Boolean = false,position:Point = null):Boolean
		{
			return instance.open(ui_id,isPop,position);	
		}
		
		/**
		 * 关闭某个UI 
		 * @param ui_id
		 * @return 
		 * 
		 */		
		public static function close(ui_id:uint):Boolean
		{
			return instance.close(ui_id);	
		}
		
		/**
		 * 关闭已经打开的所有窗口UI 
		 * 
		 */		
		public static function closeAllWindow():void
		{
			instance.closeAllWindow();
		}
		
		/**
		 * 注册一个UI 
		 * @param ui_id
		 * @param uiCls
		 * @param controlCLS
		 * 
		 */		
		public static function registerGUI(ui_id:uint,uiCls:Class,controlCLS:Class):void
		{
			instance.registerUserUI(ui_id,uiCls,controlCLS);
		}
		
		/**
		 * 销毁一个UI实例 
		 * @param ui_id
		 * 
		 */		
		public static function retireUI(ui_id:uint):void
		{
			instance.retireUI(ui_id);
		}
		
		/**
		 * 获取一个UI控制 
		 * @param ui_id
		 * @return 
		 * 
		 */		
		public static function getUIByID(ui_id:uint):UserInterControls
		{
			return instance.getUIByID(ui_id);
		}
		
		/**
		 * UI排序 
		 */		
		public static function windowLayout():void
		{
			instance.windowLayout();
		}
		
		private static function get instance():UserInternalManager
		{
			if(!mInstance)
			{
				mInstance = new UserInternalManager();
			}
			return mInstance;
		}
		
		public function UserInterfaceManager()
		{
			
		}
	}
}

import com.gskinner.motion.GTween;
import com.gskinner.motion.GTweenTimeline;
import com.gskinner.motion.easing.Sine;

import flash.display.DisplayObjectContainer;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import gFrameWork.GFrameWork;
import gFrameWork.JTinternal;
import gFrameWork.uiControl.UIStates;
import gFrameWork.uiControl.UserInterControls;
import gFrameWork.uiControl.UserInterfaceManager;
import gFrameWork.uiControl.AppWindowUIController;

use namespace JTinternal;

class UserInternalManager
{
	
	/**
	 * 当前打开互斥的窗口ID
	 */	
	private var mCurUIMutualID:uint = 0;
	
	/**
	 * UI的实例列表 
	 */	
	private var guiTable:Dictionary;
	
	/**
	 * ui注册表 
	 */	
	private var mUIRegister:Dictionary;
	
	/**
	 * 窗口布局的动画过程
	 */	
	private var mGTweenLine:GTweenTimeline = new GTweenTimeline();
	
	/**
	 * 开启的UI窗口列表 
	 */	
	private var mOpenWindowList:Vector.<AppWindowUIController>;
	
	
	/**
	 * 启动GC的延迟时间 
	 */	
	private var mGCTimeOUTID:int = 0;
	
	
	public function UserInternalManager():void
	{
		guiTable = new Dictionary();
		mUIRegister = new Dictionary();
		
		mOpenWindowList = new Vector.<AppWindowUIController>();
		
	}
	
	/**
	 * 注册一个UI对像 
	 * @param ui_id
	 * @param uiCLS
	 * @param controlCLS
	 * 
	 */	
	public function registerUserUI(ui_id:uint,uiCLS:Class,controlCLS:Class):void
	{
		if(!mUIRegister[ui_id])
		{
			var uiRegister:UIRegister = new UIRegister();
			uiRegister.mUI_ID = ui_id;
			uiRegister.mUI_CLS = uiCLS;
			uiRegister.mUI_Control = controlCLS;
			mUIRegister[ui_id] = uiRegister;
		}
	}
	
	/**
	 * 销毁此UI 
	 * @param ui_id
	 */	
	public function retireUI(ui_id:uint):void
	{
		var gui:GUI = guiTable[ui_id];
		if(gui)
		{
			gui.mUI_Control.dispose();
			gui.mUI_Control = null;
			guiTable[ui_id] = null;
		}
		delete guiTable[ui_id];
	}
	

	/**
	 * //内存回收 
	 */	
	private function gc():void
	{
		if(mGCTimeOUTID > 0)
		{
			clearTimeout(mGCTimeOUTID);
			mGCTimeOUTID = 0;
		}
		mGCTimeOUTID = setTimeout(GFrameWork.getInstance().gc,3000);
	}
	
	
	/**
	 *  
	 * 开启某个UI显示，如果开启成功则返加 true 否则返回 false; 
	 * 
	 * @param ui_id		ui的id
	 * @param isPop		如果为true则表示弹出显示
	 * @param point		显示的位置
	 * @return 
	 * 
	 */	
	public function open(ui_id:uint,isPop:Boolean = false,point:Point=null):Boolean
	{
		var gui:GUI = retrievUIControlByID(ui_id);
		if(gui)
		{
			if(gui.mUI_Control.uiElementLoading.loadCount > 0)
			{
				gui.mUI_Control.uiElementLoading.beginLoad();
			}
			else
			{
				if(gui.mUI_Control.state != UIStates.SHOW)
				{
					//排斥关闭不相关的窗口
					if(gui.mUI_Control is AppWindowUIController)
					{
						var index:int = AppWindowUIController(gui.mUI_Control).mUIMutualGroups.indexOf(mCurUIMutualID);
						if(index <= -1)
						{
							closeByMutualID(mCurUIMutualID);
							mCurUIMutualID =  AppWindowUIController(gui.mUI_Control).mGUI_ID;
						}
					}
					
					gui.mUI_Control.mCanUse = true;
					gui.mUI_Control.show(isPop,point);
					gui.mUI_Control.state = UIStates.SHOW;
					gui.mUI_Control.mCanUse = false;
					
					//添加到窗口显示列表中去
					mOpenWindowList.push(gui);
					
				}
				else 
				{
					close(ui_id);
				}
			}
			return true;
		}
		return false;
	}
	
	/**
	 * 
	 * 关闭某个ui功能的显示 
	 * @param ui_id
	 * @return 
	 * 
	 */	
	public function close(ui_id:uint):Boolean
	{
		var gui:GUI = guiTable[ui_id];
		if(gui)
		{
			if(gui.mUI_Control.state == UIStates.SHOW)
			{
				gui.mUI_Control.mCanUse = true;
				gui.mUI_Control.hide();
				gui.mUI_Control.state = UIStates.HIDE;
				gui.mUI_Control.mCanUse = false;
				
				/*从开启的列表中删除此窗口对像*/
				var index:int = mOpenWindowList.indexOf(gui);
				if(index > -1)
				{
					mOpenWindowList.splice(index,1);
				}
			}
			return true;
		}
		return false;
	}
	
	/**
	 * 关闭当前已打开的所有窗口 
	 */	
	public function closeAllWindow():void
	{
		var ids:Array = [];
		var win:AppWindowUIController;
		for each(win in mOpenWindowList)
		{
			win.mCanUse = true;
			win.hide();
			win.state = UIStates.HIDE;
			win.mCanUse = false;
			ids.push(win.mGUI_ID);
		}
		
		while(ids.length > 0)
		{
			close(ids.shift());
		}
	}
	

	/**
	 * 
	 * 窗口排序布局 
	 * 
	 */	
	public function windowLayout():void
	{
		var rect:Rectangle = new Rectangle();
		var windows:Vector.<AppWindowUIController> = mOpenWindowList;
		var i:int = 0;
		if(windows.length > 0)
		{
			for(i = 0; i < windows.length; i++)
			{
				var window:AppWindowUIController = windows[i] as AppWindowUIController;
				rect.width += window.getGui().width;
				rect.height = window.getGui().height > rect.height ? window.getGui().height : rect.height;
			}
			
			var sp:Point = new Point(Math.round((getSpace().width - rect.width) / 2),Math.round((getSpace().height - rect.height) / 2));
			var growth:Number = 0;
			
			if(mGTweenLine)
			{
				mGTweenLine.paused = true;
				mGTweenLine = new GTweenTimeline();
			}
			
			for(i = 0; i < windows.length; i++)
			{
				if(i == 0)
				{
					mGTweenLine.addTween(0,new GTween(windows[i].getGui(),0.3,{x:sp.x,y:sp.y},{ease:Sine.easeOut}));
				}
				else
				{
					mGTweenLine.addTween(0,new GTween(windows[i].getGui(),0.3,{x:sp.x + growth,y:sp.y},{ease:Sine.easeOut}));
				}
				growth += windows[i].getGui().width;
			}
			
			mGTweenLine.calculateDuration();
			
		}
	}
	
	/**
	 * 
	 * 返回UI 
	 * @param ui_id
	 * @return 
	 * 
	 */
	public function getUIByID(ui_id:uint):UserInterControls
	{
		var gui:GUI = retrievUIControlByID(ui_id);
		if(gui)
		{
			return retrievUIControlByID(ui_id).mUI_Control;
		}
		else
		{
			return null;
		}
	}
	
	/**
	 * 
	 * 按照互斥ID关闭相关的窗口界面 
	 * @param id
	 * 
	 */	
	private function closeByMutualID(id:uint):void
	{
		var gui:GUI;
		for each(gui in guiTable)
		{
			if(gui.mUI_Control is AppWindowUIController)
			{
				var index:int = AppWindowUIController(gui.mUI_Control).mUIMutualGroups.indexOf(id);
				if(index > -1)
				{
					close(gui.mUI_ID);
				}
			}
		}
	}
	
	/**
	 * 按照ID取出UI 
	 * @param id
	 */	
	private function retrievUIControlByID(id:uint):GUI
	{
		if(guiTable[id])
		{
			return guiTable[id];
		}
		else
		{
			return initGUI(id);
		}
	}
	
	/**
	 * 
	 * 构建一个GUI 
	 * @param id
	 * @return 
	 * 
	 */	
	private function initGUI(id:uint):GUI
	{
		if(mUIRegister[id])
		{
			var theRegister:UIRegister = mUIRegister[id] as UIRegister;
			var gui:GUI = new GUI();
			gui.mUI_ID = id;
			gui.mUI_Control = new theRegister.mUI_Control();
			gui.mUI_Control.internalInit(new theRegister.mUI_CLS());
			gui.mUI_Control.mGUI_ID = id;
			guiTable[id] = gui;
			return gui;
		}
		else
		{
			return null;
		}
	}
	
	/**
	 * 获取窗口的父级容器
	 * @return 
	 */	
	private function getSpace():DisplayObjectContainer
	{
		return GFrameWork.getInstance().root;
	}
}

/**
 * UI的实例缓存对像 
 * @author JT
 * 
 */
class GUI
{
	public var mUI_ID:uint = 0;
	public var mUI_Control:UserInterControls;
}

/**
 * UI注册对像 
 * @author JT
 */
class UIRegister
{
	public var mUI_ID:uint = 0;
	public var mUI_CLS:Class = null;
	public var mUI_Control:Class = null;
}
