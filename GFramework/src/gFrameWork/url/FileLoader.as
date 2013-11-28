
package gFrameWork.url
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import gFrameWork.JT_internal;
	import gFrameWork.pool.PoolMgr;
	
	
	[Event(name="complete",type="flash.events.Event")]
	[Event(name="ioError",type="flash.events.IOErrorEvent")]
	[Event(name="progress",type="flash.events.ProgressEvent")]
	[Event(name="securityError",type="flash.events.SecurityErrorEvent")]
	
	use namespace JT_internal;
	
	public class FileLoader extends EventDispatcher
	{
		
		/**
		 * 文件流加载 
		 */		
		private var mFileStreamLoader:URLStreamLoader;
		
		/**
		 * 文件是否加载完成 
		 */		
		private var mIsComplete:Boolean = false;
		
		/**
		 * 加载文件地址 
		 */		
		private var mUrlRequest:URLRequest;
		
		/**
		 * 
		 */		
		private var mLoading:Boolean = false;
		
		/**
		 * 获取一个共享的文件加载器，避免加载相同的文件 
		 * @param request
		 * @return 
		 * 
		 */		
		public static function getSharedFileLoader(request:URLRequest):FileLoader
		{
			if(request)
			{
				var cacheFileLoader:Object = PoolMgr.instance.getObjByUrl(request.url);
				if(cacheFileLoader)
				{
					return cacheFileLoader["fileLoader"];
				}
				else
				{
					var fileLoader:FileLoader = new FileLoader(request);
					PoolMgr.instance.addObjToPool(request.url,fileLoader);
					return fileLoader;
				}
			}
			return null;
		}
		
		/**
		 *
		 * 资源文件加载,文件加载完成后写入到数据流中然后再到其它相关的应用开发中使用文件流。
		 *  
		 */
		public function FileLoader(url:URLRequest)
		{
			mUrlRequest = url;	
			mLoading = false;
			mIsComplete = false;
		}
		
		public function loader():void
		{
			if(!mIsComplete)
			{
				if(!mLoading)
				{
					mLoading = true;
					if(!mFileStreamLoader)
					{
						mFileStreamLoader = new URLStreamLoader();
					}
					listener();
					mFileStreamLoader.loader(mUrlRequest);
				}
				else
				{
					listener();
				}
			}
			else
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		
		private function completeHandler(event:Event):void
		{
			mLoading = false;
			mIsComplete = true;
			dispatchEvent(event.clone());
			removeListener();
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			dispatchEvent(event.clone());
			removeListener();
		}
		
		private function progressHandler(event:ProgressEvent):void
		{
			dispatchEvent(event.clone());
		}
		
		private function securityHandler(event:SecurityErrorEvent):void
		{
			dispatchEvent(event.clone());
			removeListener();
		}
		
		private function listener():void
		{
			if(mFileStreamLoader)
			{
				mFileStreamLoader.addEventListener(Event.COMPLETE,completeHandler);
				mFileStreamLoader.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				mFileStreamLoader.addEventListener(ProgressEvent.PROGRESS,progressHandler);
				mFileStreamLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityHandler);
			}
		}
		
		private function removeListener():void
		{
			if(mFileStreamLoader)
			{
				mFileStreamLoader.removeEventListener(Event.COMPLETE,completeHandler);
				mFileStreamLoader.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				mFileStreamLoader.removeEventListener(ProgressEvent.PROGRESS,progressHandler);
				mFileStreamLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,securityHandler);
			}
		}
		/**
		 * 
		 * 释放资源 
		 */		
		public function dispose():void
		{
			removeListener();
			mLoading = false;
			mIsComplete = false;
			if(mFileStreamLoader)
			{
				mFileStreamLoader.dispose();
				mFileStreamLoader = null;
			}
		}
		
		public function get fileByte():ByteArray
		{
			return mFileStreamLoader.fileByteArray;
		}
		
		public function get request():URLRequest
		{
			return mUrlRequest;
		}
		
		public function get fileUrl():String
		{
			return mUrlRequest.url;
		}
		
		public function get isComplete():Boolean
		{
			return mIsComplete;
		}
		
	}
}