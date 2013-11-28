package com.uiComponents.texture
{
	import fl.core.InvalidationType;
	import fl.core.UIComponent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flide.events.FlexTipNodeEvent;
	import flide.display.BitTexture;

	public class Texture extends UIComponent
	{

		//-----------------------------------------
		//属性变量
		//-----------------------------------------


		/**
		 * 是否拒锯齿 
		 */
		private var mSmoothing:Boolean = true;

		/**
		 * 行数 
		 */
		private var mRow:int = 2;

		/**
		 * 列数 
		 */
		private var mColumn:int = 1;

		/**
		 * 切分限制的次数 
		 */
		private var mLimited:int = 0;

		/**
		 * 当前选中的索引默认为0 
		 */
		private var mSelectIndex:int = 0;

		/**
		 * 纹理显示对像 
		 */
		private var mTextureAssets:DisplayObject;

		/**
		 * 纹理逻辑处理 
		 */
		private var mBitTexture:BitTexture;

		/**
		 * 纹理列表 
		 */
		private var bitDataList:Vector.<BitmapData > ;

		/**
		 * 纹理填充的显示对像 
		 */
		private var bitmap:Bitmap;


		
		/**
		 * @private
		 * 默认的样式设置。
		 */
		private static var defaultStyles:Object = {
			textureAssets:"TextureAsset"
		};

		//-----------------------------------------
		//静态方法
		//-----------------------------------------

		/**
		 * 检索当前组件的默认样式映射.
		 * 
		 * <p>样式映射包含适合组件的类型，具体取决于组件使用的样式。</p>
		 * 
		 * <p>例如，<code>disabledTextFormat</code> 样式包含 <code>null</code> 值或 
		 * <code>TextFormat</code> 对象。可以使用这些样式并对当前组件调用 <code>
		 * setStyle()</code>。</p>
		 *
		 * @return 默认样式对象。
		 */
		public static function getStyleDefinition():Object
		{
			return mergeStyles(defaultStyles, UIComponent.getStyleDefinition());
		}

		public function Texture()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE,addToStageHandler,false,0,true);			
		}
		private function addToStageHandler(event:Event):void
		{
			dispatch();		
			
		}

		protected override function configUI():void
		{
			super.configUI();
			initStyles();//样式
		}

		protected function initStyles():void
		{
			//mRow = getStyleValue("row") as int;
//			mColumn = getStyleValue("column") as int;
//			mLimited = getStyleValue("limited") as int;
			mTextureAssets = getDisplayObjectInstance(getStyleValue("textureAssets"));
		}

		protected override function draw():void
		{
			if (isInvalid(InvalidationType.STYLES))
			{
				initStyles();
			}
			if (isInvalid("fullTexture"))
			{
				fullTexture();
			}
			if (isInvalid("drawCell"))
			{
				drawCell();
			}
			if(isInvalid(InvalidationType.SIZE))
			{
				measureSize();
			}
			super.draw();
		}


		/**
		 * 填充纹理 
		 */
		private function fullTexture():void
		{

			//创建纹理
			mBitTexture = new BitTexture(mTextureAssets);

			//获取位图数据列表
			bitDataList = mBitTexture.splitterToArray(mRow,mColumn,mLimited);

			if (! bitmap)
			{
				bitmap = new Bitmap();
			}

			if (! bitmap.parent)
			{
				addChild(bitmap);
			}

			drawCell();

		}

		//绘制显示
		private function drawCell():void
		{
			bitmap.bitmapData = bitDataList[mSelectIndex];
			bitmap.smoothing = mSmoothing;
		}
		
		private function measureSize():void
		{
			if(bitmap)
			{
				bitmap.width = width;
				bitmap.height = height;
			}
		}

		[Inspectable(defaultValue = true,verbose = 1)]
		public function set smoothing(val:Boolean):void
		{
			mSmoothing = val;
			invalidate("drawCell");
		}

		public function get smoothing():Boolean
		{
			return mSmoothing;
		}

		[Inspectable(name = "row",type = "Number",defaultValue = 2)]
		public function set row(val:int):void
		{
			if (mRow == val)
			{
				return;
			}
			mRow = val;
			invalidate("fullTexture");
		}

		public function get row():int
		{
			return mRow;
		}

		[Inspectable(name = "column",type = "Number",defaultValue = 1)]
		public function set column(val:int):void
		{
			if (mColumn == val)
			{
				return;
			}
			mColumn = val;
			invalidate("fullTexture");
		}

		public function get column():int
		{
			return mColumn;
		}

		[Inspectable(name = "limited",type = "Number",defaultValue = 0)]
		public function set limited(val:int):void
		{
			if (mLimited == val)
			{
				return;
			}
			mLimited = val;
			invalidate("fullTexture");
		}

		public function get limited():int
		{
			return mLimited;
		}

		[Inspectable(name = "selectIndex",type = "Number",defaultValue = 0)]
		public function set selectIndex(val:int):void
		{
			if (mSelectIndex == val)
			{
				return;
			}
			mSelectIndex = val;
			invalidate("drawCell");
		}

		public function get selectIndex():int
		{
			return mSelectIndex;
		}
		/**
		 * tip信息 
		 */		
		private var mTip:String;
		
		/**
		 * 旧的tip信息  
		 */		
		private var mOldTip:String;
		
		
		/**
		 *  @private
		 */
		 [Inspectable(name="toolTip", type="String",defaultValue="")]
		public function set toolTip(value:String):void
		{
			mOldTip = mTip;
			mTip = value;
			if(stage)
			{
				dispatch();
			}
		}
		
		public function get toolTip():String
		{
			return mTip;
		}
		
		public function get oldTooltip():String
		{
			return mOldTip;
		}
		
		private function dispatch():void
		{
			if(stage)
			{
				
				stage.dispatchEvent(new  FlexTipNodeEvent("toolTipChanged",false,false,this));
			}
		}
	}
}