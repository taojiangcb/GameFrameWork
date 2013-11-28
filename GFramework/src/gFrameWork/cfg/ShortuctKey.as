
package gFrameWork.cfg
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;

	public class ShortuctKey
	{
		
		private static const ADD:int = 1, DEL:int = -1;
		
		/**
		 * 快键的缓存 
		 */		
		private  static var mKeyMaps:Dictionary;
		
		/**
		 * 主场景 
		 */		
		private static var mStage:Stage;
		
		/**
		 * 快键的状态 
		 */		
		private static var mStarted:Boolean = false; 
		
		/**
		 * 按下的引用数 
		 */		
		private static var mUpCount:uint = 0;
		
		/**
		 * 弹起的引用数 
		 */		
		private static var mDownCount:uint = 0;
		
		/**
		 * 
		 * 快捷键的管理
		 * 
		 */
		public function ShortuctKey()
		{
			
		}
		
		public static function init(stage:Stage,autoStart:Boolean = false):void
		{
			
			if(!mKeyMaps)
			{
				mKeyMaps = new Dictionary();
			}
			
			mStage = stage;
			autoStart && start();
		}
		
		public static function start():void
		{
			if(mStage)
			{
				mStarted = true;
			}
		}
		
		
		public static function stop():void
		{
			mStarted = false;
		}
		
		/**
		 * 注册快捷键 
		 * @param keyCode			键值
		 * @param fun				回调函数
		 * @param type				键盘状态类型
		 * 
		 */		
		public static function register(keyCode:uint,fun:Function,type:String = KeyboardEvent.KEY_UP):void
		{
			var keyName:String = getKeyName(keyCode,type);
			if(mKeyMaps[keyName])
			{
				if(mKeyMaps[keyName].indexOf(fun) != -1)
				{
					mKeyMaps[keyName].push(fun);
					check(type,ADD);
				}
			}
			else
			{
				mKeyMaps[keyName] = [fun];
				check(type,ADD);
			}
		}
		
		/**
		 * 注销快捷键 
		 * @param keyCode			键值
		 * @param fun				回调函数
		 * @param type				键盘状态类型
		 * 
		 */		
		public static function unregister(keyCode:uint,fun:Function,type:String = KeyboardEvent.KEY_UP):void
		{
			var keyName:String = getKeyName(keyCode,type);
			if(mKeyMaps[keyName])
			{
				var funcIndex:int = mKeyMaps[keyName].indexOf(fun);  
				if (funcIndex >= 0)  
				{  
					mKeyMaps[keyName].splice(funcIndex, 1);
					check(type,DEL);
					
					if(mKeyMaps[keyName].length == 0)
					{
						delete mKeyMaps[keyName];
					}
					
				}  
			}
		}
		
		private static function check(type:String,act:uint):void
		{
			if(!mStage)
			{
				throw new Error("Please call shortcut.init method first");
			}
			
			switch(type)
			{
				case KeyboardEvent.KEY_DOWN:
					mDownCount += act;
					if(mDownCount == 1 )
					{
						mStage.addEventListener(KeyboardEvent.KEY_DOWN,keyHandler);
					}
					else if(mDownCount == 0)
					{
						mStage.removeEventListener(KeyboardEvent.KEY_DOWN,keyHandler);
					}
					break;
				case KeyboardEvent.KEY_UP:
					mUpCount += act;
					if(mUpCount == 1)
					{
						mStage.addEventListener(KeyboardEvent.KEY_UP,keyHandler);
					}
					else if(mUpCount == 0)
					{
						mStage.removeEventListener(KeyboardEvent.KEY_UP,keyHandler);
					}
					break;
				default:   
				{  
					throw new Error('KeyboardEvent.KEY_UP & KeyboardEvent.KEY_DOWN only.');  
					break;  
				}  
			}
			
		}
		
		private static function keyHandler(event:KeyboardEvent):void
		{
			if(!mStarted)
			{
				return;
			}
			
			var keyName:String = getKeyName(event.keyCode,event.type);
			var funcs:Array = mKeyMaps[keyName];

			if(funcs)
			{
				for(var i:int = 0; i < funcs.length;i++)
				{
					funcs[i](event);
				}
			}
		}
		
		private static function getKeyName(code:uint,type:String):String
		{
			return [code,type].join("_");
		}
		
		/**
		 * 
		 * 当前按键的状态 
		 * @return 
		 * 
		 */		
		public static function get started():Boolean
		{
			return mStarted;
		}
	}
}