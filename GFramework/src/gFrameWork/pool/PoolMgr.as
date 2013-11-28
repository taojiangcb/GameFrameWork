package gFrameWork.pool
{
	import flash.utils.Dictionary;
	
	import gFrameWork.IDisabled;
	
	

	public class PoolMgr
	{
		
		
		/**
		 *  
		 */		
		private static var internalCall:Boolean = false;
		
		private static var mInstance:PoolMgr = null;
		
		public static function get instance():PoolMgr
		{
			if(!mInstance)
			{
				internalCall = true;
				mInstance = new PoolMgr();
				internalCall = false;
			}
			return mInstance;
		}
		
		/**
		 * 共享的poolDict 
		 */		
		private var poolDict:Dictionary;
		
		public function PoolMgr()
		{
			if(!internalCall)
			{
				throw new Error("Please call properties instance");
			}
			poolDict = new Dictionary(true);
		}
		
		/**
		 * 
		 * 获取一个缓中对像
		 * @param url
		 * 
		 */		
		public function getObjByUrl(url:String):Object
		{
			if(poolDict[url])
			{
				var obj:Object = poolDict[url];
				obj["uRefCount"] = obj["uRefCount"] + 1;
			}
			return poolDict[url];
		}
		
		/**
		 * 添加一个对像到缓冲池
		 * @param url
		 * @param textureObj
		 * 
		 */		
		public function addObjToPool(url:String,textureObj:Object):void
		{
			textureObj["uRefCount"] = 1;
			poolDict[url] = textureObj;
		}
		
		/**
		 * 释放一个位图集,只有当引用数为0的时候才会真正的清除 
		 * @param url
		 * 
		 */		
		public function releasePool(url:String):void
		{
			if(poolDict[url])
			{
				var obj:Object = poolDict[url];
				obj["uRefCount"] = Math.max(0,obj["uRefCount"] - 1);
			}
		}
		
		/**
		 * 清除没有用的缓冲
		 * 
		 */		
		public function destoryDead():void
		{
			var clears:Array = [];
			var k:String;
			for (k in poolDict)
			{
				var obj:Object = poolDict[k];
				if(obj["uRefCount"] == 0)
				{
					clears.push(k);
				}
			}
			
			while(clears.length > 0)
			{
				k = String(clears.shift());
				var poolObj:Object = poolDict[k];
				var k2:String = "";
				for(k2 in poolObj)
				{
					if(k2 is IDisabled)
					{
						IDisabled(k2).dispose();
					}
				}
				delete poolDict[k]; 
			}
		}
	}
}
