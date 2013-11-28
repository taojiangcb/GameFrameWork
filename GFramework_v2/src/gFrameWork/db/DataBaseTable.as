/**
 *
 * 
 * 本地静态数据表，用于快速查讯客户端的本地静态数据对像。
 *
 *  mDataMap:HashTable 			数据集
 *
 * mDataFormationVO	:Class			数据结构格式
 * mPrimaryKey:String				表的主键
 * install(data:ValueObject):void			插入一条数据
 * select(comns:Array,values:Array,operation:uint)		检索出等以上条件的数据
 * getValues():				返回所有的数据
 * getValueByPrimaryKey(value:*)		获取主键值所引的数据
 * getFormatVO():Class			返回数据格式
 * 
 *  
 */

/**
 * 静态数据表 
 */
package gFrameWork.db
{
	//数据集
	import gFrameWork.collection.HashTable;
	
	import mx.utils.StringUtil;

	public class DataBaseTable
	{
		
		/**
		 * 数据表 
		 */		
		private var mDataMap:HashTable;
		
		/**
		 * 主键 
		 */		
		private var mPrimaryKey:String = "";
		
		public function DataBaseTable(primaryKey:String)
		{
			super();
			
			mDataMap = new HashTable();
			mPrimaryKey = primaryKey;
			
			if(primaryKey == null || StringUtil.trim(primaryKey).length == 0)
			{
				throw new ArgumentError("PrimaryKey can't is null or length can't for 0");
			}
		}
		
		/**
		 * 插出一到数据到表中 
		 * @param arg
		 * 
		 */		
		public function install(arg:Object):void
		{
			//主键
			var pk:Object = arg[mPrimaryKey];
			mDataMap[pk] = arg;
		}
		
		/**
		 * 
		 * 筛选出符合条件的数据项 
		 * @param columns						列
		 * @param values						条件值
		 * @param operations					条件操作 0等级,1大于,2小于,混合模式[0|1,0|2,1|2];
		 * @return 
		 * 
		 */		
		public function select(columns:Array,values:Array,operations:Array):Vector.<Object>
		{
			
			if(columns == null || values == null || operations == null || columns.length == 0 || values.length == 0 || operations.length == 0)
			{
				throw new ArgumentError("Parameters can't to null or length can't for 0");
			}
			
			var list:Vector.<Object> = new Vector.<Object>();
			
			var tempList:Vector.<Object> = getValues();
			
			var i:int = 0;
			var n:int = 0;
			
			for(i = 0; i < tempList.length;i++)
			{
				//当前的某条数据
				var itemValue:Object = tempList[i];
				var validate:Boolean = false;
				
				var left:Array = [];
				
				//左边表太式中的值
				for each(var c:String in columns)
				{
					left.push(itemValue[c]);
				}
				
				//比对右边表太式的中值
				for(n = 0; n < values.length; n++)
				{
					
					//条件运算符
					var op:uint = operations.length >= n ? operations[n] : operations[operations.length - 1];
					
					if(Boolean((op & DB_Operation.EQUAL) == DB_Operation.EQUAL))
					{
						if(left[n] == values[n])
						{
							validate = true;
							continue;
						}
					}
					
					if(Boolean((op & DB_Operation.GREATER) == DB_Operation.GREATER))
					{
						if(left[n] > values[n])
						{
							validate = true;
							continue;
						}
					}
					
					if(Boolean((op & DB_Operation.LESS) == DB_Operation.LESS))
					{
						if(left[n] < values[n])
						{
							validate = true;
							continue;
						}
					}
				}
				
				if(validate)
				{
					list.push(tempList[i]);
				}
				
			}
			return list;
		}
		
		/**
		 * 获取表中所有的数据 
		 * @return 
		 * 
		 */		
		public function getValues():Vector.<Object>
		{
			return mDataMap.getValues();
		}
		
		/**
		 * 按主键的索引获取表中的值 
		 * @param arg
		 * @return 
		 * 
		 */		
		public function getValueByPrimaryKey(arg:*):Object
		{
			return mDataMap[arg];
		}
		
	}
}