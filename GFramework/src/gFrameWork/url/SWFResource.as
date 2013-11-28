package gFrameWork.url
{
	import flash.display.Loader;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	
	import gFrameWork.IDisabled;
	import gFrameWork.JT_internal;
	import gFrameWork.pool.PoolMgr;
	
	use namespace JT_internal;
	
	
	/**
	 * Swf文件资源加载 
	 * @author taojiang
	 * 
	 */	
	[Event(name="complete",type="flash.Events.Event")]
	public class SWFResource extends EventDispatcher implements IDisabled
	{
		/**
		 * 资源装载器 
		 */		
		private var mLoader:ResouceLoader
		
		/**
		 * 文件的装载 
		 */		
		private var mFileLoader:FileLoader;
		
		/**
		 *装载的应用域 
		 */		
		private var mAppDomain:ApplicationDomain;
		
		/**
		 * 网络远程请求 
		 */		
		private var mRequest:URLRequest;
		
		/**
		 * 装载完成后回调 
		 */		
		private var mInstallComplete:Function;
		
		/**
		 * 装载失败后回调 
		 */		
		private var mInstallFault:Function;
		
		/**
		 * 是否已经装载完成 
		 */		
		private var mIsComplete:Boolean = false;	
		
		/**
		 * 缓存对像
		 */		
		private var mCachePool:Object = null;
		
		
		/**
		 * 装载资源 
		 * @param assets									指定的资源文件
		 * @param appDomain									指定需要装载的程序应用域
		 * @param installSucceed							装载完成执行的回调函数
		 * @param installFault								装载失改后执行的回调函数
		 * 
		 */		
		public function install(request:URLRequest,installSucceed:Function,installFault:Function = null):void
		{
			
			if(mRequest == request)
			{
				return;
			}
			
			//先清除老的资源缓冲
			PoolMgr.instance.releasePool(cacheName);
			
			mInstallComplete = installSucceed;
			mInstallFault = installFault;
			mRequest = request;
			
			mCachePool = PoolMgr.instance.getObjByUrl(cacheName);
			if(mCachePool)
			{
				mFileLoader = mCachePool["fileLoader"];
				mLoader = mCachePool["resultLoader"];
				mAppDomain = mCachePool["domain"];
				mIsComplete = mCachePool["isComplete"];
				
				//如果已经全部装载完成，直接调回完成回调函数
				if(mIsComplete)
				{
					if(mInstallComplete != null)
					{
						mInstallComplete(new Event(Event.COMPLETE));
					}
				}
				else
				{
					//不需要重复装载资源，所以不需要监听文件下载
					//mFileLoader.removeEventListener(Event.COMPLETE,fileLoaderComplete);
					//mFileLoader.removeEventListener(IOErrorEvent.IO_ERROR,fileIOErrorHandler);
					
					mLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);
					mLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				}
			}
			else
			{
				mCachePool = new Object();
				mFileLoader = new FileLoader(mRequest);
				mFileLoader.addEventListener(Event.COMPLETE,fileLoaderComplete,false,0,true);
				mFileLoader.addEventListener(IOErrorEvent.IO_ERROR,fileIOErrorHandler,false,0,true);
				
				mAppDomain = new ApplicationDomain();
				mLoader = new ResouceLoader();
				
				mCachePool["fileLoader"] = mFileLoader;
				mCachePool["resultLoader"] = mLoader;
				mCachePool["domain"] = mAppDomain;
				mCachePool["isComplete"] = mIsComplete;
				
				//添加到资源缓存池中
				PoolMgr.instance.addObjToPool(cacheName,mCachePool);
				
				mFileLoader.loader();
				
			}
			
		}
		
		/**
		 * 文件下载成功处理 
		 * @param event
		 * 
		 */		
		private function fileLoaderComplete(event:Event):void
		{
			mLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);
			mLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			var loadcontent:LoaderContext = new LoaderContext(false,mAppDomain);
			mLoader.loadBytes(mFileLoader.fileByte,loadcontent);
		}
		
		/**
		 * 文件下载失败处理 
		 * @param event
		 * 
		 */		
		private function fileIOErrorHandler(event:IOErrorEvent):void
		{
			if(mInstallFault != null)
			{
				mInstallFault(event);
			}
			else
			{
				throw new IOError(event.text);
			}
		}
		
		private function completeHandler(event:Event):void
		{
			if(mInstallComplete != null)
			{
				mInstallComplete(event);
				mIsComplete = true;
				mCachePool["isComplete"] = mIsComplete;
			}
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			if(mInstallFault != null)
			{
				mInstallFault(event);
			}
		}
		
		
		/**
		 * 
		 * 卸载安装的资源文件 
		 * 
		 */		
		public function dispose():void
		{
			//清除老的资源缓冲
			PoolMgr.instance.releasePool(cacheName);
		}
		
		
		/**
		 * 缓冲的对像名称 
		 * @return 
		 * 
		 */		
		private function get cacheName():String
		{
			if(mRequest)
			{
				return mRequest.url + "__cachePool"
			}
			else
			{
				return null;
			}
		}
		
		/**
		 * 获取加载的资源文件 
		 * @return 
		 */		
		public function getFileLoader():FileLoader
		{
			return mFileLoader;
		}
		
		public function getAssetsLoader():Loader
		{
			return mLoader;
		}
		
		public function getDomain():ApplicationDomain
		{
			return mAppDomain;
		}
	}
}