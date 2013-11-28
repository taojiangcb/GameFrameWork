/**
 * 本地静态数据库 
 */
package gFrameWork.db
{
	public class DataBase
	{
		private static var mInstance:dataBase;
		
		/**
		 * 装载一个数据表， 
		 * @param tbName			数据表名称
		 * @param tbFormat			表数据类
		 * @param profileDB			数据文件
		 * @param primarykey		主键
		 * 
		 */		
		public static function installTable(tbName:String,tbFormat:Class,profileDB:XML,primarykey:String):void
		{
			instance.installTable(tbName,tbFormat,profileDB,primarykey);	
		}
		
		/**
		 * 按照装载的数据表名称卸载一个数表 
		 * @param tbName
		 * 
		 */		
		public static function uninstallTable(tbName:String):void
		{
			instance.uninstallTable(tbName);
		}
		
		/**
		 * 按照装载的数据表名称，获取一个数据表 
		 * @param tbName
		 * @return 
		 * 
		 */		
		public static function retrieve(tbName:String):DataBaseTable
		{
			return instance.retrieve(tbName);	
		}
		
		private static function get instance():dataBase
		{
			if(!mInstance)
			{
				mInstance = new dataBase();
			}
			return mInstance;
		}
	}
}

import flash.utils.Dictionary;

import gFrameWork.db.DataBaseTable;

class dataBase
{
	private var mDB:Dictionary;
	
	public function dataBase():void
	{
		mDB = new Dictionary();
	}
	
	/**
	 * 添加一张数据表到本地
	 * @param tbName							表名
	 * @param tb								表类
	 * @param tbFormat							表的数据格式类
	 * @param profileDB							表中需要填充的数据
	 * 
	 */
	public function installTable(tbName:String,tbFormat:Class,profileDB:XML,primarykey:String):void
	{
		if(!mDB[tbName])
		{
			//获取一级目录下的所有数据项的子级
			var xmlList:XMLList = profileDB.children();
			var xmlItem:XML;
			
			//定义数据表
			var table:DataBaseTable = null;
			
			//遍历所有的数据项
			for each(xmlItem in xmlList)
			{
				//获取当前数据项的所有数据节点
				var properties:XMLList = xmlItem.children();
				//表的主键
				var primaryKey:String = primarykey;
				//当前的数据节点
				var propertXML:XML;
				//定义当前的数据结构
				var valueStruct:Object = new tbFormat();
				if(!table)
				{
					table = new DataBaseTable(primaryKey)
				}
				
				//遍历当前所有的数据节点
				for each(propertXML in properties)
				{
					var propertie:String = propertXML.localName();
					if(valueStruct.hasOwnProperty(propertie))
					{
						//填充当前的数据节点到结构中
						valueStruct[propertie] = xmlItem[propertie];
					}
				}
				
				//将当前数据结构插入到表中
				table.install(valueStruct);
			}
			mDB[tbName] = table;
		}
	}
	
	/**
	 * 按表的名称注销一张数据表 
	 * @param tbName
	 * 
	 */	
	public function uninstallTable(tbName:String):void
	{
		if(mDB[tbName])
		{
			delete mDB[tbName];
		}
	}
	
	/**
	 * 
	 * 按名称返回一张数据表 
	 * @param tbName
	 * @return
	 *  
	 */	
	public function retrieve(tbName:String):DataBaseTable
	{
		return mDB[tbName];
	}
}