package application.components
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	import gFrameWork.IDisabled;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.utils.StringUtil;
	

	[Event(name="complete", type="flash.events.Event")]
	
	
	/**
	 * 
	 * Flash swf文件加载，除了显示内容以外，还可以通过appDomain反射内容。 
	 * @author JT
	 * 
	 */	
	public class FLIDELoader extends UIComponent implements IDisabled
	{
		
		/**
		 * 文件地址 
		 */		
		private var mSource:String = "";
		
		/**
		 * 文件请求地址
		 */		
		private var mRequest:URLRequest;
		
		/**
		 * 加载 
		 */		
		private var mLoader:Loader;
		
		/**
		 * 子级应用域 
		 */		
		private var mAppdomain:ApplicationDomain;
		
		/**
		 * 当前重试的次数 
		 */		
		private var tryTime:int = 0;
		
		/**
		 * 总共可以重试的次数 
		 */		
		private const TRY_COUNT:int = 99;
		
		
		public function FLIDELoader(source:String = "")
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE,completeHandelr,false,0,true);
			mSource = source;
		}
		
		protected override function createChildren():void
		{
			mLoader = new Loader();
			addChild(mLoader);
		}
		
		private function completeHandelr(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE,completeHandelr);
			onLoader();
		}
		
		public function onLoader():void
		{
			if(mSource && StringUtil.trim(mSource).length > 0)
			{
				clearLoader();
				mLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,installSuceed);
				mLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,installFault,false,0,true);
				mAppdomain = new ApplicationDomain();
				var loaderContent:LoaderContext = new LoaderContext(false,mAppdomain);
				mLoader.load(new URLRequest(mSource),loaderContent);
			}
		}
		
		private function installSuceed(event:Event):void
		{
			var content:DisplayObject = objContent as DisplayObject;
			if(objContent.hasOwnProperty("loaderCompleteInit"))
			{
				objContent.loaderCompleteInit();
			}
			dispatchEvent(event.clone());
		}
		
		private function installFault(event:IOErrorEvent):void
		{
			if(tryTime < TRY_COUNT)
			{
				tryTime++;
				onLoader();
			}
			else
			{
				throw new Error(event.toString());
			}
		}
		
		private function clearLoader():void
		{
			if(mLoader)
			{
				mAppdomain = null;
				mLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,installSuceed);
				mLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,installFault);
				mLoader.unloadAndStop(false);
			}
		}
		
		public function dispose():void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE,completeHandelr);
			
			if(objContent && objContent.hasOwnProperty("dispose"))
			{
				objContent["dispose"]();
			}
			
			clearLoader();
			
			if(mLoader)
			{
				if(mLoader.parent)
				{
					removeChild(mLoader);
				}
				mLoader = null;
			}
		}
		
		
		public override function set width(value:Number):void
		{
			super.width = value;
			if(objContent)
			{
				objContent.width = value;
			}
		}
		
		public override function set height(value:Number):void
		{
			super.height = value;
			if(objContent)
			{
				objContent.height = value;
			}
		}
		
		/**
		 * 
		 * 获取加载的内容 
		 * @return 
		 * 
		 */		
		public function get objContent():Object
		{
			if(mLoader)
			{
				return mLoader.content;
			}
			return null;
		}
		
		/**
		 * 返回资源应用程序域 
		 * @return 
		 * 
		 */		
		public function get appDomain():ApplicationDomain
		{
			return mAppdomain;
		}
		
		/**
		 * 资源地址 
		 * @param val
		 */		
		public function set source(val:String):void
		{
			if(val == mSource) return;
			mSource = val;
			if(initialized)
			{
				onLoader();
			}
		}
		
		public function get source():String
		{
			return mSource;
		}
		
	}
}