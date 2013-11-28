package com.uiComponents.buttons
{
	import com.uiComponents.ComponentGlobal;
	
	import fl.controls.Button;
	import fl.core.UIComponent;
	
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * 
	 * 扩展Button功能，添加一个Over文本状态样式 
	 * @author JT
	 * 
	 */	
	public class FLButton extends Button
	{
		
		
		/**
		 * 文本是否要描边显示 
		 */		
		private var mIsDropShow:Boolean = true;
		
		//--------------------------------------
		//  静态属性
		//--------------------------------------
		
		/**
		 * 
		 * @private
		 * 
		 */
		private static var defaultStyles:Object =
		{
			overTextFormat:new TextFormat("_sans", 11, 0x000000, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0),
			pressTextFormat:new TextFormat("_sans", 11, 0x999999, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0)
		};
		
		//--------------------------------------
		//  Static Methods
		//--------------------------------------
		/**
		 * @copy fl.core.UIComponent#getStyleDefinition()
		 *
		 * @includeExample ../core/examples/UIComponent.getStyleDefinition.1.as -noswf
		 *
		 * @see fl.core.UIComponent#getStyle()
		 * @see fl.core.UIComponent#setStyle()
		 * @see fl.managers.StyleManager
		 */
		public static function getStyleDefinition():Object
		{
			return UIComponent.mergeStyles(Button.getStyleDefinition(), defaultStyles);
		}
		
		
		public function FLButton()
		{
			super();
		}
		
		protected override function configUI():void
		{
			super.configUI();
			if(mIsDropShow)
			{
				textField.filters = [ComponentGlobal.glowFilter];
			}
		}
		
		override protected function drawTextFormat():void
		{
			var textFormat:TextFormat;
			if(!this.enabled)
			{
				textFormat = getStyleValue("disabledTextFormat") as TextFormat;
			}
			
			else if(this.selected)
			{
				textFormat = getStyleValue("selectedTextFormat") as TextFormat;
			}
			
			else if(mouseState == "over")
			{
				textFormat = getStyleValue("overTextFormat") as TextFormat; 
			}
			
			else if(mouseState == "down")
			{
				textFormat = getStyleValue("pressTextFormat") as TextFormat;
			}
			
			if(!textFormat)
			{
				textFormat = this.getStyleValue("textFormat") as TextFormat;
			}
			
			this.textField.setTextFormat(textFormat);
			this.setEmbedFont();
		}
		
		[Inspectable(name="isDropShow", type="Boolean",defaultValue="true")]
		/**
		 * 文本是否描边 
		 * @param val
		 */		
		public function set isDropShow(val:Boolean):void
		{
			mIsDropShow = val;
			if(textField)
			{
				if(mIsDropShow)
				{
					textField.filters = [ComponentGlobal.glowFilter];
				}
				else
				{
					textField.filters = [];
				}
			}
		}
		
		public function get isDropShow():Boolean
		{
			return mIsDropShow;
		}
		
	}
}