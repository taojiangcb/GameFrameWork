package gFrameWork.net.amf
{
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;

	public class AMF
	{
		/**
		 * 服务器连接 
		 */		
		private var conn:NetConnection;
		
		/**
		 * 连接的服务端地址 
		 */		
		private var serverAddress:String = "";
		
		/**
		 * @param serverAdd 
		 * 
		 */		
		public function AMF()
		{
			conn = new NetConnection();
			conn.objectEncoding = ObjectEncoding.AMF3;
			conn.addEventListener(NetStatusEvent.NET_STATUS,onNetStatusHandler);
		}
		
		/**
		 * 连接Amf地址 
		 * @param address
		 * 
		 */		
		public function connection(address:String):void
		{
			serverAddress = address;
			conn.connect(address);
		}
		
		/**
		 * 调用服务端方法 
		 * @param serverName	服务名
		 * @param funcName		方法名
		 * @param param			参数
		 * @param onResult		调用成功处理
		 * @param onFault		调用失败处理
		 * 
		 */		
		public function call(serverName:String,funcName:String,param:Array,onResult:Function = null,onFault:Function = null):void
		{
			var responder:Responder = new Responder(onResult,onFault);
			var remoteFunc:String = [serverName,funcName].join(".");
			var parameters:Array = [remoteFunc,responder];
			while(param.length > 0)
			{
				parameters.push(param.shift());
			}
			conn.call.apply(null,parameters);
		}
		
		private function onNetStatusHandler(event:NetStatusEvent):void
		{
			throw new Error(event.toString());
		}
	}
}