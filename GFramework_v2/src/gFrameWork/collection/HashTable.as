package gFrameWork.collection
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	/**
	 * HashTable 数据列表 
	 * @author JT
	 * 
	 */	
	public class HashTable extends Proxy
	{
		private var keys:Vector.<Object>;
		private var values:Vector.<Object>;
		private var dict:Dictionary;
		
		public function HashTable()
		{
			init();
		}
		
		private function init():void
		{
			keys = new Vector.<Object>();
			values = new Vector.<Object>();
			dict = new Dictionary(true);
		}
		
		/**
		 * 添加新项 
		 * @param name 键名
		 * @param value 数据
		 * 
		 */		
		public function add(name:*,value:Object):void
		{
			/*是否已经存在数据*/
			var key:Object;
			if(name is QName)
			{
				key = QName(name).localName;
			}
			else
			{
				key = typeof(name) == "number" ? String(name) : name;
			}
			if(!isHas(key))
			{
				/*如果此数据没有，则添加*/
				keys.push(key);
				values.push(value);
			}
			else
			{
				/*如果此数据已经存在，则刷新*/
				var index : int = keys.indexOf(key);
				if(index == -1) return;
				values[index] = value;
			}
			dict[key]=value;
		}
		
		/**
		 * 按key移除数据 
		 * @param name
		 * @return 
		 * 
		 */		
		public function remove(name:*):void
		{
			var index:int = -1;
			index = typeof(name) == "number" ? keys.indexOf(name.toString()) :keys.indexOf(name);
			if(isHas(name))
			{
				keys.splice(index,1);
				values.splice(index,1);
				delete dict[name];
			}
		}
		
		private var _removeValue:Object = null;
		/**
		 *　按 value　删除数据 
		 * @param value
		 * @return 
		 * 
		 */		
		public function remove_value(value:*):Boolean
		{
			_removeValue = value;
			values.forEach(removeByValue);
			return true;
		}
		
		private function removeByValue(element:*,index:int,arr:Vector.<Object>):Boolean
		{
			if(element == _removeValue)
			{
				if(isHas(keys[index]))
				{
					remove(keys[index]);
					return true;
				}
			}
			return false;
		}
		
		public function clone():HashTable
		{
			var list:HashTable = new HashTable();
			for each(var key:* in keys)
			{
				list[key] = dict[key];
			}
			return list;
		}
		
		/**
		 * 按值获取key 
		 * @param value
		 * @return 
		 * 
		 */		
		public function keyOf(value:Object):*
		{
			var index : int = values.indexOf(value);
			return index > -1 ? keys[index] : null;
		}
		
		/**
		 * 清空数据 
		 */		
		public function clear():void
		{
			while(keys.length > 0)
				keys.pop();
			keys = null;
			
			while(values.length > 0)
				values.pop();
			values = null;
			dict = null;
			
			init();
		}
		
		public function getValues():Vector.<Object>
		{
			return values;
		}
		
		/**
		 * 按key验证数据是否存在 
		 * @param name
		 */		
		public function isHas(name:*):Boolean
		{
			return flash_proxy::hasProperty(name);
		}
		
		/**
		 * 反回第一条数据 
		 * @return 
		 * 
		 */		
		public function getFirst():Object
		{
			return values[0];
		}
		
		public function get count():Number
		{
			return values.length;
		}
		
		
		flash_proxy override function callProperty(name:*, ...parameters):*
		{
			return null;		
		}
		
		flash_proxy override function getProperty(name:*):*
		{
			var obj:Object = dict[name];
			if(obj)
			{
				var index:int = values.indexOf(obj);
				if(index > -1)
					return values[index];
			}
			return null;
		}
		
		flash_proxy override function hasProperty(name:*):Boolean
		{
			return dict[name] != null;
		}
		
		flash_proxy override function nextName(index:int):String
		{
			return keys[index-1].toString();
		}
		// 在 for each 或 for in 中取得下一个索引值
		// 如果超过界限则返回零
		// index 会从零开始,但零表示结束,所以这里返回index+1
		// 而在 nextName 与 nextValue 方法中,使用index-1
		flash_proxy override function nextNameIndex(index:int):int
		{
			return index < keys.length? index + 1 : 0;
		}
		
		flash_proxy override function nextValue(index:int):*
		{
			return dict[keys[index - 1]];
		}
		
		flash_proxy override function setProperty(name:*, value:*):void
		{
			add(name,value);
		}
	}
}