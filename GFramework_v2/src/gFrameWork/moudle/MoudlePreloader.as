/**
 *
 * 在打开UI之前先要下载相关的资源逻辑处理，例如在打开一个窗口的时候，可能选要预下载此窗口内相关的资源文件等等。
 * author:jiangtao;
 * version:1.0.0;
 * date:20120910
 *  
 */
package gFrameWork.moudle
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	
	import gFrameWork.url.FileLoader;
	
	import mx.utils.StringUtil;

	[event(name="complete",type="flash.events.Event")]
	
	/**
	 * UI资源加载控制器，一个UI开启之前会进入一个加载阶段，加载当前UI所需要的资源文件 
	 * @author taojiang
	 * 
	 */	
	public class MoudlePreloader extends EventDispatcher
	{
		
		/**
		 * 加载的资源文件列表
		 */		
		private var mLoadList:Vector.<String>;
				
		/**
		 * 标记是否正在清除中 
		 */		
		private var mClearingFag:Boolean = false;
		
		/**
		 * 当前下载的索引 
		 */		
		private var mCurIndex:int = 0;
		
		/**
		 * 当前下载的资源
		 */		
		protected var mCurFileLoader:FileLoader;
		
		/**
		 * 当前的UI控制器 
		 */		
		private var mUImoudle:MoudleBase;
		
		
		private var moudleIsPop:Boolean = false;
		
		private var moudlePoint:Point = null;
		
		private var moudleData:Object = null
		
		
		public function MoudlePreloader(uiControl:MoudleBase)
		{
			mLoadList = new Vector.<String>(); 			
			mUImoudle = uiControl;
			
			registerToLoaded();
		}
		
		/**
		 * 注册当前UI所需加载的资源,由子对像覆盖实现.
		 * 
		 */		
		protected function registerToLoaded():void
		{
			var fileUrls:Vector.<String> = mUImoudle.getUiLoadFiles();
			if(fileUrls)
			{
				while(fileUrls.length > 0)
				{
					appendToList(fileUrls[0]);
				}
			}
		}
		
		/**
		 * 资源文件读取中的进度处理函数，由子对像覆盖实现。
		 * @param event
		 * 
		 */		
		protected function loadProgress(event:ProgressEvent):void
		{
			
		}
		
		/**
		 * 
		 * 资源文件读取完成,如果最后一个文件读取完成后就会派发 Event.COMPLETE 事件否则会执行下一个文件的加载调用netLoader
		 * @param event
		 * 
		 */		
		private function loadComplete(event:Event):void
		{
			if(mCurIndex != mLoadList.length)
			{
				nextLoad();
			}
			else
			{
				onComplete();
				stopAndClear();
				if(hasEventListener(Event.COMPLETE))
				{
					dispatchEvent(new Event(Event.COMPLETE));
				}
			}
		}
		
		/**
		 * 
		 * 资源文件读取失败 
		 * @param event
		 * 
		 */		
		private function loadError(event:IOErrorEvent):void
		{
			onFault(event);
		}
		
		/**
		 * 开始下一个文件的加载 
		 * 
		 */		
		private function nextLoad():void
		{
			if(mCurFileLoader)
			{
				mCurFileLoader.removeEventListener(Event.COMPLETE,loadComplete);
				mCurFileLoader.removeEventListener(IOErrorEvent.IO_ERROR,loadError);
				mCurFileLoader.removeEventListener(ProgressEvent.PROGRESS,loadProgress);
				mCurFileLoader.dispose();
				mCurFileLoader = null;
			}
			
			if(mCurIndex < mLoadList.length)
			{
				mCurFileLoader = FileLoader.getSharedFileLoader(new URLRequest(mLoadList[mCurIndex]));
			}
			
			if(mCurFileLoader)
			{
				mCurIndex++;
				
				onLoadChange();
				
				mCurFileLoader.addEventListener(Event.COMPLETE,loadComplete,false,0,true);
				mCurFileLoader.addEventListener(IOErrorEvent.IO_ERROR,loadError,false,0,true);
				mCurFileLoader.addEventListener(ProgressEvent.PROGRESS,loadProgress,false,0,true);
				mCurFileLoader.loader();
			}
		}
		
		/**
		 *
		 * 当下载的资源列表完成时处理,由子对像覆盖实现
		 * 
		 */		
		protected function onComplete():void
		{
			mLoadList = new Vector.<String>();
			MoudleManager.open(mUImoudle.modeID,moudleIsPop,moudlePoint,moudleData);
		}
		
		/**
		 * 
		 * 当下载的资源失败时处理,由子对像覆盖实现
		 * 
		 */		
		protected function onFault(error:IOErrorEvent):void
		{
			
		}
		
		/**
		 * 
		 * 当下载的资源发生变更时的处理,由子对像覆盖实现
		 * 
		 */		
		protected function onLoadChange():void
		{
			
		}
		
		/**
		 *
		 * 开始下载当前指定的资源 
		 * 
		 */		
		public function beginLoad(...args):void
		{
			
			if(args.length == 3)
			{
				moudleIsPop = args[0];
				moudlePoint = args[1];
				moudleData = args[2];
			}
			
			if(!mClearingFag)
			{
				nextLoad();
			}
			else
			{
				throw new Error("please before here call stopClear() function delete previous content。");
			}
		}
		
		/**
		 * 
		 * 添加到源列表中 
		 * @param val
		 * 
		 */		
		public function appendToList(val:String):void
		{
			if(val == null  || StringUtil.trim(val).length == 0) return;
			if(!(mLoadList.indexOf(val) > -1))
			{
				mLoadList.push(val);
			}
		}
		
		/**
		 * 
		 * 暂停并且清除当前所下载的列表资源 
		 * 
		 */		
		public function stopAndClear():void
		{
			mClearingFag = true;
			mCurIndex = 0;
			if(mCurFileLoader)
			{
				mCurFileLoader.removeEventListener(Event.COMPLETE,loadComplete);
				mCurFileLoader.removeEventListener(IOErrorEvent.IO_ERROR,loadError);
				mCurFileLoader.removeEventListener(ProgressEvent.PROGRESS,loadProgress);
				mCurFileLoader.dispose();
				mCurFileLoader = null;
			}
			
			if(mLoadList && mLoadList.length)
			{
				mLoadList.length = 0;	
			}
			mClearingFag = false;
		}
		
		/**
		 * 
		 * 当前下载的资源列表 
		 * @return 
		 * 
		 */		
		public function get loadList():Vector.<String>
		{
			return mLoadList;
		}
		
		/**
		 * 当前下载的条数 
		 * @return 
		 * 
		 */		
		public function get loadIndex():int
		{
			return mCurIndex;
		}
		
		/**
		 * 总共的条数 
		 */		
		public function get loadCount():int
		{
			return loadList.length;
		}
	}
}