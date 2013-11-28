/**
 *  
 * 文件下载
 *  
 */
package gFrameWork.url
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	[Event(name="complete",type="flash.events.Event")]
	[Event(name="ioError",type="flash.events.IOErrorEvent")]
	[Event(name="progress",type="flash.events.ProgressEvent")]
	[Event(name="securityErrorEvent",type="flash.events.SecurityErrorEvent")]
	
	public class URLStreamLoader extends EventDispatcher
	{
		
		/**
		 * 加载失败后重试的次数
		 */		
		private const TRY_COUNT:int = 15;
		
		/**
		 * 重试的累计次数 
		 */		
		private var tryTime:int = 0;
		
		/**
		 * 文件加载的数据流 
		 */		
		private var urlStream:URLStream;
		
		/**
		 * 网络地址  
		 */		
		private var mUrl:URLRequest;
		
		/**
		 * 被加载到的文件流数据 
		 */		
		private var mFileByteArray:ByteArray;
		
		public function URLStreamLoader(url:URLRequest = null)
		{
			mUrl = url;
		}
		
		public function loader(url:URLRequest = null):void
		{
			if(url) 
			{
				mUrl = url;	
			}
			
			if(!urlStream)
			{
				urlStream = new URLStream();
			}
			else
			{
				urlStream.close();
				removeListener();
			}
			
			listener();
			urlStream.load(mUrl);
		}
		
		/**
		 * 下载完成后回调函数 
		 * @param event
		 * 
		 */		
		private function loadComplete(event:Event):void
		{
			if(urlStream.bytesAvailable > 0)
			{
				mFileByteArray = new ByteArray();
				urlStream.readBytes(mFileByteArray);
				
				if(hasEventListener(Event.COMPLETE))
				{
					dispatchEvent(event.clone());
				}
				removeListener();
			}
			else
			{
				loader();
			}
		}
		
		/**
		 * 下载进程回调函数 
		 * @param event
		 * 
		 */		
		private function progressHandler(event:ProgressEvent):void
		{
			if(hasEventListener(ProgressEvent.PROGRESS))
			{
				dispatchEvent(event.clone());
			}
		}
		
		/**
		 * 下载失败回调函数 
		 * @param event
		 * 
		 */		
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			if(tryTime < TRY_COUNT)
			{
				tryTime++;
				loader();
			}
			else
			{
				if(hasEventListener(IOErrorEvent.IO_ERROR))
				{
					dispatchEvent(event.clone());
				}
				removeListener();
			}
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			if(hasEventListener(SecurityErrorEvent.SECURITY_ERROR))
			{
				dispatchEvent(event.clone());
			}
			removeListener();
		}
		
		private function listener():void
		{
			if(urlStream)
			{
				urlStream.addEventListener(Event.COMPLETE,loadComplete);
				urlStream.addEventListener(ProgressEvent.PROGRESS,progressHandler);
				urlStream.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrorHandler);
			}
		}
		
		private function removeListener():void
		{
			if(urlStream)
			{
				urlStream.removeEventListener(Event.COMPLETE,loadComplete);
				urlStream.removeEventListener(ProgressEvent.PROGRESS,progressHandler);
				urlStream.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrorHandler);
			}
		}
		
		/**
		 * 回收 
		 */		
		public function dispose():void
		{
			if(urlStream)
			{
				removeListener();
				urlStream.close();
				urlStream = null;
			}
			
			if(mFileByteArray)
			{
				mFileByteArray.clear();
				mFileByteArray = null;
			}
		}
		
		/**
		 * 被加载到的文件流 
		 * @return 
		 */		
		public function get fileByteArray():ByteArray
		{
			return mFileByteArray;
		}
	}
}