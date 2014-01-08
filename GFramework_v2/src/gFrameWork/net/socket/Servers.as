package gFrameWork.net.socket
{
	public class Servers
	{
		
	
		
		private static var internalCall:Boolean = false;
		
		private static var mInstance:Servers;
		
		
		public static function get instance():Servers
		{
			if(!mInstance)
			{
				internalCall = true;
				mInstance = new Servers();
				internalCall = false;
			}
			return mInstance;
		}
		
		/**
		 * 服务端通信息Socket
		 */		
		public var cppService:NetEngine;
		
		public function Servers()
		{
			if(!internalCall)
			{
				throw new Error("please used propertie instance()");
			}
		}
	
	}
}