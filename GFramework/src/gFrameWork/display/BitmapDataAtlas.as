/**
 * 
 * 说明:将一个MovieClip动画转换成bitmapData位图数据源,然后由其它对像进行动画的渲染或位图处理
 * 版本:201206030500
 *  
 */
package gFrameWork.display
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	
	import mx.utils.StringUtil;

	public class BitmapDataAtlas
	{
		
		/**
		 * 动画帧的信息 
		 */		
		private var m_frames:Vector.<FrameInfo> = null;
		
		/**
		 * 动画的源对像 
		 */		
		private var m_oldObject:Object = null;
		
		/**
		 * 渲染的矩形 
		 */		
		private var m_rectangle:Vector.<Rectangle>;
		
		public function BitmapDataAtlas(source:Object)
		{
			m_frames = new Vector.<FrameInfo>();
			m_oldObject = source;
			convert();
		}
		
		/**
		 * 
		 * 转换数据源。 
		 * 
		 */		
		private function convert():void
		{
			try
			{
				var clip:MovieClip;
				var frame:FrameInfo;
				
				if(m_oldObject is String)
				{
					clip =  new (getDefinitionByName(m_oldObject as String) as Class)() as MovieClip;
				}
				else if(m_oldObject is Class)
				{
					clip = new m_oldObject() as MovieClip;	
				}
				else if(m_oldObject is MovieClip)
				{
					clip = m_oldObject as MovieClip;
				}
				else if(m_oldObject is Vector.<BitmapData>)
				{
					var bits:Vector.<BitmapData> = m_oldObject as Vector.<BitmapData>;
					while(bits.length > 0)
					{
						frame = new FrameInfo();
						frame.bitmapData = bits.shift() as BitmapData;
						m_frames.push(frame);
					}
					return;
				}
				
				for(var i:int = 1; i <= clip.totalFrames; i++)
				{
					clip.gotoAndStop(i);
					var theRect:Rectangle = clip.getRect(clip);
					var theFrameData:BitmapData = new BitmapData(theRect.width + Math.abs(theRect.x),theRect.height + Math.abs(theRect.y),true,0);
					theFrameData.draw(clip,new Matrix(1,0,0,1,Math.abs(theRect.x),Math.abs(theRect.y)));
					
					frame = new FrameInfo();
					frame.name = clip.currentFrameLabel;
					frame.bitmapData = theFrameData;
					m_frames.push(frame);
				}
			}
			catch(e:Error)
			{
				throw new ArgumentError(e.message);
			}
		}
		
		/**
		 * 
		 * 根据MovieClip的帧名来获取动画图位集
		 * @param frameName
		 * @return 
		 * 
		 */		
		private function getFrameByName(frameName:String):Vector.<BitmapData>
		{
			
			if(frameName == null || StringUtil.trim(frameName).length == 0)
			{
				throw new Error("frameName can not is null or length is 0");
			}
			
			if(m_frames.length > 0)
			{
				var list:Vector.<BitmapData> = new Vector.<BitmapData>();
				for each(var frame:FrameInfo in m_frames)
				{
					var findFag:Boolean = false;
					
					if(frame.name == frameName)
					{
						list.push(frame.bitmapData);
						findFag = true; 
						continue;
					}
					
					if(!findFag)
					{
						if(frame.name == null || frame.name == "")
						{
							list.push(frame.bitmapData);
						}
						else 
						{
							return list;
						}
					}
				}
				return list;
			}
			return null;
		}
		
		public function getFrames():Vector.<BitmapData>
		{
			if(m_frames.length > 0)
			{
				var list:Vector.<BitmapData> = new Vector.<BitmapData>();	
				for each(var frame:FrameInfo in m_frames)
				{
					list.push(frame.bitmapData);
				}
				return list;
			}
			return null;
		}
		
		/**
		 * 
		 * 如果原数据对像是MovieClip对像的话，请使用此方法，根据帧的名称来获取位图集。 
		 * @param frameName
		 * @return 
		 * 
		 */		
		public function getFramesByName(frameName:String):BitmapDataAtlas
		{
			var bits:Vector.<BitmapData> = getFrameByName(frameName);
			var bitAtlas:BitmapDataAtlas = new BitmapDataAtlas(bits);
			return bitAtlas;
		}
		
		public function dispose():void
		{
			if(m_frames)
			{
				while(m_frames.length > 0)
				{
					m_frames[0].bitmapData.dispose();
					m_frames.shift();
				}
				m_frames = null;
			}
		}
	}
}

import flash.display.BitmapData;

class FrameInfo
{
	public var name:String = "";
	public var bitmapData:BitmapData = null;
}
