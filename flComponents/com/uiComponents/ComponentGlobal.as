package com.uiComponents
{
	import flash.filters.DropShadowFilter;

	public class ComponentGlobal
	{
		
		/*文字描边*/
		private static var _dropShadowFilter:DropShadowFilter;
		public static function get glowFilter():DropShadowFilter
		{
			if(!_dropShadowFilter)
			{
				_dropShadowFilter = new DropShadowFilter(0,0,0x000000,0.8,2,2,100,1);
			}
			return _dropShadowFilter;
		}
	}
}