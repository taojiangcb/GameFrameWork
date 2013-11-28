package gFrameWork.appDrag
{
	import flash.display.DisplayObject;

	/**
	 * 是否可以接爱拖拽或者鼠标粘贴对像  
	 * @author JT
	 * 
	 */	
	public interface IDragClient
	{
		/**
		 * 
		 * 接受鼠标放入的目标对像方法 
		 * @param displayObj
		 * @param itemData
		 * @return 
		 * 
		 */		
		function acceptClingy(event:AppDragEvent):void;
	}
}