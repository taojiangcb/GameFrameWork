package application.TLFCustom 
{
	import flash.events.ErrorEvent;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.elements.TextFlow;
	import flash.utils.getDefinitionByName;
	import flashx.textLayout.events.StatusChangeEvent;
	/**
	 * ...
	 * @author Tao
	 */
	public class InlineGraphicElementV2 extends InlineGraphicElement
	{
		
		private var _graphicStatus:String = "";
		
		public function InlineGraphicElementV2() 
		{
			super();
			_graphicStatus = status;
		}
		
		override public function applyDelayedElementUpdate(textFlow:TextFlow, okToUnloadGraphics:Boolean, hasController:Boolean):void 
		{
			if (textFlow != this.getTextFlow())
			{
				hasController = false;
			}
			
			if (source is String)
			{
				var findCls:Class = getDefinitionByName(source) as Class;
				if (findCls)
				{
					elem = DisplayObject(new cls());
					changeGraphicStatus(EMBED_LOADED);
					return;
				}
			}
			super.applyDelayedElementUpdate(textFlow, okToUnloadGraphics, hasController);	
		}
		
		private function changeGraphicStatus(stat:Object):void
		{
			var oldStatus:String = status;
			_graphicStatus = stat;
			var newStatus:String = status;
			if (oldStatus != newStatus || stat is ErrorEvent)
			{
				var tf:TextFlow = getTextFlow();
				if (tf)
				{
					if (newStatus == InlineGraphicElementStatus.SIZE_PENDING)
						tf.processAutoSizeImageLoaded(this);
					tf.dispatchEvent(new StatusChangeEvent(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, false, false, this, newStatus, stat as ErrorEvent));
				}
			}
		}
		
		override public function get status():String 
		{
			return _graphicStatus;
		}
	}

}