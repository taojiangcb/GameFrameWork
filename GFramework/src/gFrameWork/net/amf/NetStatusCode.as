package gFrameWork.net.amf
{
	public class NetStatusCode
	{
		
		/**
		 * 以不能识别的格式编码的数据包。 
		 */		
		public static const CALL_BAD_VERSION:String = "NetConnection.Call.BadVersion";

		/**
		 * NetConnection.call() 方法无法调用服务器端的方法或命令。 
		 */		
		public static const CALL_FALIED:String = "NetConnection.Call.Failed";
		
		/**
		 *Action Message Format (AMF) 操作因安全原因而被阻止。AMF URL 与文件（其中包含调用 NetConnection.call() 方法的代码）不在同一个域中，或者 AMF 服务器没有信任文件（其中包含调用 NetConnection.call() 方法的代码）所在域的策略文件。 
		 */		
		public static const CALL_PROHIBITED:String = "NetConnection.Call.Prohibited";
		
		/**
		 * 正在关闭服务器端应用程序。 
		 */		
		public static const CONN_APP_SHUTDOWN:String = "NetConnection.Connect.AppShutdown";
		
		/**
		 * 连接尝试失败。 
		 */		
		public static const CONN_FAILED:String = "NetConnection.Connect.Failed";
		
		/**
		 * Flash Media Server 断开了与客户端的连接，因为客户端的闲置时间已超过了 <MaxIdleTime> 的配置值。 在 Flash Media Server 上，<AutoCloseIdleClients> 默认情况下处于禁用状态。 启用时，默认超时值为 3600 秒（1 小时）。有关详细信息，请参阅 关闭闲置连接。 
		 */		
		public static const CONN_IDLE_TIMEOUT:String = "NetConnection.Connect.IdleTimeout";
		
		/**
		 * 	对 NetConnection.connect() 的调用中指定的应用程序名称无效。 
		 */		
		public static const CONN_INVALID_APP:String = "NetConnection.Connect.InvalidApp";
		
		/**
		 * Flash Player 检测到网络更改，例如，断开的无线连接、成功的无线连接或者网络电缆缺失。
		 * 使用此事件检查网络接口更改。不要使用此事件实现 NetConnection 重新连接逻辑。使用 "NetConnection.Connect.Closed" 来实现 NetConnection 重新连接逻辑。 
		 */		
		public static const CONN_NET_WORK_CHANGE:String = "NetConnection.Connect.NetworkChange";
		
		/**
		 * 连接尝试没有访问应用程序的权限。 
		 */		
		public static const CONN_REJECTED:String = "NetConnection.Connect.Rejected";
		
		/**
		 * 连接尝试成功。 
		 */		
		public static const CONN_SUCCESS:String = "NetConnection.Connect.Success";

		public function NetStatusCode()
		{
		}
	}
}