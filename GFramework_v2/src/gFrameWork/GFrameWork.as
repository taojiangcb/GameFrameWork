package gFrameWork
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.net.LocalConnection;

	/**
	 * 游戏的内核入口 
	 * @author JT
	 * 
	 */	
	public class GFrameWork
	{
		
		/**
		 * 单例 
		 */		
		private static var mInstance:GFrameWork;
		private static var mInterCall:Boolean = false;
		
		public static function getInstance():GFrameWork
		{
			if(!mInstance)
			{
				mInterCall = true;
				mInstance = new GFrameWork();
				mInterCall = false;
			}
			return mInstance;
		}
		
		/**
		 * 主场景
		 */		
		private var mRoot:Sprite;
		
		/**
		 * 窗口空间层 
		 */		
		private var mWinSpace:Sprite;
		
		
		public function GFrameWork()
		{
			if(!mInterCall)
			{
				throw new Error("Please use the getInstance () function.");
			}
		}
		
		/**
		 * 初始化游戏内核心 
		 * @param root  		主场景
		 * @param winSpace		窗口层
		 * 
		 */		
		public function internalInit(root:Sprite):void
		{
			mRoot = root;
		}
		
		/**
		 * 启动GC回收内存 
		 */		
		public function gc():void
		{
			try
			{
				new LocalConnection().connect("conn");
				new LocalConnection().connect("conn");
			}
			catch(e:Error){}
		}
		
		/**
		 * 获取当前游戏的窗口大小 
		 * @return 
		 * 
		 */		
		public function get stageSize():Rectangle
		{
			return new Rectangle(0,0,root.stage.stageWidth,root.stage.stageHeight);	
		}
		
		public function get root():Sprite
		{
			return mRoot;
		}
		
	}
}