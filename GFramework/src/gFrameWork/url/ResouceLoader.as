package gFrameWork.url
{
	import flash.display.Loader;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import gFrameWork.JT_internal;
	
	use namespace JT_internal
	
	/**
	 * 资源文件装载
	 * @author taojiang
	 */	
	public class ResouceLoader extends Loader
	{
		/**
		 * 测试次数 
		 */		
		private var mTryCount:int = 5;
		
		/**
		 * 当前重试的次数 
		 */		
		private var mTime:int = 0;
		
		/**
		 * 加载的路径 
		 */		
		private var mUrlRequest:URLRequest;
		
		/**
		 * 加载的内容 
		 */		
		private var mContext:LoaderContext;
		
		/**
		 * 加载的二制流 
		 */		
		private var mByteArray:ByteArray;
		
		/**
		 * 是否正在加载中 
		 */		
		private var isLoading:Boolean = false;
		
		public function ResouceLoader()
		{
			super();
		}
		
		private function listener():void
		{
			contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler,false,0,true);
			contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securyErrorHandler,false,0,true);
			contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler,false,0,true);
		}
		
		private function removeListener():void
		{
			contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,securyErrorHandler);
			contentLoaderInfo.removeEventListener(Event.COMPLETE,completeHandler);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			isLoading = false;
			if(mTime != mTryCount)
			{
				mTime++;
				if(!mByteArray)
				{
					load(mUrlRequest,mContext);
				}
				else
				{
					loadBytes(mByteArray,mContext);
				}
			}
			else
			{
				throw new Error(event.toString());
			}
		}
		
		private function securyErrorHandler(event:SecurityErrorEvent):void
		{
			isLoading = false;
			if(mTime != mTryCount)
			{
				mTime++;
				if(!mByteArray)
				{
					load(mUrlRequest,mContext);
				}
				else
				{
					loadBytes(mByteArray,mContext);
				}
			}
			else
			{
				throw new Error(event.toString());
			}
		}
		
		private function completeHandler(event:Event):void
		{
			mTime=0;
			isLoading = false;
		}
		
		public override function load(request:URLRequest, context:LoaderContext=null):void
		{
			mUrlRequest = request;
			mContext = context;
			
			if(!isLoading)
			{
				isLoading = true;
				super.load(request,context);
			}
		}
		
		/**
		 * 按二进制流装载资源 
		 * @param bytes
		 * @param context
		 * 
		 */		
		public override function loadBytes(bytes:ByteArray, context:LoaderContext=null):void
		{
			mByteArray = bytes;
			mContext = context;
			
			if(!isLoading)
			{
				isLoading = true;
				super.loadBytes(bytes,context);
			}
		}
		
		/**
		 * 是否已经装载过了 
		 * @return 
		 * 
		 */		
		public function get isComplete():Boolean
		{
			return content ? true : false;
		}
		
	}
}