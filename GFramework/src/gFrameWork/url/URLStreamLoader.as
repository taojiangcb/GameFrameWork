/**
 *  
 * 轻量级的数据加载方式,将文件以数据流的方式进行加载
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
		private var _urlStream:URLStream;
		
		/**
		 * 网络地址  
		 */		
		private var _url:URLRequest;
		
		/**
		 * 被加载到的文件流数据 
		 */		
		private var _fileByteArray:ByteArray;
		
		public function URLStreamLoader(url:URLRequest = null)
		{
			_url = url;
		}
		
		public function loader(url:URLRequest = null):void
		{
			if(url) 
			{
				_url = url;	
			}
			
			if(!_urlStream)
			{
				_urlStream = new URLStream();
			}
			else
			{
				_urlStream.close();
				removeListener();
			}
			
			listener();
			_urlStream.load(_url);
		}
		
		private function loadComplete(event:Event):void
		{
			if(_urlStream.bytesAvailable > 0)
			{
				_fileByteArray = new ByteArray();
				_urlStream.readBytes(_fileByteArray);
				
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
		
		private function progressHandler(event:ProgressEvent):void
		{
			if(hasEventListener(ProgressEvent.PROGRESS))
			{
				dispatchEvent(event.clone());
			}
		}
		
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
			if(_urlStream)
			{
				_urlStream.addEventListener(Event.COMPLETE,loadComplete);
				_urlStream.addEventListener(ProgressEvent.PROGRESS,progressHandler);
				_urlStream.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				_urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrorHandler);
			}
		}
		
		private function removeListener():void
		{
			if(_urlStream)
			{
				_urlStream.removeEventListener(Event.COMPLETE,loadComplete);
				_urlStream.removeEventListener(ProgressEvent.PROGRESS,progressHandler);
				_urlStream.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				_urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrorHandler);
			}
		}
		
		public function dispose():void
		{
			if(_urlStream)
			{
				removeListener();
				_urlStream.close();
				_urlStream = null;
			}
			
			if(_fileByteArray)
			{
				_fileByteArray.clear();
				_fileByteArray = null;
			}
		}
		
		/**
		 * 
		 * 被加载到的文件流 
		 * @return 
		 * 
		 */		
		public function get fileByteArray():ByteArray
		{
			return _fileByteArray;
		}
	}
}