/**
 *
 * UI控制管理
 *  
 */

package gFrameWork.uiModel
{
	import flash.geom.Point;
	
	import mx.core.UIComponent;

	public class UIModelManager
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
		 * 根据Model类型关闭所有的model
		 * 
		 */		
		public static function closeAllModel(modelType:int):void
		{
			instance.closeAllByType(modelType);
		}
		
		/**
		 * 注册一个UIModel
		 * @param modeID
		 * @param uiCls
		 * @param controlCLS
		 * 
		 */		
		public static function registerModel(modeID:uint,modelCls:Class):void
		{
			instance.registerModel(modeID,modelCls);
		}
		
		/**
		 * 销毁一个UI实例 
		 * @param modeID
		 * 
		 */		
		public static function retireModel(modeID:uint):void
		{
			instance.retireModel(modeID);
		}
		
		/**
		 * 获取一个UI控制 
		 * @param modeID
		 * @return 
		 * 
		 */		
		public static function getModelByID(modeID:uint):UIModelBase
		{
			return instance.getModelByID(modeID);
		}
		
		/**
		 * 根据model类型和model的ID 
		 * @param type
		 * @param ids
		 * 
		 */				
		public static function modelLayout(type:String,...ids):void
		{
			var parames:Array = [type];
			var i:int = 0;
			var len:int = ids.length;
			for(i = 0; i != len; i++)
			{
				parames.push(ids[i]);
			}
			instance.modelLayout.apply(null,parames);
		}
		
		private static function get instance():UserInternalManager
		{
			if(!mInstance)
			{
				mInstance = new UserInternalManager();
			}
			return mInstance;
		}
		
		public function UIModelManager()
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
import gFrameWork.uiModel.UIModelBase;
import gFrameWork.uiModel.UIModelManager;
import gFrameWork.uiModel.UIModelType;
import gFrameWork.uiModel.UIModelStates;
import gFrameWork.uiModel.UIWindowModel;

import org.puremvc.as3.core.Model;

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
	private var modelTable:Dictionary;
	
	/**
	 * 模块注册表 
	 */	
	private var modelRegister:Dictionary;
	
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
	private var openModels:Vector.<UIModelBase>
	
	
	public function UserInternalManager():void
	{
		modelTable = new Dictionary();
		modelRegister = new Dictionary();
		openModels = new Vector.<UIModelBase>();
	}
	
	/**
	 * 注册一个功能模块 
	 * @param modeID	//模块ID
	 * @param mCls		//模块启动类
	 * 
	 */
	public function registerModel(modeID:uint,mCls:Class):void
	{
		if(!modelRegister[modeID])
		{
			var register:UIModelResiter = new UIModelResiter();
			register.mID = modeID;
			register.modelCls = mCls;
			modelRegister[modeID] = register;
		}
	}
	
	/**
	 * 销毁一个功能模块 
	 * @param modeID
	 */	
	public function retireModel(modeID:uint):void
	{
		var model:ModelCache = modelTable[modeID];
		if(model)
		{
			model.modelBase.dispose();
			model.modelBase = null;
			modelTable[modeID] = null;
			delete modelTable[modeID];
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
	 * 开启某个Model显示，如果开启成功则返加 true 否则返回 false; 
	 * 
	 * @param modeID	Model的id
	 * @param isPop		如果为true则表示弹出显示
	 * @param point		显示的位置
	 * @return 
	 * 
	 */	
	public function open(modeID:uint,isPop:Boolean = false,point:Point=null,data:Object = null):Boolean
	{
		var model:ModelCache = retrievUIControlByID(modeID);
		if(model)
		{
			if(model.modelBase.preload.loadCount > 0)
			{
				model.modelBase.preload.beginLoad(isPop,point,data);
			}
			else
			{
				if(model.modelBase.state != UIModelStates.SHOW)
				{
					//排斥关闭不相关的窗口
					if(model.modelBase is UIWindowModel)
					{
						var index:int = UIWindowModel(model.modelBase).mUIMutualGroups.indexOf(mCurUIMutualID);
						if(index <= -1)
						{
							closeByMutualID(mCurUIMutualID);
							mCurUIMutualID =  UIWindowModel(model.modelBase).modeID;
						}
					}
					
					model.modelBase.mCanUse = true;
					model.modelBase.show(isPop,point,data);
					model.modelBase.state = UIModelStates.SHOW;
					model.modelBase.mCanUse = false;
					
					//添加到窗口显示列表中去
					openModels.push(model);
					
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
		var model:ModelCache = modelTable[modeID];
		if(model)
		{
			if(model.modelBase.state == UIModelStates.SHOW)
			{
				model.modelBase.mCanUse = true;
				model.modelBase.hide();
				model.modelBase.state = UIModelStates.HIDE;
				model.modelBase.mCanUse = false;
				
				/*从开启的列表中删除此窗口对像*/
				var index:int = openModels.indexOf(model);
				if(index > -1)
				{
					openModels.splice(index,1);
				}
			}
			return true;
		}
		return false;
	}
	
	/**
	 * 按类型关掉所有的窗口 
	 * @param modelType
	 * 
	 */	
	public function closeAllByType(modelType:int):void
	{
		var ids:Array = [];
		var model:UIModelBase;
		for each(model in openModels)
		{
			if(model.modelType == modelType)
			{
				model.mCanUse = true;
				model.hide();
				model.state = UIModelStates.HIDE;
				model.mCanUse = false;
				ids.push(model.modeID);
			}
		}
	}
	

	/**
	 * 
	 * 窗口排序布局 
	 * 
	 */	
	public function modelLayout(modelType:int = UIModelType.WINDOW,...ids):void
	{
		var rect:Rectangle = new Rectangle();
		var models:Vector.<UIModelBase> = new Vector.<UIModelBase>();
		var i:int = 0,j:int = 0;
		var len:int = openModels.length;
		for(i; i != len; i++)
		{
		
			for(j=0; j != ids.length; j++)
			{
				if(openModels[i].modelType == modelType)
				{
					models.push(openModels[i]);
				}
			}
			
		
		}
		if(models.length > 0)
		{
			for(i = 0; i < models.length; i++)
			{
				var window:UIWindowModel = models[i] as UIWindowModel;
				rect.width += window.getModelContent().width;
				rect.height = window.getModelContent().height > rect.height ? window.getModelContent().height : rect.height;
			}
			
			var sp:Point = new Point(Math.round((getSpace().width - rect.width) / 2),Math.round((getSpace().height - rect.height) / 2));
			var growth:Number = 0;
			
			if(mGTweenLine)
			{
				mGTweenLine.paused = true;
				mGTweenLine = new GTweenTimeline();
			}
			
			for(i = 0; i < models.length; i++)
			{
				if(i == 0)
				{
					mGTweenLine.addTween(0,new GTween(models[i].getModelContent(),0.3,{x:sp.x,y:sp.y},{ease:Sine.easeOut}));
				}
				else
				{
					mGTweenLine.addTween(0,new GTween(models[i].getModelContent(),0.3,{x:sp.x + growth,y:sp.y},{ease:Sine.easeOut}));
				}
				growth += models[i].getModelContent().width;
			}
			
			mGTweenLine.calculateDuration();
			
		}
	}
	
	/**
	 * 
	 * 返回Model
	 * @param ui_id
	 * @return 
	 * 
	 */
	public function getModelByID(modelID:uint):UIModelBase
	{
		var model:ModelCache = retrievUIControlByID(modelID);
		if(model)
		{
			return retrievUIControlByID(modelID).modelBase;
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
		var model:ModelCache;
		for each(model in modelTable)
		{
			if(model.modelBase is UIWindowModel)
			{
				var index:int = UIWindowModel(model.modelBase).mUIMutualGroups.indexOf(id);
				if(index > -1)
				{
					close(model.mID);
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
	private function retrievUIControlByID(id:uint):ModelCache
	{
		if(modelTable[id])
		{
			return modelTable[id];
		}
		else
		{
			return initModel(id);
		}
	}
	
	/**
	 * 
	 * 构建一个Model
	 * @param id
	 * @return 
	 * 
	 */	
	private function initModel(id:uint):ModelCache
	{
		if(modelRegister[id])
		{
			var theRegister:UIModelResiter = modelRegister[id] as UIModelResiter;
			var model:ModelCache = new ModelCache();
			model.mID = id;
			model.modelBase = new theRegister.modelCls();
			model.modelBase.modeID = id;
			modelTable[id] = model;
			return model;
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
 * Model的实例缓存对像 
 * @author JT
 * 
 */
class ModelCache
{
	public var mID:uint = 0;
	public var modelBase:UIModelBase;
}

/**
 * Model注册对像 
 * @author JT
 * 
 */
class UIModelResiter
{
	public var mID:uint = 0;
	public var modelCls:Class = null;
}
