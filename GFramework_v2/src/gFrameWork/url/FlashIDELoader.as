package gFrameWork.url
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	
	import gFrameWork.IDisabled;
	
	import mx.utils.StringUtil;
	
	/**
	 * SWF外部程序加载，其中还包含此swf文件的中资源应用域
	 * @author taojiang
	 * 
	 */	
	public class FlashIDELoader extends Sprite implements IDisabled
	{
		/**
		 * 当前下载的swf文件资源 
		 */		
		private var mSWFResource:SWFResource;
		
		/**
		 * 下载的文件地址 
		 */		
		private var mSource:String = "";
		
		[Event(name="complete",type="flash.events.Event")]
		public function FlashIDELoader(source:String="")
		{
			//TODO: implement function
			super();
			mSource = source;
			invalidateLoader();
		}
		
		/**
		 * 开始加载资源 
		 * 
		 */		
		private function onLoader():void
		{
			if(source && StringUtil.substitute(mSource).length > 0)
			{
				clearLoader();
				var request:URLRequest = new URLRequest(mSource);
				mSWFResource = new SWFResource();
				mSWFResource.install(request,onSucceedHandler,onFaultHadler);
			}
		}
		
		/**
		 * 请除当前下载的swf文件 
		 * 
		 */		
		private function clearLoader():void
		{
			if(mSWFResource)
			{
				if(objContent && DisplayObject(objContent).parent)
				{
					removeChild(objContent as DisplayObject);
				}
				mSWFResource.dispose();
				mSWFResource = null;
			}
		}
		
		/**
		 * 加载成功后调用处理 
		 * @param event
		 * 
		 */		
		private function onSucceedHandler(event:Event):void
		{
			addChild(objContent as DisplayObject);
			
			if(hasEventListener(Event.COMPLETE))
			{
				dispatchEvent(event.clone());
			}
		}
		
		/**
		 * 加载失败后调用处理 
		 * @param event
		 * 
		 */		
		private function onFaultHadler(event:IOErrorEvent):void
		{
			throw new Error(event.toString());
		}
		
		/**
		 * 缓冲调用加载，将加载合并后自 
		 * 
		 */		
		private function invalidateLoader():void
		{
			removeEventListener(Event.ENTER_FRAME,nextFrameHandler);
			addEventListener(Event.ENTER_FRAME,nextFrameHandler,false,0,true);
		}
		
		private function nextFrameHandler(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME,nextFrameHandler);
			onLoader();
		}
		
		/**
		 * 已加载的内空显示对像 
		 * @return 
		 * 
		 */		
		public function get objContent():Object
		{
			if(mSWFResource)
			{
				mSWFResource.getAssetsLoader().content;
			}
			return null;
		}
		
		/**
		 * 指定需要加载的swf文件 
		 * @param val
		 * 
		 */		
		public function set source(val:String):void
		{
			if(mSource == val) return;
			mSource = val;
			invalidateLoader();
		}
		
		public function get source():String
		{
			return mSource;
		}
		
		/**
		 * 获取swfIDE的资源应用域，可以用于swf内部的资源反射 
		 * @return 
		 * 
		 */		
		public function get appDomain():ApplicationDomain
		{
			if(mSWFResource)
			{
				mSWFResource.getDomain();
			}
			return null;
		}
		
		public function dispose():void
		{
			removeEventListener(Event.ENTER_FRAME,nextFrameHandler);
			clearLoader();
		}
		
	}
}