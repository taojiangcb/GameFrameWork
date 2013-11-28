package com.uiComponents.avatarImage
{

	import com.uiComponents.texture.Texture;

	import fl.containers.UILoader;
	import fl.core.InvalidationType;
	import fl.core.UIComponent;

	import flash.display.MovieClip;
	import flide.events.FlexTipNodeEvent;
	import flash.events.Event;
	import flash.display.Bitmap;

	/**
	 * 游戏中的图片组件，其中包括图片加载和品级边框 
	 * @author JT
	 * 
	 */
	public class AvatarImage extends UIComponent
	{

		/**
		 * @private
		 */
		private static var defaultStyles:Object = {
		avatarBorder:"AvatarBorderSkill"
		};

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

		/**
		 * 加载 
		 */
		private var mUILoader:UILoader;

		/**
		 * 边框 
		 */
		private var mBorderTexture:Texture;

		/**
		 * 图片的加载地址 
		 */
		private var mSource:String = "";

		/**
		 * 品质等级 
		 */
		private var mLevel:int = 0;

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
		 * 是否拒锯齿 
		 */
		private var mSmoothing:Boolean = true;


		public function AvatarImage()
		{
			super();
			createChild();
			addEventListener(Event.ADDED_TO_STAGE,addToStageHandler,false,0,true);
			mUILoader.addEventListener(Event.COMPLETE,completeHandler,false,0,true);
		}

		private function addToStageHandler(event:Event):void
		{
			dispatch();
		}

		/**
		 * 构建子级 
		 */
		private function createChild():void
		{

			mUILoader = new UILoader();
			addChild(mUILoader);

			mBorderTexture = new Texture();
			addChild(mBorderTexture);
		}

		/**
		 * 绘制 
		 */
		protected override function draw():void
		{
			if (isInvalid(InvalidationType.SIZE))
			{
				drawLayout();
			}

			if (isInvalid(InvalidationType.STYLES))
			{
				mBorderTexture.setStyle("textureAssets",getStyleValue("avatarBorder"));
			}

			if (isInvalid(InvalidationType.DATA))
			{
				commitproperties();
			}

			super.draw();
		}

		/**
		 * 布局 
		 */
		protected function drawLayout():void
		{
			mUILoader.setSize(width,height);
			mBorderTexture.setSize(width,height);
		}

		/**
		 * 设置相关的属性 
		 */
		protected function commitproperties():void
		{
			mUILoader.addEventListener(Event.COMPLETE,completeHandler,false,0,true);
			mUILoader.source = source;
			mBorderTexture.selectIndex = Math.max(mLevel - 1,0);
			mBorderTexture.row = row;
			mBorderTexture.column = column;
			mBorderTexture.limited = limited;
		}

		private function completeHandler(event:Event):void
		{
			if (mUILoader)
			{
				mUILoader.removeEventListener(Event.COMPLETE,completeHandler);
			}
			if (mUILoader && mUILoader.content)
			{

				mUILoader.removeEventListener(Event.COMPLETE,completeHandler);
				if (mUILoader.content)
				{
					var image:Bitmap = Bitmap(mUILoader.content);
					image.smoothing = mSmoothing;
				}
			}

		}

		[Inspectable(name = "source",type = "String",defaultValue = "")]
		public function set source(val:String):void
		{
			if (mSource == val)
			{
				return;
			}
			mSource = val;
			mUILoader.source = mSource;
		}

		public function get source():String
		{
			return mSource;
		}

		[Inspectable(name = "level",type = "Number",defaultValue = 1)]
		public function set level(val:int):void
		{
			if (mLevel == val)
			{
				return;
			}
			mLevel = val;
			mBorderTexture.selectIndex = Math.max(mLevel - 1,0);
		}

		public function get level():int
		{
			return mLevel;
		}

		[Inspectable(defaultValue = true,verbose = 1)]
		public function set smoothing(val:Boolean):void
		{
			mSmoothing = val;
			if (mUILoader)
			{
				if (mUILoader.content)
				{
					var image:Bitmap = Bitmap(mUILoader.content);
					image.smoothing = mSmoothing;
				}
			}
			//invalidate(InvalidationType.DATA);
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
			mBorderTexture.row = row;
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
			mBorderTexture.column = column;
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
			mBorderTexture.limited = limited;
		}

		public function get limited():int
		{
			return mLimited;
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
		[Inspectable(name = "toolTip",type = "String",defaultValue = "")]
		public function set toolTip(value:String):void
		{
			mOldTip = mTip;
			mTip = value;
			if (stage)
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
			if (stage)
			{
				stage.dispatchEvent(new FlexTipNodeEvent("toolTipChanged",false,false,this));
			}
		}

	}
}