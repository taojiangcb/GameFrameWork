package gFrameWork.tooltip
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.sampler.Sample;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	
	import gFrameWork.GFrameWork;

	/**
	 * 默认的TOOLTI文本显示 
	 * @author taojiang
	 * 
	 */	
	public class DefaultTooltip extends TooltipBase implements ITooltip
	{
		/**
		 * 文本显示 
		 */		
		private var textField:TextField
		
		/**
		 * 提示的文本内容 
		 */		
		private var tooltip:String = "";
		
		/**
		 * 最大宽度显示 
		 */		
		private var maxWidth:int = 300;
		
		/**
		 * tip内容显示 
		 */		
		private var tipString:String;
		
		/**
		 * 显示的动画缓动 
		 */		
		private var mGTween:GTween;
		
		public function DefaultTooltip()
		{
			super();
			
			textField = new TextField();
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.wordWrap = false;
			addChild(textField);
			alpha = 0;
		}
		
		/**
		 * 更新参数显示 
		 * 
		 */		
		protected override function commitproperties():void
		{
			super.commitproperties();
			
			textField.text = String(tip);
			if(textField.width > maxWidth)
			{
				textField.wordWrap = true;
				textField.width = maxWidth;
			}
		}
		
		/**
		 * 刷新显示 
		 * 
		 */		
		protected override function updateDisplay():void
		{
			super.updateDisplay();
			
			var gp:Graphics = graphics;
			gp.clear();
			gp.lineStyle(0, 0x000000);
			gp.beginFill(0xFFFFCC);
			gp.drawRect(0,0,width,height);
			gp.endFill();
		}
		
//====================ITooltip=========================================================
		
		public override function set tip(val:Object):void
		{
			if(tooltip == val) return;
			tooltip = String(val);
			
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.wordWrap = false;
		}
		
		public override function get tip():Object
		{
			return tooltip;
		}
		
//============================END=====================================================
	}
}