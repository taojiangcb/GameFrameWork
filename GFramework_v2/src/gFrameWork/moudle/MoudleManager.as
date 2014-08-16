/**
 *
 * UI控制管理
 *  
 */

package gFrameWork.moudle
{
	import flash.geom.Point;
	
	import mx.core.UIComponent;

	public class MoudleManager
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
		public static function open(modeID:uint,isPop:Boolean = false,position:Point = null,data:Object = null):Boolean
		{
			return instance.open(modeID,isPop,position,data);	
		}
		
		/**
		 * 关闭某个UI 
		 * @param modeID
		 * @return 
		 * 
		 */		
		public static function close(modeID:uint):Boolean
		{
			return instance.close(modeID);	
		}
		
		/**
		 * 根据moudle类型关闭所有的moudle
		 * 
		 */		
		public static function closeAllmoudle(moudleType:int):void
		{
			instance.closeAllByType(moudleType);
		}
		
		/**
		 * 注册一个UImoudle
		 * @param modeID
		 * @param uiCls
		 * @param controlCLS
		 * 
		 */		
		public static function registermoudle(modeID:uint,moudleCls:Class):void
		{
			instance.registermoudle(modeID,moudleCls);
		}
		
		/**
		 * 销毁一个UI实例 
		 * @param modeID
		 * 
		 */		
		public static function retiremoudle(modeID:uint):void
		{
			instance.retiremoudle(modeID);
		}
		
		/**
		 * 获取一个UI控制 
		 * @param modeID
		 * @return 
		 * 
		 */		
		public static function getmoudleByID(modeID:uint):MoudleBase
		{
			return instance.getmoudleByID(modeID);
		}
		
		/**
		 * 根据moudle类型和moudle的ID 
		 * @param type
		 * @param ids
		 * 
		 */				
		public static function moudleLayout(type:String,...ids):void
		{
			var parames:Array = [type];
			var i:int = 0;
			var len:int = ids.length;
			for(i = 0; i != len; i++)
			{
				parames.push(ids[i]);
			}
			instance.moudleLayout.apply(null,parames);
		}
		
		private static function get instance():UserInternalManager
		{
			if(!mInstance)
			{
				mInstance = new UserInternalManager();
			}
			return mInstance;
		}
		
		public function MoudleManager()
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
import gFrameWork.moudle.MoudleBase;
import gFrameWork.moudle.MoudleManager;
import gFrameWork.moudle.MoudleType;
import gFrameWork.moudle.MoudleStates;
import gFrameWork.moudle.UIWindowMoudle;

use namespace JTinternal;

class UserInternalManager
{
	
	/**
	 * 当前打开互斥的窗口ID
	 */	
	private var mCurUIMutualID:uint = 0;
	
	/**
	 * 模块的实例列表 
	 */	
	private var moudleTable:Dictionary;
	
	/**
	 * 模块注册表 
	 */	
	private var moudleRegister:Dictionary;
	
	/**
	 * 窗口布局的动画过程
	 */	
	private var mGTweenLine:GTweenTimeline = new GTweenTimeline();
	
	
	/**
	 * 启动GC的延迟时间 
	 */	
	private var mGCTimeOUTID:int = 0;
	
	
	/**
	 * 打开的UI模块 
	 */	
	private var openmoudles:Vector.<MoudleBase>
	
	
	public function UserInternalManager():void
	{
		moudleTable = new Dictionary();
		moudleRegister = new Dictionary();
		openmoudles = new Vector.<MoudleBase>();
	}
	
	/**
	 * 注册一个功能模块 
	 * @param modeID	//模块ID
	 * @param mCls		//模块启动类
	 * 
	 */
	public function registermoudle(modeID:uint,mCls:Class):void
	{
		if(!moudleRegister[modeID])
		{
			var register:UImoudleResiter = new UImoudleResiter();
			register.mID = modeID;
			register.moudleCls = mCls;
			moudleRegister[modeID] = register;
		}
	}
	
	/**
	 * 销毁一个功能模块 
	 * @param modeID
	 */	
	public function retiremoudle(modeID:uint):void
	{
		var moudle:moudleCache = moudleTable[modeID];
		if(moudle)
		{
			moudle.moudleBase.dispose();
			moudle.moudleBase = null;
			moudleTable[modeID] = null;
			delete moudleTable[modeID];
		}
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
	 * 开启某个moudle显示，如果开启成功则返加 true 否则返回 false; 
	 * 
	 * @param modeID	moudle的id
	 * @param isPop		如果为true则表示弹出显示
	 * @param point		显示的位置
	 * @return 
	 * 
	 */	
	public function open(modeID:uint,isPop:Boolean = false,point:Point=null,data:Object = null):Boolean
	{
		var moudle:moudleCache = retrievUIControlByID(modeID);
		if(moudle)
		{
			if(moudle.moudleBase.preload.loadCount > 0)
			{
				moudle.moudleBase.preload.beginLoad(isPop,point,data);
			}
			else
			{
				if(moudle.moudleBase.state != MoudleStates.SHOW)
				{
					//排斥关闭不相关的窗口
					if(moudle.moudleBase is UIWindowMoudle)
					{
						var index:int = UIWindowMoudle(moudle.moudleBase).mUIMutualGroups.indexOf(mCurUIMutualID);
						if(index <= -1)
						{
							closeByMutualID(mCurUIMutualID);
							mCurUIMutualID =  UIWindowMoudle(moudle.moudleBase).modeID;
						}
					}
					
					moudle.moudleBase.mCanUse = true;
					moudle.moudleBase.show(isPop,point,data);
					moudle.moudleBase.state = MoudleStates.SHOW;
					moudle.moudleBase.mCanUse = false;
					
					//添加到窗口显示列表中去
					openmoudles.push(moudle);
					
				}
				else 
				{
					close(modeID);
				}
			}
			return true;
		}
		return false;
	}
	
	/**
	 * 
	 * 关闭某个ui功能的显示 
	 * @param modeID
	 * @return 
	 * 
	 */	
	public function close(modeID:uint):Boolean
	{
		var moudle:moudleCache = moudleTable[modeID];
		if(moudle)
		{
			if(moudle.moudleBase.state == MoudleStates.SHOW)
			{
				moudle.moudleBase.mCanUse = true;
				moudle.moudleBase.hide();
				moudle.moudleBase.state = MoudleStates.HIDE;
				moudle.moudleBase.mCanUse = false;
				
				/*从开启的列表中删除此窗口对像*/
				var index:int = openmoudles.indexOf(moudle);
				if(index > -1)
				{
					openmoudles.splice(index,1);
				}
			}
			return true;
		}
		return false;
	}
	
	/**
	 * 按类型关掉所有的窗口 
	 * @param moudleType
	 * 
	 */	
	public function closeAllByType(moudleType:int):void
	{
		var ids:Array = [];
		var moudle:MoudleBase;
		for each(moudle in openmoudles)
		{
			if(moudle.moudleType == moudleType)
			{
				moudle.mCanUse = true;
				moudle.hide();
				moudle.state = MoudleStates.HIDE;
				moudle.mCanUse = false;
				ids.push(moudle.modeID);
			}
		}
	}
	

	/**
	 * 
	 * 窗口排序布局 
	 * 
	 */	
	public function moudleLayout(moudleType:int = MoudleType.WINDOW,...ids):void
	{
		var rect:Rectangle = new Rectangle();
		var moudles:Vector.<MoudleBase> = new Vector.<MoudleBase>();
		var i:int = 0,j:int = 0;
		var len:int = openmoudles.length;
		for(i; i != len; i++)
		{
		
			for(j=0; j != ids.length; j++)
			{
				if(openmoudles[i].moudleType == moudleType)
				{
					moudles.push(openmoudles[i]);
				}
			}
			
		
		}
		if(moudles.length > 0)
		{
			for(i = 0; i < moudles.length; i++)
			{
				var window:UIWindowMoudle = moudles[i] as UIWindowMoudle;
				rect.width += window.getmoudleContent().width;
				rect.height = window.getmoudleContent().height > rect.height ? window.getmoudleContent().height : rect.height;
			}
			
			var sp:Point = new Point(Math.round((getSpace().width - rect.width) / 2),Math.round((getSpace().height - rect.height) / 2));
			var growth:Number = 0;
			
			if(mGTweenLine)
			{
				mGTweenLine.paused = true;
				mGTweenLine = new GTweenTimeline();
			}
			
			for(i = 0; i < moudles.length; i++)
			{
				if(i == 0)
				{
					mGTweenLine.addTween(0,new GTween(moudles[i].getmoudleContent(),0.3,{x:sp.x,y:sp.y},{ease:Sine.easeOut}));
				}
				else
				{
					mGTweenLine.addTween(0,new GTween(moudles[i].getmoudleContent(),0.3,{x:sp.x + growth,y:sp.y},{ease:Sine.easeOut}));
				}
				growth += moudles[i].getmoudleContent().width;
			}
			
			mGTweenLine.calculateDuration();
			
		}
	}
	
	/**
	 * 
	 * 返回moudle
	 * @param ui_id
	 * @return 
	 * 
	 */
	public function getmoudleByID(moudleID:uint):MoudleBase
	{
		var moudle:moudleCache = retrievUIControlByID(moudleID);
		if(moudle)
		{
			return retrievUIControlByID(moudleID).moudleBase;
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
		var moudle:moudleCache;
		for each(moudle in moudleTable)
		{
			if(moudle.moudleBase is UIWindowMoudle)
			{
				var index:int = UIWindowMoudle(moudle.moudleBase).mUIMutualGroups.indexOf(id);
				if(index > -1)
				{
					close(moudle.mID);
				}
			}
		}
	}
	
	/**
	 * 
	 * 按照ID取出一个模块
	 * @param id
	 * 
	 */	
	private function retrievUIControlByID(id:uint):moudleCache
	{
		if(moudleTable[id])
		{
			return moudleTable[id];
		}
		else
		{
			return initmoudle(id);
		}
	}
	
	/**
	 * 
	 * 构建一个moudle
	 * @param id
	 * @return 
	 * 
	 */	
	private function initmoudle(id:uint):moudleCache
	{
		if(moudleRegister[id])
		{
			var theRegister:UImoudleResiter = moudleRegister[id] as UImoudleResiter;
			var moudle:moudleCache = new moudleCache();
			moudle.mID = id;
			moudle.moudleBase = new theRegister.moudleCls();
			moudle.moudleBase.modeID = id;
			moudleTable[id] = moudle;
			return moudle;
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
 * moudle的实例缓存对像 
 * @author JT
 * 
 */
class moudleCache
{
	public var mID:uint = 0;
	public var moudleBase:MoudleBase;
}

/**
 * moudle注册对像 
 * @author JT
 * 
 */
class UImoudleResiter
{
	public var mID:uint = 0;
	public var moudleCls:Class = null;
}
