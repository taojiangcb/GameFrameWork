

package gFrameWork.url
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	/**
	 * 远程网络文件引用 
	 * @author JT
	 * 
	 */	
	public class URLFileReference
	{

		/**
		 * 下载的文件流 
		 */		
		private var mFileStream:URLStreamLoader;
		
		/**
		 * 下载完成后回调函数引用 
		 */		
		private var mLoadingCompleteHandler:Function;
		
		/**
		 * 下载失败后回调引用 
		 */		
		private var mLoadingFaultHandler:Function;
		
		/**
		 * 下载进程回调 
		 */		
		private var mProgressingHandler:Function;
		
		/**
		 * 远程网络地址 
		 */		
		private var mUrl:URLRequest;
		
		/**
		 * 网络远程文件 
		 * @param address
		 * 
		 */		
		public function URLFileReference(address:URLRequest = null)
		{
			mUrl = address;					
		}
		
		/**
		 * 打开文件 
		 * @param address						网络文件地址
		 * @param succeedHandler				打开文件成功后的调用
		 * @param faultHandler					打开文件失败后的调用
		 * @param progressHandler				加载过程中调用的函数
		 * 
		 */		
		public function openFile(succeedHandler:Function,faultHandler:Function = null,progressHandler:Function = null,address:URLRequest = null):void
		{
			mLoadingCompleteHandler = succeedHandler;
			mLoadingFaultHandler = faultHandler;
			mProgressingHandler = progressHandler;
			
			if(address)
			{
				mUrl = address;
			}
			
			if(mUrl)
			{
				if(!mFileStream)
				{
					mFileStream = new URLStreamLoader(mUrl);
				}
				else
				{
					removeListener();
					mFileStream.dispose();
					mFileStream = new URLStreamLoader(mUrl);
				}
				
				listener();
				mFileStream.loader();
			}
			else
			{
				throw new Error("address Can't for empty");
			}
		}
		
		/**
		 * 关闭 
		 */		
		public function close():void
		{
			removeListener();
			if(mFileStream)
			{
				mFileStream.dispose();
				mFileStream = null;
			}
		}
		
		/**
		 * 成功后调用 
		 * @param event
		 * 
		 */		
		private function completeHandler(event:Event):void
		{
			if(mLoadingCompleteHandler != null)
			{
				mLoadingCompleteHandler(event);
			}
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			if(mLoadingFaultHandler != null)
			{
				mLoadingFaultHandler(event);
			}
		}
		
		private function progressHandler(event:ProgressEvent):void
		{
			if(mProgressingHandler != null)
			{
				mProgressingHandler(event);
			}
		}
		
		private function listener():void
		{
			if(mFileStream)
			{
				mFileStream.addEventListener(Event.COMPLETE,completeHandler,false,0,true);
				mFileStream.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler,false,0,true);
				mFileStream.addEventListener(ProgressEvent.PROGRESS,progressHandler,false,0,true);
			}
		}
		
		private function removeListener():void
		{
			if(mFileStream)
			{
				mFileStream.removeEventListener(Event.COMPLETE,completeHandler);
				mFileStream.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				mFileStream.removeEventListener(ProgressEvent.PROGRESS,progressHandler);
			}
		}
		
		public function getFileStrem():ByteArray
		{
			return mFileStream.fileByteArray;
		}
		
		public function getAddress():URLRequest
		{
			return mUrl;
		}
	}
}