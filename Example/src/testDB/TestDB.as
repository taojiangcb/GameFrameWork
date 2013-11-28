package testDB
{
	import flash.display.Sprite;
	
	import gFrameWork.db.DataBase;
	import gFrameWork.db.DataBaseTable;
	import gFrameWork.utils.StringUtils;

	public class TestDB extends Sprite
	{
		
		[Embed(source="c_city_scene_reg.xml",mimeType="application/octet-stream")]
		private var DB_FILE:Class;
		
		public function TestDB()
		{
			installDB();
			readerDB();
		}
		
		private function installDB():void
		{
			var dbXML:XML = new XML(new DB_FILE());
			DataBase.installTable("cityScene",DataBaseTable,C_City_Scene_Reg,dbXML);
		}
		
		private function readerDB():void
		{
			var dbTable:DataBaseTable = DataBase.retrieve("cityScene");
			var regs:Vector.<Object> = dbTable.getValues();
			var cityScene:C_City_Scene_Reg;
			for each(cityScene in regs)
			{
				trace(StringUtils.Format("cityID:{0},cityName:{1}",cityScene.CityID,cityScene.Battle));
			}
			
			trace("quickFind:",dbTable.getValueByPrimaryKey(6)["Battle"]);
		}
	}
}