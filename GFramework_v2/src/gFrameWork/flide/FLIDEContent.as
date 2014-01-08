package gFrameWork.flide
{
	import flash.display.Sprite;
	
	import gFrameWork.IDisabled;

	/**
	 * swf的应用模块基类
	 * @author JT
	 * 
	 */	
	public class FLIDEContent extends Sprite implements IDisabled
	{
		
		public static const FACADE:String = "facade";
		
		
		public static const LANGUAGE:String = "language";
		
		
		public static const FILE_ADDRESS:String = "fileAddress";
		
		
		public static const SERVER_CONFIG:String = "serverConfig";
		
		
		public function FLIDEContent()
		{
			super();
		}
		
		/**
		 * 当UI界面加载完成后由主程序主动调用
		 */		
		public function loaderCompleteInit(...args):void
		{
			
		}
		
		/**
		 * 根据主端定义的名称来获取主端的对像 
		 * @param defName
		 * @return 
		 * 
		 */		
		public function getMainDomainDefine(defName:String):Object
		{
			return loaderInfo.applicationDomain.getDefinition(defName);
		}
		
		public function dispose():void
		{
			
		}
		
	}
}