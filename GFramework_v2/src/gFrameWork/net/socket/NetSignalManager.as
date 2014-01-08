package gFrameWork.net.socket
{
	import flash.utils.ByteArray;

	public class NetSignalManager
	{
		
		private static var __mgr:SignalMgr;
		
		public function NetSignalManager()
		{
			
		}
		
		public static function registerRespond(packetID:int,msgCls:Class,responCls:Class):void
		{
			mgr.registerRespond(packetID,msgCls,responCls);
		}
		
		public static function recreiveMsg(packetID:int,data:ByteArray):void
		{
			mgr.reciverMsg(packetID,data);
		}
		
		private static function get mgr():SignalMgr
		{
			if(!__mgr)
			{
				__mgr = new SignalMgr();
			}
			return __mgr;
		}
		
		
	}
}

import com.netease.protobuf.Message;

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import gFrameWork.net.socket.NetResponseBase;

class SignalMgr
{
	
	private var mMsgMap:Dictionary;
	
	public function SignalMgr():void
	{
		mMsgMap = new Dictionary(false);
	}
	
	/**
	 * 接收到信息并回调处理 
	 * @param packetID
	 * @param data
	 * 
	 */	
	public function reciverMsg(packetID:int,data:ByteArray):void
	{
		var netPacket:NetPackage = retrieveRespond(packetID);
		if(netPacket)
		{
			var msg:Message = new netPacket.messageCls();
			msg.mergeFrom(data);
			
			var respond:NetResponseBase = new netPacket.response();
			respond.onResult(msg);
		}
	}
	
	/**
	 * 注册数据传输答应器 
	 * @param packetID				包ID
	 * @param msgCls				数据信息
	 * @param responCls				答应器
	 * 
	 */	
	public function registerRespond(packetID:int,msgCls:Class,responCls:Class):void
	{
		if(packetID > 0 && msgCls != null && responCls != null)
		{
			var netpb:NetPackage = new NetPackage();
			netpb.packetID = packetID;
			netpb.messageCls = msgCls;
			netpb.response = responCls;
			mMsgMap[packetID] = netpb;
		}
	}
	
	public function retrieveRespond(packetID:int):NetPackage
	{
		return mMsgMap[packetID];
	}
}

class NetPackage
{
	public var packetID:int = 0;
	public var response:Class;
	public var messageCls:Class;
	
	public function NetPacket():void{}
	
}