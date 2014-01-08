package flide.controller
{
	import flash.display.Sprite;
	
	import org.puremvc.as3.patterns.facade.Facade;
	
	/**
	 * FLIDE的模块内容,其中包括一些主程序传进的基本数据
	 * @author JT
	 * 
	 */	
	public class FLIDEContent extends Sprite
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
	}
}