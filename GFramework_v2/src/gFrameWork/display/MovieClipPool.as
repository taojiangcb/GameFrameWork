package gFrameWork.display
{
	
	/**
	 * 动画对像池管理
	 * @author JT
	 * 
	 */	
	public class MovieClipPool
	{
		
		private static var mPool:Pool = null;
		
		public function MovieClipPool()
		{
				
		}
		
		public static function add(val:IAnimatable):void
		{
			poolMgr.add(val);
		}
		
		public static function remove(val:IAnimatable):void
		{
			poolMgr.remove(val);
		}
		
		private static function get poolMgr():Pool
		{
			if(!mPool)
			{
				mPool = new Pool();
			}
			return mPool;
		}
	}
}
import gFrameWork.display.IAnimatable;

import flash.events.Event;
import flash.utils.clearInterval;
import flash.utils.setInterval;

import gFrameWork.GFrameWork;


class Pool
{
	/**
	 * 计时器ID 
	 */	
	private var internalID:int = 0;
	
	/**
	 * 频率ID 
	 */	
	private var fps:int = 30;
	
	/**
	 * 间隔时间 
	 */	
	private var duration:int = 1000 / fps;
	
	/**
	 * 动画列表
	 */	
	private var animationList:Vector.<IAnimatable> = null;
	
	/**
	 * 动画对队锁，因为删除过程可能与动画过程步同执行。 
	 */	
	private var block:Boolean = false;
	
	public function Pool():void
	{
		animationList = new Vector.<IAnimatable>();
	}
	
	/**
	 * 添加一个动画到池中
	 * @param val
	 */	
	public function add(val:IAnimatable):void
	{
		if(val != null)
		{
			var index:int = animationList.indexOf(val);
			if(index == -1)
			{
				animationList.push(val);
			}
		}
		
		if(internalID == 0 && animationList.length > 0)
		{
			GFrameWork.getInstance().root.addEventListener(Event.ENTER_FRAME,intervalHandler);
		}
	}
	
	/**
	 * 从池中删除一个动画 
	 * @param val
	 * 
	 */	
	public function remove(val:IAnimatable):void
	{
		block = true;
		
		GFrameWork.getInstance().root.removeEventListener(Event.ENTER_FRAME,intervalHandler)
		
		var index:int = animationList.indexOf(val);
		if(index > -1)
		{
			animationList.splice(index,1);
		}
		
		if(animationList.length > 0)
		{
			GFrameWork.getInstance().root.addEventListener(Event.ENTER_FRAME,intervalHandler);
		}
		block = false;
	}
	
	/**
	 * 每帧执行的刷新动画 
	 * @param event
	 * 
	 */	
	private function intervalHandler(event:Event):void
	{
		if(!block)
		{
			var i:int = 0;
			var len:int = animationList.length;
			while(animationList.length > 0)
			{
				if(i >= animationList.length)
				{
					return
				}
				else
				{
					animationList[i].advanceTime(duration);
				}
				i++;
			}
		}
	}
}