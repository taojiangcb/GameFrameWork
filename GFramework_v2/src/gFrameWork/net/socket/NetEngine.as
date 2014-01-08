package gFrameWork.net.socket
{
	import com.netease.protobuf.Message;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	[Event(name="close",type="flash.events.Event")]
	[Event(name="connect",type="flash.events.Event")]
	[Event(name="ioError",type="flash.events.IOErrorEvent")]
	
	public class NetEngine extends EventDispatcher
	{
		private var _socket:Socket = null;
		private var _needLen:uint;
		private var _recvLen:uint;
		private var _cmd:uint;
		private const HEAD_LENGTH:uint = 6;
		private var _recvData:ByteArray;		
		private var _sendData:ByteArray;
		private var _recvHead:Boolean;
		
		private const OFF_SET:uint = 2;
		
		/**
		 * 重试的次数 
		 */		
		private var tryAgin:int = 5;
		/**
		 * 当前重试的次数 
		 */		
		private var time:int = 0;
		
		
		public function NetEngine() : void
		{
			_recvData = new ByteArray();
			_recvData.endian = Endian.LITTLE_ENDIAN;
			
			_sendData = new ByteArray();
			_sendData.endian = Endian.LITTLE_ENDIAN;
			
			_needLen = HEAD_LENGTH;
			_recvHead = true;
			
		}
		
		private function callBack(cmd:uint, data:ByteArray):void
		{
			NetSignalManager.recreiveMsg(cmd,data);
		}
		
		public function connect(server:String, port:int) : void
		{
			_socket = new Socket();
			_socket.endian = Endian.LITTLE_ENDIAN;
			_socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_socket.addEventListener(Event.CLOSE, closeHandler);
			_socket.addEventListener(Event.CONNECT,connectHandler);
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrorHandler);
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, receiveHandler);
			// 连接
			_socket.connect(server,port);
			return;
		}
		
		private function ioErrorHandler(evt:IOErrorEvent):void
		{
			trace("Connection-ioErrorHandler");
			dispatchEvent(evt.clone());
		}		
		
		private function securityErrorHandler(evt:SecurityErrorEvent):void
		{
			trace("Connection-securityErrorHandler");
			dispatchEvent(evt.clone());
		}
		
		private function closeHandler(evt:Event):void
		{
			trace("Connection-closeHandler");
			dispatchEvent(evt.clone());
		}
		
		private function connectHandler(evt:Event):void
		{
			trace("Connection-connectHandler");
			dispatchEvent(evt.clone());
		}
		
		//接收数据处理
		private function receiveHandler(evt:ProgressEvent):void
		{
			var slice_len:uint = _socket.bytesAvailable;
			while(true)
			{
				if(slice_len < 1)
				{
					break;
				}
				var read_len:uint = 0;
				// 还不够
				if (_recvLen + slice_len < _needLen)
				{
					read_len = slice_len;
				}
					// 已搞完
				else
				{
					read_len = _needLen - _recvLen;
				}
				_socket.readBytes(_recvData, _recvLen, read_len);
				_recvLen += read_len;
				slice_len -= read_len;
				
				if (_recvLen == _needLen)
				{
					// 包头读取完毕
					if (_recvHead)
					{
						// magic
						_recvData.readUnsignedShort();
						_needLen = _recvData.readUnsignedShort() - OFF_SET;
						_cmd = _recvData.readUnsignedShort();
						//trace(_cmd);
						// 准备下一次读取
						_recvData.clear();
						_recvLen = 0;
						_recvHead = false;
						// 空消息体
						if (_needLen == 0)
						{
							callBack(_cmd, null);
							_needLen = HEAD_LENGTH;
							_recvHead = true;
						}
					}
						// 消息主体读取完毕
					else
					{
						_needLen = HEAD_LENGTH;
						_recvLen = 0;
						_recvHead = true;
						_recvData.position = 0;
						callBack(_cmd, _recvData);
						// 准备下一次读取
						_recvData.clear();
					}
				}
			}
		}
		
		//发送数据
		public function sendMessage(msg:Message):void
		{	
			if(msg == null)
			{
				return;
			}
			
			if(_socket && _socket.connected)
			{
				_socket.writeShort(998);
				_sendData.clear();
				msg.writeTo(_sendData);
				_socket.writeShort(_sendData.length + OFF_SET);
				
				// cmd
				_socket.writeShort(msg['xYID']);
				_socket.writeBytes(_sendData);
				_socket.flush();
			}
		}
		
		public function close() : void
		{
			if (_socket && _socket.connected)
			{
				_socket.close();
			}
		}
	}
}
