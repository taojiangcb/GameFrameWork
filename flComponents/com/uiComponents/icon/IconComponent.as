/**
 *
 * Icon图标组件,下载外部的资源图标并显示,这里有两个参数需要注意的。
 * 第一个是iconType属性，它决定当前应该显示哪个状诚的图标。
 * 第二个是iconTempCls属性，它决定当前图标的排序逻辑和渲染逻辑。
 * 
 * author:jiangtao
 * version:1.0.0
 * date:20120910
 *  
 */
package com.uiComponents.icon
{
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	
	import gameLib_JT.JT_IDisposable;
	import gameLib_JT.components.JT_UIComponent;
	import gameLib_JT.resouce.JT_AssetsFileLoader;
	import gameLib_JT.resouce.JT_ResouceManager;
	import gameLib_JT.resouce.JT_SWFResource;
	
	import mx.events.FlexEvent;
	import mx.utils.StringUtil;
	
	import spark.components.Group;
	import spark.components.SkinnableContainer;
	import spark.primitives.Graphic;
	
	public class IconComponent extends JT_UIComponent implements JT_IDisposable
	{
		
		/**
		 * 文件地址 
		 */		
		private var mFileUrl:String = "";
		
		/**
		 * 图标类型 
		 */		
		private var mIconType:String = "";
		
		/**
		 * 图标资源装载
		 */		
		private var mSwfResource:JT_SWFResource;
		
		/**
		 * 图标模板 
		 */		
		private var mIconTempCls:Class;
		
		/**
		 * 图标渲染组件
		 */		
		private var mIcon:BitblitICON;
		
		/**
		 *  
		 * @param source						图标文件地址
		 * @param iconTemp						图标的类模板
		 * @param iconType						当前显示的图标状态
		 * 
		 */		
		public function IconComponent(source:String = "",iconTemp:Class=null,iconType:String="")
		{
			super();
			mFileUrl = source;
			mIconTempCls = iconTemp;
			mIconType = iconType;
			
			addEventListener(FlexEvent.CREATION_COMPLETE,createCompleteHandler,false,0,true);
		}
		
		private function createCompleteHandler(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE,createCompleteHandler)
//			addEventListener(Event.ADDED_TO_STAGE,addToStageHandler,false,0,true);
//			addEventListener(Event.REMOVED_FROM_STAGE,removeStageHandler,false,0,true);
			
			if(mIconTempCls)
			{
				invalidateLoadIcon();
			}
		}
		
//		private function addToStageHandler(event:Event):void
//		{
//			if(initialized)
//			{
//				if(mIconTempCls)
//				{
//					invalidateLoadIcon();
//				}
//			}
//		}
		
//		private function removeStageHandler(event:Event):void
//		{
//			if(initialized)
//			{
//				removeEventListener(Event.ENTER_FRAME,nextTimeHandler);
//				destorySwfResource();
//				destoryIcon();
//			}
//		}
		
		
		private function invalidateLoadIcon():void
		{
			addEventListener(Event.ENTER_FRAME,nextTimeHandler,false,0,true);
		}
		
		private function nextTimeHandler(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME,nextTimeHandler);
			if(stage)
			{
				loadIcon();
			}
		}
		
		private function loadIcon():void
		{
			destorySwfResource();
			if(mFileUrl && StringUtil.trim(StringUtil.substitute(mFileUrl)).length > 0)
			{
				mSwfResource = new JT_SWFResource();
				mSwfResource.install(new URLRequest(mFileUrl),installSucceed,installFault);
			}
		}
		
		private function installSucceed(event:Event):void
		{
			if(width > 0 && height > 0)
			{
				destoryIcon();
				var iconCls:Class = mSwfResource.getDomain().getDefinition("icon") as Class;
				mIcon = new mIconTempCls(new BitblitData(iconCls,width,height));
				mIcon.iconType = mIconType;
				addChild(mIcon);
			}
			else
			{
				throw new Error("Please set in width and height");
			}
		}
		
		private function installFault(event:Event):void
		{
			trace("file ioError:",mFileUrl);
		}
		
		public override function dispose():void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE,createCompleteHandler);
			removeEventListener(Event.ENTER_FRAME,nextTimeHandler);
//			removeEventListener(Event.ADDED_TO_STAGE,addToStageHandler);
//			removeEventListener(Event.REMOVED_FROM_STAGE,removeStageHandler);
			destorySwfResource();
			destoryIcon();
			super.dispose();
			
		}
		
		/**
		 * 清除加载的swf资源 
		 * 
		 */		
		private function destorySwfResource():void
		{
			if(mSwfResource)
			{
				mSwfResource.unInstall(); 
				mSwfResource = null;
			}
		}
		
		/**
		 * 清之ICON显示的图标 
		 * 
		 */		
		private function destoryIcon():void
		{
			if(mIcon)
			{
				mIcon.dispose();
				if(mIcon.parent)
				{
					removeChild(mIcon);
					mIcon = null;
				}
			}
		}
		
		public function set source(val:String):void
		{
			
			if(mFileUrl == val) return;
			
			mFileUrl = val;
			
			if(initialized && iconTemp)
			{
				destorySwfResource();
				destoryIcon();
				invalidateLoadIcon();
			}
		}
		
		public function get source():String
		{
			return mFileUrl;				
		}
		
		public function set iconTemp(cls:Class):void
		{
			
			if(mIconTempCls == cls) return;
			mIconTempCls = cls;
			if(initialized)
			{
				destorySwfResource();
				destoryIcon();
				invalidateLoadIcon();
			}
		}
		
		public function get iconTemp():Class
		{
			return mIconTempCls;				
		}
		
		public function set iconType(val:String):void
		{
			if(mIconType == val) return;
			mIconType = val;
			if(mIcon)
			{
				mIcon.iconType = mIconType;
			}
		}
		
		public function get iconType():String
		{
			return mIconType;	
		}
		
		public function get iconProxy():BitblitICON
		{
			return mIcon;
		}
		
	}
}