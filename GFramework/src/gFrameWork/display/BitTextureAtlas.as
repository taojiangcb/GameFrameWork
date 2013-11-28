//-------------------------------
//
// 	位图贴图集，将一个贴图图片根据xml传入的数据内容转换成一个位图集数据，
//	然后根据贴图的名称来获取相关的位图数据列表。
//
//-------------------------------
package gFrameWork.display
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import gFrameWork.IDisabled;
	

	public class BitTextureAtlas implements IDisabled
	{
		/**
		 * 位图的数据源 
		 */		
		private var mSourceBit:BitmapData;
		
		/**
		 * 帧区块集
		 */		
		private var mFrames:Dictionary;
		
		/**
		 * 图形位图区块集 
		 */		
		private var mTextureRegions:Dictionary;
		
		/**
		 * 解析位图的数据源 
		 */		
		private var mData:XML;
		
		public function BitTextureAtlas(srcbit:BitmapData,data:XML)
		{
			mSourceBit = srcbit;
			mData = data;
			
			mFrames = new Dictionary();
			mTextureRegions = new Dictionary();
			
			parseXML();
			
		}
		
		/**
		 * 
		 * 根据名称和相关的位置信息所系索引到相关的位图片段 
		 * @param sourceBit
		 * @param rectange
		 * @param frameRect
		 * @return 
		 * 
		 */		
		private function findBit(sourceBit:BitmapData,rectange:Rectangle,frameRect:Rectangle):BitmapData
		{
			if(rectange && sourceBit)
			{
				
				var offPoint:Point = new Point(Math.abs(frameRect.x),Math.abs(frameRect.y));
				var bitData:BitmapData = new BitmapData(frameRect.width,frameRect.height,true,0);
				bitData.copyPixels(sourceBit,rectange,offPoint);
				return bitData;

			}
			return null;
		}
		
		/**
		 *
		 * 解析帖图数据
		 *   
		 */		
		private function parseXML():void
		{
			for each (var subTexture:XML in mData.SubTexture)
			{
				var name:String        = subTexture.attribute("name");
				var x:Number           = parseFloat(subTexture.attribute("x"));
				var y:Number           = parseFloat(subTexture.attribute("y"));
				var width:Number       = parseFloat(subTexture.attribute("width"));
				var height:Number      = parseFloat(subTexture.attribute("height"));
				var frameX:Number      = parseFloat(subTexture.attribute("frameX"));
				var frameY:Number      = parseFloat(subTexture.attribute("frameY"));
				var frameWidth:Number  = parseFloat(subTexture.attribute("frameWidth"));
				var frameHeight:Number = parseFloat(subTexture.attribute("frameHeight"));
				
				var region:Rectangle = new Rectangle(x, y, width, height);
				var frame:Rectangle = new Rectangle(frameX, frameY, frameWidth, frameHeight);
				addRegion(name, region, frame);
			}
		}
		
		private function addRegion(name_:String,region_:Rectangle,frame_:Rectangle):void
		{
			mTextureRegions[name_] = region_;
			mFrames[name_] = frame_;
		}
		
		/**
		 * 
		 * 根据帖图的名称来获取相关的帖图的位图数据列表 
		 * @param parseName
		 * @return 
		 * 
		 */		
		public function getBitmapDatas(parseName:String):Vector.<BitmapData>
		{
			var bits:Vector.<BitmapData> = new Vector.<BitmapData>();
			var names:Vector.<String> = new Vector.<String>();
			var name:String;
			
			for(name in mTextureRegions)
			{
				if(name.indexOf(parseName) == 0)
				{
					names.push(name);
				}
			}
			
			names.sort(Array.CASEINSENSITIVE);
			var i:int = 0;
			
			for(i = 0; i < names.length; i++)
			{
				bits.push(getBitByName(names[i]));
			}
			
			return bits;
			
		}
		
		/**
		 * 
		 * 删除一张位图数据 
		 * @param bitName
		 * 
		 */		
		public function removeBitmapdata(bitName:String):void
		{
			if(mTextureRegions[bitName])
			{
				delete mTextureRegions[bitName];
			}
		}
		
		public function dispose():void
		{
			mFrames = null;
			mTextureRegions = null;
			mSourceBit = null;
		}
		
		
		private function getBitByName(name:String):BitmapData
		{
			var rect:Rectangle = mTextureRegions[name];
			if(!rect)
			{
				return null;
			}
			else
			{
				return findBit(mSourceBit,rect,mFrames[name]);
			}
		}
	}
}