/**
 * 说明: 位图版本的MovieClip但帧数是从0开始并非从1开始
 * 版本:201206030548
 */
package gFrameWork.display
{
	import gFrameWork.display.MovieClipPool;
	import gFrameWork.display.IAnimatable;
	import gFrameWork.display.events.GFEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.media.Sound;
	
	[Event(name="movieCompleted",type="gameLib_JT.events.JT_Event")]
	[Event(name="movieStop",type="gameLib_JT.events.JT_Event")]
	[Event(name="moviePlayer",type="gameLib_JT.events.JT_Event")]
	public class BitMovieClip extends PivotSprite implements IAnimatable
	{
		/**
		 * 动画播放数据源 
		 */		
		private var m_bitmapDataAtlas:BitmapDataAtlas;
		
		/**
		 * 播放动画时控制的帧频 
		 */		
		private var m_fps:uint = 0;
		
		/**
		 *  默认每帧播放的持续时间
		 */		
		private var m_defaultfarmeDuration:Number = 0;
		
		/**
		 * 是否可以循环播放 
		 */		
		private var m_loop:Boolean = true;
		
		/**
		 * 是否在播放中 
		 */		
		private var m_playing:Boolean = false;
		
		/**
		 * 播放的总时长 
		 */		
		private var m_totalTime:Number = 0;
		
		/**
		 * 当前播放帧的时间 
		 */		
		private var m_currentTime:Number = 0;
		
		/**
		 * 当前播放的帧数 
		 */		
		private var m_currentFrame:int = 0;
		
		/**
		 * 各帧播放的持续时间
		 */		
		private var m_frameDuration:Vector.<Number> = null;
		
		/**
		 * 各帧播放的起始时间 
		 */		
		private var m_startTimes:Vector.<Number> = null;
		
		/**
		 * 各帧的音效 
		 */		
		private var m_sound:Vector.<Sound> = null;
		
		/**
		 * 当前播放动画的帧 
		 */		
		private var m_frames:Vector.<BitmapData>;
		
		
		/**
		 * 设置回调函数处理 
		 */		
		private var m_callBackFuncs:Vector.<Function>;
		
		/**
		 * 当前播放的序列ID 
		 */		
		private var playID:uint = 0;
		
		/**
		 * 位图图形渲染 
		 */		
		private var m_bitmap:Bitmap;
		
		/**
		 * 倒回播放
		 */		
		private var m_reverse:Boolean;
		
		/**
		 *  
		 * @param frame					播放动画的帧
		 * @param fps					帧频
		 * @param loop					是否循环播放
		 * @param reserse				是否倒回播放
		 * 
		 */		
		public function BitMovieClip(frame:BitmapDataAtlas,fps:uint=30,loop:Boolean = true,reverse:Boolean=false):void
		{
			super();
			m_bitmapDataAtlas = frame;
			if(m_bitmapDataAtlas)
			{
				m_fps = fps;
				m_loop = loop;
				m_reverse = reverse;
				m_defaultfarmeDuration = Math.round(1000 / m_fps);
				
				m_callBackFuncs = new Vector.<Function>();
				m_frameDuration = new Vector.<Number>();
				m_startTimes = new Vector.<Number>();
				m_sound = new Vector.<Sound>();
				m_frames = new Vector.<BitmapData>();
				m_bitmap = new Bitmap(null,"auto",true);
				addChild(m_bitmap);
				
				var bit:BitmapData;
				for each(bit in m_bitmapDataAtlas.getFrames())
				{
					addFrame(bit);
				}
				
				if(totalFrames > 0)
				{
					m_bitmap.bitmapData = m_frames[0];
					//new JT_MovieClip 后必须手动调用Player才会播放动画，为了节省cup
					//					updateFrame();
				}
			}
			
			addEventListener(Event.ADDED_TO_STAGE,addToStageHandler,false,0,true);
			addEventListener(Event.REMOVED_FROM_STAGE,removeStageHandler,false,0,true);
		}
		
		private function addToStageHandler(event:Event):void
		{
			MovieClipPool.add(this);
		}
		
		private function removeStageHandler(event:Event):void
		{
			MovieClipPool.remove(this);
		}
		
		private function addFrame(bitmapData:BitmapData):void
		{
			addFrameAt(totalFrames,bitmapData,null,null,-1);
		}
		
		public function addFrameAt(frameID:int,bitmapData:BitmapData,sound:Sound,callBackFunc:Function,duration:Number=-1):void
		{
			if(frameID <0 || frameID > totalFrames) throw new ArgumentError("invalida frame id");
			if(duration < 0) duration = m_defaultfarmeDuration;
			
			m_frames.splice(frameID,0,bitmapData);
			m_sound.splice(frameID,0,sound);
			m_frameDuration.splice(frameID,0,duration);
			m_callBackFuncs.splice(frameID,0,callBackFunc);
			m_totalTime += duration;
			
			if(frameID > 0 && frameID == totalFrames)
			{
				m_startTimes[frameID] = m_startTimes[frameID - 1] + m_frameDuration[frameID - 1];
			}
			else
			{
				updateStartTimes();
			}
		}
		
		public function removeFrameAt(frameID:int):void
		{
			if(frameID < 0 || frameID > totalFrames) throw new ArgumentError("invalida frame id");
			if(totalFrames == 0) throw new IllegalOperationError("movie clip must not be empty");
			
			m_totalTime -= m_frameDuration[frameID];
			
			m_frames.splice(frameID,1);
			m_sound.splice(frameID,1);
			m_frameDuration.splice(frameID,1);
			
			updateStartTimes();
		}
		
		private function updateStartTimes():void
		{
			var frameNums:int = totalFrames;
			m_startTimes.length = 0;
			m_startTimes[0] = 0;
			
			for(var i:int = 1; i < frameNums; i++)
			{
				m_startTimes[i] = m_startTimes[i - 1] + m_frameDuration[i - 1];
			}
		}
		
		//		private function updateFrame():void
		//		{
		//			if(m_frameDuration && m_frameDuration.length > 0)
		//			{
		//				var duration:Number = m_frameDuration[m_currentFrame];
		//				if(playID > 0)
		//				{
		//					clearTimeout(playID);
		//					playID = 0;
		//				}
		//				if(m_playing && duration > 0 && m_fps > 0)
		//				{
		//					playID = setTimeout(advanceTime,duration,duration);
		//				}
		//			}
		//		}
		
		public override function dispose():void
		{
			m_playing = false;
			
			removeEventListener(Event.ADDED_TO_STAGE,addToStageHandler);
			removeEventListener(Event.REMOVED_FROM_STAGE,removeStageHandler);
			
			MovieClipPool.remove(this);
			
			if(playID > 0)
			{
				playID = 0;
			}
			
			if(stage)
			{
				stage.removeEventListener(Event.RENDER,renderHandler);
			}
			
			if(m_bitmap)
			{
				if(m_bitmap.parent)
				{
					m_bitmap.parent.removeChild(m_bitmap);
					m_bitmap = null;
				}
			}
			
			if(m_frames)
			{
				m_frames.length = 0;
			}
			
			if(m_sound)
			{
				while(m_sound.length > 0)
				{
					if(m_sound[0] != null)
					{
						m_sound[0].close();
					}
					m_sound.shift();
				}
				m_sound = null;
			}
		}
		
		/**
		 * 
		 * 播放
		 * 
		 */		
		public function player():void
		{
			m_playing = true;
		}
		
		/**
		 * 
		 * 暂停 
		 * 
		 */		
		public function stop():void
		{
			m_playing = false;
		}
		
		/**
		 * 跳转 某帧暂停
		 * @param _frameID
		 * 
		 */		
		public function gotoAndStop(_frameID:int):void
		{
			m_currentFrame = _frameID;
			m_currentTime = 0.0;
			
			for (var i:int=0; i< _frameID; ++i)
			{
				m_currentTime += m_frameDuration[i];
			}
			
			if(m_frames.length > 0)
			{
				if(m_frames[m_currentFrame])
				{
					m_bitmap.bitmapData = m_frames[m_currentFrame];
				}
			}
			
			if(m_sound && m_sound.length > 0)
			{
				if (m_sound[m_currentFrame]) 
				{
					m_sound[m_currentFrame].play();
				}
			}
			
			m_playing = false;
			
		}
		
		/**
		 * 跳转到某帧并继续播放 
		 * @param _frameID
		 * 
		 */		
		public function gotoAndPlayer(_frameID:int):void
		{
			m_currentFrame = _frameID;
			m_currentTime = 0.0;
			
			for (var i:int=0; i< _frameID; ++i)
			{
				m_currentTime += m_frameDuration[i];
			}
			
			m_bitmap.bitmapData = m_frames[m_currentFrame];
			if (m_sound[m_currentFrame])
			{
				m_sound[m_currentFrame].play();
			}
			
			m_playing = true;
			
		}
		
		private function renderHandler(event:Event):void
		{
			if(m_bitmap && m_frames)
			{
				m_bitmap.bitmapData = m_frames[m_currentFrame] as BitmapData;
			}
			if(stage)
			{
				stage.removeEventListener(Event.RENDER,renderHandler);
			}
		}
		
		/**
		 * 动画播放 
		 * @param passedTime
		 * 
		 */		
		public function advanceTime(passedTime:Number):void
		{
			if(!m_playing) return;
			if(!stage) return;
			if(totalFrames == 0) return;
			
			var finalFrame:int;
			var previousFrame:int = m_currentFrame;
			
			if (m_loop && m_currentTime == m_totalTime) { m_currentTime = 0.0; m_currentFrame = 0;}
			if (!m_playing || passedTime == 0.0 || m_currentTime == m_totalTime) return;
			
			m_currentTime += passedTime;
			finalFrame = totalFrames - 1;
			
			if(finalFrame <= 0) return;
			
			if (stage)
			{
				stage.addEventListener(Event.RENDER,renderHandler,false,0,true);
				stage.invalidate();
			}
			
			//			m_bitmap.bitmapData = m_frames[m_currentFrame] as BitmapData;
			
			while(m_currentTime >= m_startTimes[m_currentFrame] + m_frameDuration[m_currentFrame])
			{
				if (m_currentFrame == finalFrame)
				{
					if(m_reverse)
					{
						/*倒置播放的执行时间*/
						var reserseDuration:Vector.<Number> = new Vector.<Number>();
						var cloneDuration:Vector.<Number> = m_frameDuration.concat();
						while(cloneDuration.length > 0)
						{
							reserseDuration.unshift(cloneDuration.shift());
						}
						m_frameDuration = reserseDuration;
						
						/*倒置播放的位图数据*/
						var reserseFrames:Vector.<BitmapData> = new Vector.<BitmapData>();
						var cloneReserseFrames:Vector.<BitmapData> = m_frames.concat();
						while(cloneReserseFrames.length > 0)
						{
							reserseFrames.unshift(cloneReserseFrames.shift());
						}
						m_frames = reserseFrames;
						
						m_currentTime = 0;
						m_currentFrame = 0;
					}
						
					else if(m_loop)
					{
						m_currentTime = 0;
						m_currentFrame = 0;
					}
					else
					{
						m_currentTime = 0;
					}
					
					if(hasEventListener(GFEvent.MOVIE_COMPLETED))
					{
						dispatchEvent(new GFEvent(GFEvent.MOVIE_COMPLETED));
					}
					break;
				}
				else
				{
					m_currentFrame++;
					var sound:Sound = m_sound[m_currentFrame];
					if (sound)
					{
						sound.play();
					}
					
					var func:Function = m_callBackFuncs[m_currentFrame];
					if(func != null)
					{
						func();
					}
				}
			}
		}
		
		/**
		 * 某帧的声音 
		 * @param frameID
		 * @param sound
		 * 
		 */		
		public function setFrameSound(frameID:int,sound:Sound):void
		{
			if(frameID <0 || frameID > totalFrames) throw new ArgumentError("invalida frame id");
			m_sound[frameID] = sound;
		}
		
		/**
		 * 某帧处理的回调函数 
		 * @param frameID
		 * @param func
		 * 
		 */		
		public function setFrameCallFunc(frameID:int,func:Function):void
		{
			if(frameID < 0 || frameID > totalFrames) throw new ArgumentError("invalida frame id");
			m_callBackFuncs[frameID] = func;
		}
		
		/**
		 * 某帧的时间 
		 * @param frameID
		 * @param duration
		 */		
		public function setFrameDuration(frameID:int,duration:Number):void
		{
			if(frameID <0 || frameID > totalFrames) throw new ArgumentError("invalida frame id");
			m_frameDuration[frameID] = duration;
		}
		
		/**
		 * 设置当前动画的帧频率 
		 * @param fps
		 * 
		 */		
		public function setFps(fps:uint):void
		{
			m_fps = fps;
			stop();
			m_defaultfarmeDuration = Math.round(1000 / m_fps);
			
			if(m_frameDuration)
			{
				for(var i:int = 0; i != m_frameDuration.length; i++)
				{
					m_frameDuration[i] = m_defaultfarmeDuration;
				}
				updateStartTimes();
			}
			player();
		}
		
		/**
		 * 获取该动画的时间总长 
		 */		
		public function getTotalTime():Number
		{
			return m_totalTime;
		}
		
		public function getFps():uint
		{
			return m_fps;
		}
		
		/**
		 * 总帧数 
		 * @return 
		 */		
		public function get totalFrames():int
		{
			return m_frames.length;
		}
	}
}