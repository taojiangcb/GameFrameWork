/**
 *
 * 填充动态数据对像
 *  
 */

package gFrameWork.utils
{
	import mx.utils.StringUtil;

	public class DynamicProperties
	{
		
		public function DynamicProperties():void
		{
			
		}
		
		/**
		 * 
		 * 序列动态对像的属性信息
		 * 
		 */		
		public static function serialize(source:String,obj:*):void
		{
			var str_list:Array = source.split("\n");
			while(str_list.length > 0)
			{
				var str_line:String = StringUtil.substitute(str_list.shift()).replace(/[\n\r]/gi,"");
				if(StringUtil.trim(str_line).length == 0) continue;
				if(str_line.indexOf("#") == 0) continue;
				var find_char_index:int = str_line.indexOf("=");
				if(find_char_index == -1) continue;
				var key:String = StringUtil.trim(str_line.substring(0,find_char_index));
				var value:String = StringUtil.trim(str_line.substring(find_char_index + 1));
				obj[key] = value;
			}
		}
	}
}