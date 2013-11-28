package  com.uiComponents.bitNumber
{
	import fl.core.InvalidationType;
	import fl.core.UIComponent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	
	
	/**
	 * 数字
	 *
	 * @default "NumberAssets"
	 */
	[Style(name="NumberAssets", type="Class")]
	/**
	 * 单元宽度
	 * @default "17"
	 */
	[Style(name="cellWidth",  type="Number", format="Length")]
	
	/**
	 * 单元高度
	 * @default "21"
	 */
	[Style(name="cellHeight",  type="Number", format="Length")]
	/**
	 * 单元的间隔
	 * @default "Calendar_arrowIconDisabled"
	 */
	[Style(name="contentPadding", type="Number",format="Lenght")]
	
	/**
	 * 
	 * 位图数字渲染组件 
	 * @author JT
	 * 
	 */	
	public class BitNumber extends UIComponent 
	{
		
		/*变量属性*/
	
		/**
		 * 数据切片宽 
		 */		
		private var mCellWidth:int = 0;
		
		/**
		 * 数字切片高
		 */		
		private var mCellHeight:int = 0;
		
		/**
		 * 间隔 
		 */		
		private var mContentPadding:int = 0;
		
		
		/**
		 * 要渲染的数字 
		 */		
		private var mValue:String = "0";
		
		/**
		 * 数字渲染集  
		 */		
		private var mBitData:BitmapData;
		private var mBit:Bitmap;
		
		
		/**
		 * 数字 
		 */		
		private var mNumDisplay:DisplayObject;
		
		/**
		 * 数字源 
		 */		
		private var bitSource:BitmapData = null;
		
		/**
		 * @private
		 * 默认的样式设置。
		 */
		private static var defaultStyles:Object = {
			numberAssets:"NumberAssets",
			contentPadding:2,
			cellWidth:17,
			cellHeight:21
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
		public static function getStyleDefinition():Object { 
			return mergeStyles(defaultStyles, UIComponent.getStyleDefinition());
		}
		
		public function BitNumber() 
		{
			super();
		}
		
		/**
		 * 配置相关的参数 
		 * 
		 */		
		protected override function configUI():void
		{
			super.configUI();
			initStyles();				//样式
			autoSize();					//大小
		}
		
		/**
		 * 初始化相关样式数据 
		 */		
		protected function initStyles():void
		{
			mCellWidth = getStyleValue("cellWidth") as int;
			mCellHeight = getStyleValue("cellHeight") as int;
			mContentPadding = getStyleValue("contentPadding") as int;
			mNumDisplay = getDisplayObjectInstance(getStyleValue("numberAssets"));
		}
		
		/**
		 * 计算数字的高与宽 
		 */		
		private function autoSize():void
		{
			width = Math.max(1,mValue.length) * mCellWidth + mContentPadding * (mValue.length - 1);
			height = mCellHeight;
		}
		
		/**
		 * 开始渲染绘制 
		 */		
		protected override function draw():void
		{
			if(invalidHash[InvalidationType.ALL])
			{
				autoSize();
				drawNumber();
			}
			else
			{
				/*重新计算大小*/
				if(invalidHash[InvalidationType.SIZE])
				{
					autoSize();
				}
				
				/*开始渲染*/
				if(invalidHash["drawNumber"])
				{
					drawNumber();
				}
			}
			
			super.draw();
		}
		
		/**
		 * 开始演染数字 
		 * 
		 */		
		private function drawNumber():void
		{
			var n:int = mValue.length;
			if(!bitSource)
			{
				bitSource = new BitmapData(mNumDisplay.width,mNumDisplay.height,true,0);
				bitSource.draw(mNumDisplay);
			}
			if(bitSource)
			{
				
				mBitData = new BitmapData(width,height,true,0);
				
				for(var i:int = 0;i< n;i++)
				{
					var number:int = int(mValue.substr(i,1)) == 0 ? 10 : int(mValue.substr(i,1));
					var cellBit:BitmapData = new BitmapData(mCellWidth,mCellHeight,true,0);
					cellBit.copyPixels(bitSource,new Rectangle(0,(number-1)*mCellHeight,mCellWidth,mCellHeight),new Point())
					//mBitData.copyPixels(bitSource,new Rectangle(0,(number-1)*mCellHeight,mCellWidth,mCellHeight),new Point(i * (mCellWidth + mContentPadding,0)));
					mBitData.draw(cellBit,new Matrix(1,0,0,1,i * (mCellWidth + mContentPadding),0));
				}
				
				if(!mBit)
				{
					mBit = new Bitmap();
				}
				
				mBit.bitmapData = mBitData;
				mBit.smoothing = true;
				
				if(!mBit.parent)
				{
					addChild(mBit);
				}
			}
		}
		
		[Inspectable(name="number", type="Number",defaultValue=0)]
		/**
		 * 渲染的数字 
		 * @param val
		 */		
		public function set number(val:int):void
		{
			mValue = val.toString();
			invalidate(InvalidationType.SIZE);
			invalidate("drawNumber");
		}
		
		public function get number():int
		{
			return int(mValue);
		}
		
		[Inspectable(name="contentPadding", type="Number",defaultValue=2)]
		public function set contentPadding(val:int):void
		{
			mContentPadding = val;
			invalidate(InvalidationType.SIZE);
			invalidate("drawNumber");
		}
		
		public function get contentPadding():int
		{
			return mContentPadding;
		}
		
		[Inspectable(name="cellWidth", type="Number", defaultValue=17)]
		public function set cellWidth(val:int):void
		{
			mCellWidth = val;
			invalidate(InvalidationType.SIZE);
			invalidate("drawNumber");
		}
		
		public function get cellWidth():int
		{
			return mCellWidth;
		}
		
		[Inspectable(name="cellHeight", type="Number",defaultValue=21)]
		public function set cellHeight(val:int):void
		{
			mCellHeight = val;
			invalidate(InvalidationType.SIZE);
			invalidate("drawNumber");
		}
		
		public function get cellHeight():int
		{
			return mCellHeight;
		}
		
		public function set numDisplay(val:DisplayObject):void
		{
			mNumDisplay = val;
			invalidate("drawNumber");
		}
		
		public function get numDisplay():DisplayObject
		{
			return mNumDisplay;
		}
	}
	
}
