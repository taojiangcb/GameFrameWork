package
{
	import fl.controls.Button;
	import fl.controls.ButtonLabelPlacement;
	import fl.controls.Label;
	import fl.managers.StyleManager;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.net.Responder;
	import flash.text.TextFormat;
	
	import flashUI.controls.FLButton;
	
	import gFrameWork.GFrameWork;
	import gFrameWork.net.amf.AMF;
	import gFrameWork.tooltip.DefaultTooltip;
	import gFrameWork.tooltip.TooltipManager;

	[SWF(frameRate="60",width="600",height="800")]
	public class FUITest extends Sprite
	{
		private var label:Label;
		private var btn:Button;
		private var clearBtn:Button;
		
		private var amfphp:AMF;
		
		public function FUITest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var gf:GFrameWork = GFrameWork.getInstance();
			gf.internalInit(this,null);
			
			label = new Label();
			label.text = "test";
			label.move(100,333);
			addChild(label);
			
			btn = new Button();
			btn.labelPlacement = "left";
			btn.label = "testBt";
			btn.move(200,400);
			addChild(btn);
			
			clearBtn = new Button();
			clearBtn.label = "清理Tooltip";
			clearBtn.addEventListener(MouseEvent.CLICK,clickHandler,false,0,true);
			addChild(clearBtn);
			clearBtn.move(400,500);
			TooltipManager.registerTip(clearBtn,"清理所有的Tooltip信息");
			
			TooltipManager.registerTip(label,"这个是测试");
			TooltipManager.registerTip(btn,"这个更加是测试");
			
			amfphp = new AMF();
			amfphp.connection("http://s0.tzl.wan777.com/amfphp/gateway.php");
			
			amfphp.call("LoginService","getServerInfo",[],onResultHandler,onFaultHandler);
			
			amfphp.call("CityService","getCityInfo",[42],onResultHandler,onFaultHandler);
			
			var fb:FLButton = new FLButton();
			fb.setStyle("overTextFormat",new TextFormat("宋体",16,0xFF0000));
			fb.labelPlacement = ButtonLabelPlacement.LEFT;
			addChild(fb);
			
		}
		
		private function onResultHandler(rsp:Object):void
		{
			trace(rsp);
		}
		
		private function onFaultHandler(rsp:Object):void
		{
			trace(rsp.toString());
		}
		
		private function clickHandler(event:MouseEvent):void
		{
			TooltipManager.unregisterTip(clearBtn);
			TooltipManager.unregisterTip(btn);
			TooltipManager.unregisterTip(label);
		}
		
	}
}