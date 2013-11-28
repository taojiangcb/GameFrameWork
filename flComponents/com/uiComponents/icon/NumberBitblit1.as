package com.uiComponents.icon
{
	import com.gskinner.motion.GTween;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import gameLib_JT.JT_IDisposable;
	import gameLib_JT.components.JT_PiovtUIComponent;
	import gameLib_JT.components.JT_UIComponent;
	
	import icon.*;
	import com.uiComponents.icon.BitblitData;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.TweenEvent;
		
	/**
	 * 数字渲染控件 
	 * @author JiangTao
	 */	
	public class NumberBitblit1 extends JT_UIComponent implements JT_IDisposable
	{
			
			//----------------------------------属性变量------------------------------------
			//数据列表
			private var mNumTxtList:Vector.<IconComponent>;
			
			//数字的值
			private var mValue:String = "0";
			
			//各字符之间显示的附加像素数。如果为正值，则会在正常间距的基础上增加字符间距；如果为负值，则减小此间距。 默认值为 0.
			private var mLetterSpacing:int = 0;
			
			//当前的数值
			private var mNumber:int = 0;
			
			private var mSource:String = "";
			
			private var mCellWidth:Number = 0;
			private var mCellHeight:Number = 0;
			
			private var NumberICON:Class = null;
			
			/**
			 * 构建的延时ID 
			 */			
			private var mInvalidateInitID:int = 0;
			
			//------------------内部构造-------------------
			public function NumberBitblit1(source:String="",mNumberICON:Class = null)
			{
				mSource = source;
				NumberICON = mNumberICON;
				mNumTxtList = new Vector.<IconComponent>();
				addEventListener(FlexEvent.CREATION_COMPLETE,createCompleteHandler,false,0,true);
				autoSize();
			}
			
			private function createCompleteHandler(event:FlexEvent):void
			{
				removeEventListener(FlexEvent.CREATION_COMPLETE,createCompleteHandler);
				invalidateInit();
			}
			
			
			private function invalidateInit():void
			{
				if(mInvalidateInitID > 0)
				{
					clearTimeout(mInvalidateInitID);
					mInvalidateInitID = 0;
				}
				
				mInvalidateInitID = setTimeout(internalInit,1000 / 30);
			}
			
			
			private function internalInit():void
			{
				autoSize();
				growthNums();
				invalidateDrawn();
			}
			
			
			//---------------------------内部逻辑处理---------------------------------------
			/**
			 * 刷新绘制新的数字
			 */		
			protected function updateDrawn():void 
			{
				
				if(mNumTxtList && mNumTxtList.length > 0)
				{
					for(var i:int = 0; i < mNumTxtList.length; i++)
					{
						var number:int = int(mValue.substr(i,1)) == 0 ? 10 : int(mValue.substr(i,1));
						mNumTxtList[i].width = cellWidth;
						mNumTxtList[i].height = cellHeight;
						mNumTxtList[i].iconType = number.toString();
					}
					displayLayout();
				}
			}
			
			public function invalidateDrawn():void 
			{
				addEventListener(Event.ENTER_FRAME,nextFrameDraw,false,0,true);
			}
			
			private function nextFrameDraw(event:Event):void
			{
				removeEventListener(Event.ENTER_FRAME,nextFrameDraw);
				updateDrawn();
			}
			
			/**
			 * 释放资源 
			 * 
			 */		
			public override function dispose():void
			{
				removeEventListener(FlexEvent.CREATION_COMPLETE,createCompleteHandler);
				removeEventListener(Event.ENTER_FRAME,nextFrameDraw);
				if(mInvalidateInitID > 0)
				{
					clearTimeout(mInvalidateInitID);
					mInvalidateInitID = 0;
				}
				
				clearOldNums();
				mNumTxtList = null;
				super.dispose();
			}
			
			/**
			 * 清除老的数字 
			 * 
			 */			
			private function clearOldNums():void
			{
				if(mNumTxtList)
				{
					while(mNumTxtList.length > 0)
					{
						if(mNumTxtList[0].parent)
						{
							mNumTxtList[0].parent.removeChild(mNumTxtList[0]);
						}
						mNumTxtList[0].dispose();
						mNumTxtList.shift();
					}
				}
			}
			
			/**
			 * 
			 * 生成数字组件列表
			 * 
			 */			
			private function growthNums():void
			{
				
				if(!NumberICON) return;
				
				if(mSource && mSource.length > 0)
				{
					var growthNum:int = 0;
					var valueLen:int = mValue ? mValue.length : 1; 
					growthNum = valueLen - mNumTxtList.length;
					
					var i:int = 0;
					var numComponent:IconComponent;
					
					if(growthNum > 0)
					{
						for(i = 0; i < growthNum; i++)
						{
							numComponent = new IconComponent(mSource,NumberICON,"0");
							numComponent.width = mCellWidth;
							numComponent.height = mCellHeight;
							addChild(numComponent);
							mNumTxtList.push(numComponent);
						}
					}
					else if(growthNum < 0)
					{
						var clearNum:int = Math.abs(growthNum);
						for(i = 0; i < clearNum; i++)
						{
							var tmpNum:IconComponent = mNumTxtList.pop();
							
							if(tmpNum.parent)
							{
								tmpNum.parent.removeChild(tmpNum);
							}
							
							tmpNum.dispose();
							tmpNum = null;
						}
					}
				}
			}
			
			/**
			 * 自动布局调整大小 
			 * 
			 */			
			public override function autoSize():void
			{
				width = Math.max(1,mValue.length) * mCellWidth + letterSpacing * (mValue.length - 1);
				height = mCellHeight;
			}
			
			/**
			 *
			 * 数字布局控制显示 
			 * 
			 */			
			private function displayLayout():void
			{
				if(mNumTxtList)
				{
					for(var i:int = 0; i < mNumTxtList.length; i++)
					{
						mNumTxtList[i].x = i * (cellWidth + letterSpacing);
						mNumTxtList[i].y = 0;
					}
				}
			}
			
			//---------------------------------相关的属性设定-------------------------------------
			
			/**
			 * 渲染的数字 
			 * @param num
			 */		
			public function set number(val:int):void
			{
				if(mNumber == Math.abs(val)) return;
				mNumber = Math.abs(val);
				value = number;
				autoSize();
				if(initialized)
				{
					invalidateInit();
				}
			}
			
			public function get number():int
			{
				return mNumber;
			}
			
			public function set cellWidth(val:int):void
			{
				if(mCellWidth == val) return;
				mCellWidth = val;
				autoSize();
				if(initialized)
				{
					displayLayout();
				}
			}
			
			public function get cellWidth():int
			{
				return mCellWidth;
			}
			
			public function set cellHeight(val:int):void
			{
				if(mCellHeight == val) return;
				mCellHeight = val;
				autoSize();
				if(initialized)
				{
					displayLayout();
				}
			}
			
			public function get cellHeight():int
			{
				return mCellHeight;
			}
			
			/**
			 * 数字之间的水平间隔 
			 * @param value
			 */		
			public function set letterSpacing(value:int):void
			{
				if(mLetterSpacing == value) return;
				mLetterSpacing = value;
				autoSize();
				if(initialized)
				{
					autoSize();
					displayLayout();
				}
			}
			
			public function get letterSpacing():int
			{
				return mLetterSpacing;			
			}
			
			/**
			 * 当前渲染的值,只是内部调用 
			 * @param num
			 * 
			 */		
			private function set value(num:int):void
			{
				mValue = Math.abs(num).toString();
			}
			
			private function get value():int
			{
				return int(mValue);
			}
			
			public function set source(val:String):void
			{
				if(source == val) return;
				mSource = val;
				if(initialized)
				{
					clearOldNums();
					invalidateInit();
				}
			}
			
			public function get source():String
			{
				return mSource;	
			}
			
			public function set iconTemp(cls:Class):void
			{
				NumberICON = cls;
				if(initialized)
				{
					clearOldNums();
					invalidateInit();
				}
			}
			
			public function get iconTemp():Class
			{
				return NumberICON;				
			}
		}
	}