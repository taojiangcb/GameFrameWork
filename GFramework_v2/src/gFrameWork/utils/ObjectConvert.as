package gFrameWork.utils
{
	
	import flash.net.getClassByAlias;
	import flash.utils.describeType;
	import flash.utils.flash_proxy;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.utils.StringUtil;
	
	/**
	 * 工具类，数据转换,
	 * @author JiangTao
	 * 
	 */	
	public class ObjectConvert
	{
		public function ObjectConvert()
		{
			
		}
		/**
		 * 将对像类型转换成消息字符串
		 * @param obj
		 * @param isTelnetVO 是否是远程对像
		 * @return　例如 : {UserID:100;Message:你今天吃饭了没有;Name:斗儿;Channel:1}; 
		 * 
		 */		
		public static function ObjectConvertToString(obj:Object,isTelnetVO:Boolean = false):String
		{
			if(!obj)
			{
				throw new Error("convert obj not is null");	
			}
			var value : String = "{";
			/*对像是否是类引用?*/
			if(getQualifiedClassName(obj) != "Object")
			{
				/*如果对像是类引用的话，则执行以下操作*/
				var properties_xml : XML = XML(describeType(obj).toXMLString());
				var accessor_xml:XMLList = properties_xml.accessor;
				var key:String = "";
				for(var i : int = 0;i<accessor_xml.length();i++)
				{
					key = accessor_xml[i].@name;
					//如果此属性是数组则以下处理
					if(obj[key] is Array)
					{
						value += StringUtil.substitute("\"{0}\":{1}{2}",key ,ArrayConvertToString(obj[key] as Array),i >= accessor_xml.length() ? "" : ",");
					}
					//如果此属性是对像则以下处理
					else if(typeof(obj[key]) == "object")
					{
						value += StringUtil.substitute("\"{0}\":{1}{2}",key,ObjectConvertToString(obj[key],isTelnetVO),i >= accessor_xml.length() ? "" : ",");
					}
					else
					{
						value += StringUtil.substitute("\"{0}\":\"{1}\"{2}",key,obj[key],i >= accessor_xml.length() ? "" : ",");
					}
				}
			}
			else
			{
				/*如果对像不是类引用的话，则执行以下操作*/
				var len : int = obj.length;
				var n : int = 0;
				for(var k:String in obj)
				{
					value +=  ("\"{0}\":\"{1}\"{2}",k,obj[k],n >= len ? "" : ",");
				}
			}
			
			/*如果是远程对像的话，则获取对像名再得新组织*/			
			if(isTelnetVO)
			{
				var className : String = getQualifiedClassName(obj).toString();
				if(className.length > 0 && className != "ull")
				{
					value += "\"className\":" + "\"" + className + "\"";
				}
			}
			value +="}";
			return value;
		}
		
		
		/**
		 * 将数据转换成字符 
		 * @param ary
		 * @return 
		 * 
		 */		
		public static function ArrayConvertToString(ary:Array):String
		{
			return JSON.stringify(ary);
		}
		
		/**
		 * 将数据结构转换成Object 
		 * @param obj
		 * @return 
		 * 
		 */		
		public static function classTargetToObject(obj:*):Object
		{
			if(getQualifiedClassName(obj) != "Object")
			{
				var properties_xml:XML = XML(describeType(obj).toXMLString())
				var accessor_xml:XMLList  = properties_xml.accessor;
				var key:String;
				
				var data:Object = new Object();
				for (var i:int = 0;i < accessor_xml.length();i++)
				{
					if(accessor_xml[i].@access == "readonly") continue;
					key = accessor_xml[i].@name;
					data[key] = obj[key];
				}
				properties_xml = null;
				accessor_xml = null;
				return data;
			}
			else
			{
				if(obj.hasOwnProperty("_explicitType"))
				delete obj["_explicitType"];
				return obj;
			}
		}
		
		/**
		 * 将字符转换成对像 
		 * @param str
		 * @return 
		 * 
		 */		
		public static function stringConvertToObject(str:String):Object
		{
			var value : Object;
			value = JSON.parse(str);
			if(value is Array)
			{
				for(var i:int = 0;i < value.length;i++)
				{
					value[i] = objectToStruct(value[i]);
				}
			}
			else if(value.hasOwnProperty("_explicitType"))
			{
				return objectToStruct(value);
			}
			return value;
		}
		
		/**
		 * 将数据对像转换为数据结构 
		 * @param value
		 * 
		 */		
		public static function objectToStruct(value:*):Object
		{
			var refCls : Object;
			var result:Object;
			if(value.hasOwnProperty("_explicitType"))
			{
				refCls = getClassByAlias(value["_explicitType"]) as Class;
				result = new refCls();
				delete value["_explicitType"];
				for(var k : String in value)
				{
					if(value[k] == null) continue;
					if(value[k].hasOwnProperty("_explicitType"))
					{
						result[k] = objectToStruct(value[k]);
					}
					else if(value[k] is Array)
					{
						result[k] = value[k]
						for(var i:int = 0;i < value[k].length;i++)
						{
							result[k][i] = objectToStruct(value[k][i]);
						}
					}
					else
					{
						//过滤服务端多余属性(例子：LegionStruct->chief->legionRank->RankAppointStruct->GrantValue )
						if(result.hasOwnProperty(k))
							result[k] = value[k];						
					}
				}
			}
			else
			{
				result = value;
			}
			return result;	
		}
		
		public static function stringConvertToObjectV2(str:String,splitFlag:String = "/"):Array
		{
			return str.split(splitFlag);
		}
		
		public static function arraytoJSONString(arr:Array):String
		{
			var len : int = arr.length;
			var n : int = 0;
			var value:String = "{";
			for(var k:String in arr)
			{
				n++;
				value +=  StringUtil.substitute("\"{0}\":\"{1}\"{2}",k,arr[k],n >= len ? "" : ",");
			}
			value += "}";
			return value;
		}
		
		/**
		 * 
		 * 将数据文件拆成数据列表 
		 * @param strProfile
		 * @return 
		 * 
		 */		
		public static function profileToArray(strProfile:String):Vector.<String>
		{
			var strLine:Vector.<String> = new Vector.<String>();
			
			var profile:String = StringUtil.trim(strProfile);
			
			var tempList:Array = [];
			
			if(profile && profile.length > 0)
			{
				tempList = profile.split("\n");
			}
			
			while(tempList.length > 0)
			{
				var line:String = StringUtil.trim(tempList.shift());
				if(line.length == 0) continue;
				if(line.indexOf("#") == 0) continue;
				strLine.push(line);
			}
			
			return strLine;
		}
		
	}
}