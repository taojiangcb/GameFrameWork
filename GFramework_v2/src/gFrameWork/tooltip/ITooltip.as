package gFrameWork.tooltip
{
	import gFrameWork.IDisabled;

	/**
	 * Tooltip显示对像的接口 
	 * @author JT
	 * 
	 */	
	public interface ITooltip extends IDisabled
	{
		/*设置Tip的显容*/
		function set tip(val:Object):void;
		function get tip():Object;
		
		/*显示Tip*/
		function showTip():void;
		function hideTip():void;
			
			
	}
}