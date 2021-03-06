package ppppu 
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import io.FileReferenceHelper;
	import io.ByteArrayLoadedEvent;
	import Menu.ExpressionAnimationPanel;
	import Menu.ExpressionSelectPanel;
	//import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import ui.HSVCMenu;
	import ui.PopupButton;
	import ui.RGBAMenu;
	import ui.SlidingPanel;
	import flash.display.IGraphicsData;
	import flash.display.GraphicsGradientFill;
	public class ppppuMenu extends Sprite
	{
		//private var irisWorkColorTransform:ColorTransform = new ColorTransform(0,0,0,0,54,113,193,255);
		//private var scleraWorkColorTransform:ColorTransform = new ColorTransform(0,0,0,0,255,255,255,255);
		//private var lipsWorkColorTransform:ColorTransform = new ColorTransform(0, 0, 0, 0, 255, 153, 204, 255);
		
		//For panels/windows that need to be accessed by functions
		
		private var sp_Menu:SlidingPanel;
		private var p_ExpressionSelectMenu:ExpressionSelectPanel;
		//color values for elements with gradient colors
		private var faceGradientValues:Array = new Array(0,0);
		private var breastGradientValues:Array = new Array(0,0,0);
		private var vulvaGradientValues:Array = new Array(0,0);
		private var anusGradientValues:Array = new Array(0,0);
		private var areolaGradientValues:Array = new Array(0,0); //Areola gradients have the same color at both points, just use different alpha values. Currently, users have no way of actually adjusting the end value.
		
		//Element "types" for gradient editing
		public const FACEGRADIENT:int = 0;
		public const BREASTGRADIENT:int = 1;
		public const VULVAGRADIENT:int = 2;
		public const ANUSGRADIENT:int = 3;
		public const AREOLAGRADIENT:int = 4;
		
		private var faceGradientChangingElements:Array;
		private var breastGradientChangingElements:Array;
		private var vulvaGradientChangingElements:Array;
		private var anusGradientChangingElements:Array;
		private var areolaGradientChangingElements:Array;
		
		private var hairColorMenu:ui.HSVCMenu = new ui.HSVCMenu("Hair");
		private var skinColorMenu:ui.RGBAMenu = new ui.RGBAMenu("Skin");
		private var scleraColorMenu:ui.RGBAMenu = new ui.RGBAMenu("Sclera");
		private var irisLColorMenu:ui.RGBAMenu = new ui.RGBAMenu("IrisL");
		private var irisRColorMenu:ui.RGBAMenu = new ui.RGBAMenu("IrisR");
		private var lipsColorMenu:ui.RGBAMenu = new ui.RGBAMenu("Lips");
		private var nippleColorMenu:ui.RGBAMenu = new ui.RGBAMenu("Nipples");
		private var facePoint1ColorMenu:ui.RGBAMenu = new ui.RGBAMenu("Face 1");
		private var facePoint2ColorMenu:ui.RGBAMenu = new ui.RGBAMenu("Face 2");
		private var breastPoint1ColorMenu:ui.RGBAMenu = new ui.RGBAMenu("Breast 1");
		private var breastPoint2ColorMenu:ui.RGBAMenu = new ui.RGBAMenu("Breast 2");
		private var breastPoint3ColorMenu:ui.RGBAMenu = new ui.RGBAMenu("Breast 3");
		private var vulvaPoint1ColorMenu:ui.RGBAMenu = new ui.RGBAMenu("Vulva 1");
		private var vulvaPoint2ColorMenu:ui.RGBAMenu = new ui.RGBAMenu("Vulva 2");
		private var anusPoint1ColorMenu:ui.RGBAMenu = new ui.RGBAMenu("Anus 1");
		private var anusPoint2ColorMenu:ui.RGBAMenu = new ui.RGBAMenu("Anus 2");
		
		//Background Modification
		private var outerDiamondColorMenu:ui.RGBAMenu = new ui.RGBAMenu("O.Diamond");
		private var innerDiamondColor1Menu:ui.RGBAMenu = new ui.RGBAMenu("TopLeft");
		private var innerDiamondColor2Menu:ui.RGBAMenu = new ui.RGBAMenu("Middle");
		private var innerDiamondColor3Menu:ui.RGBAMenu = new ui.RGBAMenu("BottomRight");
		private var backlightColorMenu:ui.RGBAMenu = new ui.RGBAMenu("Backlight");
		
		private var autoAdjustGradientsToBaseSkin:Boolean = true;
		
		private var templateInUse:MasterTemplate;
		
		public function ppppuMenu(target:MasterTemplate) 
		{
			templateInUse = target;
			faceGradientChangingElements = [templateInUse.Face.Element.SkinGradient, templateInUse.EarL.Element.SkinGradient, templateInUse.EarR.Element.SkinGradient];
			breastGradientChangingElements = [templateInUse.Boob2L.Element.SkinGradient,templateInUse.Boob2R.Element.SkinGradient, templateInUse.Boob3L.Element.SkinGradient, templateInUse.Boob3R.Element.SkinGradient];
			vulvaGradientChangingElements = [templateInUse.Vulva.Element.SkinGradient, templateInUse.TurnedVulva.Element.SkinGradient, templateInUse.VulvaBackview.Element.SkinGradient];
			anusGradientChangingElements = [templateInUse.Anus.Element.SkinGradient];
			areolaGradientChangingElements = [templateInUse.AreolaL.Element.SkinGradient, templateInUse.AreolaR.Element.SkinGradient];
			InitMenu();
		}
				
		private function InitMenu():void
		{
			var p_Menu:Panel = new Panel(null);
			p_Menu.setSize(580, 120);
			
			sp_Menu = new SlidingPanel(p_Menu, new Rectangle(0, 690, 580, 30), new Point(0, 720), new Point(0, 600));
			addChild(sp_Menu);
			
			//var p_GradientSubMenu:Panel = new Panel(null);
			var p_GradientSubMenu:Sprite = new Sprite();
			//p_GradientSubMenu.setSize(100, 80);
			
			p_ExpressionSelectMenu = new ExpressionSelectPanel(templateInUse);
			
			//Add labels for skin gradients sub menu
			var l_faceGradient:Label = new Label(p_GradientSubMenu, 0, 0, "Face");
			var l_breastGradient:Label = new Label(p_GradientSubMenu, 0, 20, "Breast");
			var l_vulvaGradient:Label = new Label(p_GradientSubMenu, 0, 40, "Vulva");
			var l_anusGradient:Label = new Label(p_GradientSubMenu, 0, 60, "Anus");
			
			//Add buttons for the gradient sub menu
			
			//Face/Ear buttons
			var pb_faceGradPoint1:PopupButton = new PopupButton(p_GradientSubMenu, 35, 1, "Face1");
			pb_faceGradPoint1.setSize(16, 16);
			pb_faceGradPoint1.addChild(new ColorButtonGraphic);
			//Disables the colorButtonGraphic instance from dealing with mouse events.
			pb_faceGradPoint1.mouseChildren = false;
			pb_faceGradPoint1.bindPopup(facePoint1ColorMenu, "rightOuter", "bottomInner");
			
			var pb_faceGradPoint2:PopupButton = new PopupButton(p_GradientSubMenu, 55, 1, "Face2");
			pb_faceGradPoint2.setSize(16, 16);
			pb_faceGradPoint2.addChild(new ColorButtonGraphic);
			pb_faceGradPoint2.mouseChildren = false;
			pb_faceGradPoint2.bindPopup(facePoint2ColorMenu, "rightOuter", "bottomInner");
			
			//Breast buttons
			var pb_breastGradPoint1:PopupButton = new PopupButton(p_GradientSubMenu, 35, 21);
			pb_breastGradPoint1.setSize(16, 16);
			pb_breastGradPoint1.addChild(new ColorButtonGraphic);
			pb_breastGradPoint1.mouseChildren = false;
			pb_breastGradPoint1.bindPopup(breastPoint1ColorMenu, "rightOuter", "bottomInner");
			
			var pb_breastGradPoint2:PopupButton = new PopupButton(p_GradientSubMenu, 55, 21);
			pb_breastGradPoint2.setSize(16, 16);
			pb_breastGradPoint2.addChild(new ColorButtonGraphic);
			pb_breastGradPoint2.mouseChildren = false;
			pb_breastGradPoint2.bindPopup(breastPoint2ColorMenu, "rightOuter", "bottomInner");
			
			var pb_breastGradPoint3:PopupButton = new PopupButton(p_GradientSubMenu, 75, 21);
			pb_breastGradPoint3.setSize(16, 16);
			pb_breastGradPoint3.addChild(new ColorButtonGraphic);
			pb_breastGradPoint3.mouseChildren = false;
			pb_breastGradPoint3.bindPopup(breastPoint3ColorMenu, "rightOuter", "bottomInner");
			
			//Vulva buttons
			var pb_vulvaGradPoint1:PopupButton = new PopupButton(p_GradientSubMenu, 35, 41);
			pb_vulvaGradPoint1.setSize(16, 16);
			pb_vulvaGradPoint1.addChild(new ColorButtonGraphic);
			pb_vulvaGradPoint1.mouseChildren = false;
			pb_vulvaGradPoint1.bindPopup(vulvaPoint1ColorMenu, "rightOuter", "bottomInner");
			
			var pb_vulvaGradPoint2:PopupButton = new PopupButton(p_GradientSubMenu, 55, 41);
			pb_vulvaGradPoint2.setSize(16, 16);
			pb_vulvaGradPoint2.addChild(new ColorButtonGraphic);
			pb_vulvaGradPoint2.mouseChildren = false;
			pb_vulvaGradPoint2.bindPopup(vulvaPoint2ColorMenu, "rightOuter", "bottomInner");
			
			//Anus buttons
			var pb_anusGradPoint1:PopupButton = new PopupButton(p_GradientSubMenu, 35, 61);
			pb_anusGradPoint1.setSize(16, 16);
			pb_anusGradPoint1.addChild(new ColorButtonGraphic);
			pb_anusGradPoint1.mouseChildren = false;
			pb_anusGradPoint1.bindPopup(anusPoint1ColorMenu, "rightOuter", "bottomInner");
			
			var pb_anusGradPoint2:PopupButton = new PopupButton(p_GradientSubMenu, 55, 61);
			pb_anusGradPoint2.setSize(16, 16);
			pb_anusGradPoint2.addChild(new ColorButtonGraphic);
			pb_anusGradPoint2.mouseChildren = false;
			pb_anusGradPoint2.bindPopup(anusPoint2ColorMenu, "rightOuter", "bottomInner");
			
			var cbox_autoAdjustColors:CheckBox = new CheckBox(p_GradientSubMenu, 0, 80, "Auto adjust to skin color changes", AutoAdjustColorHandler);
			cbox_autoAdjustColors.selected = true;
			//End of skin gradient items
			
			var con_iris:Sprite = new Sprite();
			irisRColorMenu.x = 160;
			con_iris.addChild(irisLColorMenu);
			con_iris.addChild(irisRColorMenu);
			var pb_iris:ui.PopupButton = new ui.PopupButton(p_Menu, 10, 10, "Iris");
			pb_iris.bindPopup(con_iris, "rightOuter", "bottomInner");
			
			var pb_hair:ui.PopupButton = new ui.PopupButton(p_Menu, 10, 30, "Hair");
			pb_hair.bindPopup(hairColorMenu, "rightOuter", "bottomInner");
			
			var pb_sclera:ui.PopupButton = new ui.PopupButton(p_Menu, 10, 50, "Sclera");
			pb_sclera.bindPopup(scleraColorMenu, "rightOuter", "bottomInner");
			
			var pb_lips:ui.PopupButton = new ui.PopupButton(p_Menu, 10, 70, "Lips");
			pb_lips.bindPopup(lipsColorMenu, "rightOuter", "bottomInner");
			
			var pb_skin:ui.PopupButton = new ui.PopupButton(p_Menu, 10, 90, "Skin");
			pb_skin.bindPopup(skinColorMenu, "rightOuter", "bottomInner");
			
			var pb_nipples:ui.PopupButton = new PopupButton(p_Menu, 120, 10, "Nipples");
			pb_nipples.bindPopup(nippleColorMenu, "rightOuter", "bottomInner");
			
			var pb_skinGradients:PopupButton = new PopupButton(p_Menu, 120, 90, "Skin Gradients");
			pb_skinGradients.bindPopup(p_GradientSubMenu, "rightOuter", "bottomInner");
			
			var b_File:PushButton = new PushButton(p_Menu, 230, 10, "Load File", loadFile);
			
			//Set up expression menu button
			var pb_ExpressionMenu:PopupButton = new PopupButton(p_Menu, 230, 30, "Expression submenu");
			pb_ExpressionMenu.addEventListener(MouseEvent.CLICK, ExpressionButtonHandler);
			pb_ExpressionMenu.bindPopup(p_ExpressionSelectMenu, "middle", "bottomInner"); 
			
			
			hairColorMenu.addEventListener(Event.CHANGE, HairSlidersChange);
			skinColorMenu.addEventListener(Event.CHANGE, SkinSlidersChange);
			scleraColorMenu.addEventListener(Event.CHANGE, ScleraSliderChanged);
			lipsColorMenu.addEventListener(Event.CHANGE, LipsSliderChanged);
			irisLColorMenu.addEventListener(Event.CHANGE, IrisLSliderChanged);
			irisRColorMenu.addEventListener(Event.CHANGE, IrisRSliderChanged);
			nippleColorMenu.addEventListener(Event.CHANGE, NipplesSlidersChanged);
			
			
			//var peachStandardGradientEndPoint:ColorTransform = new ColorTransform(0,0,0,0, 243,182,154, 255);
			//var peachAnusPoint1Skin:ColorTransform = new ColorTransform(0,0,0,0, 255,166,159, 255);
			facePoint1ColorMenu.addEventListener(Event.CHANGE, FaceGradientSlidersChange);
			facePoint2ColorMenu.addEventListener(Event.CHANGE, FaceGradientSlidersChange);
			breastPoint1ColorMenu.addEventListener(Event.CHANGE, BreastGradientSlidersChange);	
			breastPoint2ColorMenu.addEventListener(Event.CHANGE, BreastGradientSlidersChange);	
			breastPoint3ColorMenu.addEventListener(Event.CHANGE, BreastGradientSlidersChange);	
			vulvaPoint1ColorMenu.addEventListener(Event.CHANGE, VulvaGradientSlidersChange);
			vulvaPoint2ColorMenu.addEventListener(Event.CHANGE, VulvaGradientSlidersChange);
			anusPoint1ColorMenu.addEventListener(Event.CHANGE, AnusGradientSlidersChange);
			anusPoint2ColorMenu.addEventListener(Event.CHANGE, AnusGradientSlidersChange);
			
			InitializeBackgroundSubMenu(p_Menu);
		}
		
		private function loadFile(e:MouseEvent):void 
		{
			var f:FileReferenceHelper = new FileReferenceHelper(handler, "Images", "*.jpg;*.gif;*.png");
		}
		
		private function handler(e:ByteArrayLoadedEvent):void 
		{
			var bmp:Bitmap = e.getBitmap();
			//And do nothing with it...
		}
		
		private function ExpressionButtonHandler(e:MouseEvent):void
		{
			var core:ppppuCore = this.parent as ppppuCore;
			p_ExpressionSelectMenu.UpdateLists(core.GetListOfAnimationNames(), core.GetListOfCharacterNames());
		}
		
		private function LipsSliderChanged(e:Event):void
		{
			var m:ui.RGBAMenu = e.target as ui.RGBAMenu;
			var ct:ColorTransform = new ColorTransform(0, 0, 0, 0, m.R, m.G, m.B, m.A);
			//templateInUse.Mouth.LipsColor.transform.colorTransform = ct;
		}
		private function ScleraSliderChanged(e:Event):void
		{
			var m:ui.RGBAMenu = e.target as ui.RGBAMenu;
			var ct:ColorTransform = new ColorTransform(0, 0, 0, 0, m.R, m.G, m.B, m.A);
			templateInUse.EyeL.Element.ScleraSettings.Sclera.scleraColor.transform.colorTransform = ct;
			templateInUse.EyeR.Element.ScleraSettings.Sclera.scleraColor.transform.colorTransform = ct;
		}
		private function IrisLSliderChanged(e:Event):void
		{
			var m:ui.RGBAMenu = e.target as ui.RGBAMenu;
			var ct:ColorTransform = new ColorTransform(0, 0, 0, 0, m.R, m.G, m.B, m.A);
			templateInUse.EyeL.Element.InnerEyeSettings.InnerEye.Iris.transform.colorTransform = ct;
		}
		private function IrisRSliderChanged(e:Event):void
		{
			var m:ui.RGBAMenu = e.target as ui.RGBAMenu;
			var ct:ColorTransform = new ColorTransform(0, 0, 0, 0, m.R, m.G, m.B, m.A);
			templateInUse.EyeR.Element.InnerEyeSettings.InnerEye.Iris.transform.colorTransform = ct;
		}
		
		public function SkinSlidersChange(e:Event):void
		{
			var m:ui.RGBAMenu = e.target as ui.RGBAMenu;
			//Alpha is to never be adjusted
			var ct:ColorTransform = new ColorTransform(0, 0, 0, 0, m.R, m.G, m.B, 255);
			
			//Color only
			templateInUse.UpperLegL.Element.Skin.transform.colorTransform = ct;
			templateInUse.UpperLegR.Element.Skin.transform.colorTransform = ct;
			templateInUse.Groin.Element.Skin.transform.colorTransform = ct;
			templateInUse.Groin2.Element.Skin.transform.colorTransform = ct;
			templateInUse.Hips.Element.Skin.transform.colorTransform = ct;
			templateInUse.Hips2.Element.Skin.transform.colorTransform = ct;
			templateInUse.TurnedHips.Element.Skin.transform.colorTransform = ct;
			templateInUse.TurnedMidTorso.Element.Skin.transform.colorTransform = ct;
			templateInUse.TurnedUpperTorso.Element.Skin.transform.colorTransform = ct;
			templateInUse.Vulva2.Element.Skin.transform.colorTransform = ct;
			templateInUse.MidTorso.Element.Skin.transform.colorTransform = ct;
			templateInUse.UpperTorso.Element.Skin.transform.colorTransform = ct;
			templateInUse.MidBack.Element.Skin.transform.colorTransform = ct;
			templateInUse.UpperBack.Element.Skin.transform.colorTransform = ct;
			templateInUse.LowerBack.Element.Skin.transform.colorTransform = ct;
			templateInUse.Chest.Element.Skin.transform.colorTransform = ct;
			templateInUse.ArmL.Element.Skin.transform.colorTransform = ct;
			templateInUse.ArmR.Element.Skin.transform.colorTransform = ct;
			templateInUse.Arm2L.Element.Skin.transform.colorTransform = ct;
			templateInUse.Arm2R.Element.Skin.transform.colorTransform = ct;
			templateInUse.Arm3L.Element.Skin.transform.colorTransform = ct;
			templateInUse.Arm3R.Element.Skin.transform.colorTransform = ct;
			templateInUse.ForearmL.Element.Skin.transform.colorTransform = ct;
			templateInUse.ForearmR.Element.Skin.transform.colorTransform = ct;
			templateInUse.ShoulderL.Element.Skin.transform.colorTransform = ct;
			templateInUse.ShoulderR.Element.Skin.transform.colorTransform = ct;
			templateInUse.Neck.Element.Skin.transform.colorTransform = ct;
			templateInUse.FrontButtL.Element.Skin.transform.colorTransform = ct;
			templateInUse.FrontButtR.Element.Skin.transform.colorTransform = ct;
			templateInUse.ButtCheekL.Element.Skin.transform.colorTransform = ct;
			templateInUse.ButtCheekR.Element.Skin.transform.colorTransform = ct;
			templateInUse.Navel.Element.Skin.transform.colorTransform = ct;
			templateInUse.TurnedFace.Element.Skin.transform.colorTransform = ct;
			templateInUse.TurnedFace2.Element.Skin.transform.colorTransform = ct;
			templateInUse.TurnedFace3.Element.Skin.transform.colorTransform = ct;
			templateInUse.EyeL.Element.EyelidSettings.Eyelid.transform.colorTransform = ct;
			templateInUse.EyeR.Element.EyelidSettings.Eyelid.transform.colorTransform = ct;
			templateInUse.EyeL.Element.ScleraSettings.Sclera.Skin.transform.colorTransform = ct;
			templateInUse.EyeR.Element.ScleraSettings.Sclera.Skin.transform.colorTransform = ct;
			templateInUse.BoobL.Element.Skin.transform.colorTransform = ct;
			templateInUse.BoobR.Element.Skin.transform.colorTransform = ct;
			templateInUse.SideBoobL.Element.Skin.transform.colorTransform = ct;
			templateInUse.HandL.Element.Skin.transform.colorTransform = ct;
			templateInUse.HandR.Element.Skin.transform.colorTransform = ct;
			templateInUse.Hand2L.Element.Skin.transform.colorTransform = ct;
			templateInUse.Hand2R.Element.Skin.transform.colorTransform = ct;
			
			//Placeholder for custom elements with changable skin
			/*
			 * for(var i:int = 0, l:int = customElementsArray/Vector.length; i < l; ++i)
			 * {
			 * 		//Note for the future: Custom elements with changable skin might need to be something added from external swfs.
			 * 		customElementsArray/Vector[i].Element.Skin.transform.colorTransform = ct;
			 * }
			 * */
			
			if (autoAdjustGradientsToBaseSkin)
			{
				facePoint1ColorMenu.setValue(ct);
				breastPoint1ColorMenu.setValue(ct);
				breastPoint2ColorMenu.setValue(ct);
				vulvaPoint2ColorMenu.setValue(ct);
				anusPoint2ColorMenu.setValue(ct);
			}
		}
		private function GetColorMatrixFilter(hue:Number, saturation:Number, brightness:Number, contrast:Number):ColorMatrixFilter
		{
			var colorMatrixValues:Array = new Array(1,0,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0);
			var hueDegrees:Number = hue * Math.PI / 180.0;
			var U:Number = Math.cos(hueDegrees); //For rotation around YIQ Y axis
			var W:Number = Math.sin(hueDegrees); //For rotation around YIQ Y axis
			//var S:Number = saturation;
			var V:Number = brightness;
			var C:Number = contrast;
			var VSU:Number = V*saturation*U; //To reduce the number of multiplication operations needed
			var VSW:Number = V*saturation*W; //To reduce the number of multiplication operations needed
			var cOffset:Number = 128 - C * 128;
			colorMatrixValues[0] = (.299*V + .701*VSU + .168*VSW)*C;
			colorMatrixValues[1] = (.587*V - .587*VSU + .330*VSW)*C;
			colorMatrixValues[2] = (.114*V - .114*VSU - .497*VSW)*C;
			//colorMatrixValues[3] = 0; //alpha offset
			colorMatrixValues[4] = cOffset;
			colorMatrixValues[5] = (.299*V - .299*VSU - .328*VSW)*C;
			colorMatrixValues[6] = (.587*V + .413*VSU + .035*VSW)*C;
			colorMatrixValues[7] = (.114*V - .114*VSU + .292*VSW)*C;
			//colorMatrixValues[8] = 0; //alpha offset
			colorMatrixValues[9] = cOffset;
			colorMatrixValues[10] = (.299*V - .3*VSU + 1.25*VSW)*C;
			colorMatrixValues[11] = (.587*V - .588*VSU - 1.05*VSW)*C;
			colorMatrixValues[12] = (.114*V + .886*VSU - .203*VSW)*C; 
			//colorMatrixValues[13] = 0; //alpha offset
			colorMatrixValues[14] = cOffset;
			//colorMatrixValues[15] = 0; //alpha
			//colorMatrixValues[16] = 0; //alpha
			//colorMatrixValues[17] = 0; //alpha
			//colorMatrixValues[18] = 0; //alpha offset
			//colorMatrixValues[19] = 0;
			return new ColorMatrixFilter(colorMatrixValues);
		}
		public function HairSlidersChange(e:Event):void
		{
			var m:ui.HSVCMenu = e.target as ui.HSVCMenu;
			var cmf:ColorMatrixFilter = GetColorMatrixFilter(m.H, m.S, m.V, m.C);
			
			if (templateInUse)
			{
				/*Hair Elements are no longer a part of the master template at compile time. They must be added
				 * during run time and when this happens they are added to a vector.*/
				var masterTemplate:MasterTemplate = templateInUse as MasterTemplate;
				for (var i:int = 0, l:int = masterTemplate.customHairElements.length; i < l; ++i)
				{
					masterTemplate.customHairElements[i].filters = [cmf];
				}
				/*templateInUse.HairSideL.filters = [cmf];
				templateInUse.HairSide2L.filters = [cmf];
				templateInUse.HairSide3L.filters = [cmf];
				templateInUse.HairSideR.filters = [cmf];
				templateInUse.HairSide2R.filters = [cmf];
				templateInUse.HairSide3R.filters = [cmf];
				templateInUse.HairFront.filters = [cmf];
				templateInUse.HairFrontAngled.filters = [cmf];
				templateInUse.HairFrontAngled2.filters = [cmf];
				templateInUse.HairBack.filters = [cmf];*/
			}
		}
		public function NipplesSlidersChanged(e:Event):void
		{
			var m:ui.RGBAMenu = e.target as ui.RGBAMenu;
			var ct:ColorTransform = new ColorTransform(0, 0, 0, 0, m.R, m.G, m.B, m.A);
			templateInUse.NippleL.Element.Skin.transform.colorTransform = ct;
			templateInUse.NippleR.Element.Skin.transform.colorTransform = ct;
			areolaGradientValues[0] = GetColorUintValue(m.R, m.G, m.B);
			areolaGradientValues[1] = GetColorUintValue(m.R, m.G, m.B, 0);
			GradientChange(AREOLAGRADIENT, areolaGradientChangingElements);
		}
		public function FaceGradientSlidersChange(e:Event):void
		{
			var m:RGBAMenu = e.target as RGBAMenu;
			switch(m.name)
			{
				case "Face 1":
					faceGradientValues[0] = GetColorUintValue(m.R, m.G, m.B);
					break;
				case "Face 2":
					faceGradientValues[1] = GetColorUintValue(m.R, m.G, m.B);
					break;
			}
			GradientChange(FACEGRADIENT, faceGradientChangingElements);
		}
		
		public function BreastGradientSlidersChange(e:Event):void
		{
			var m:RGBAMenu = e.target as RGBAMenu;
			switch(m.name)
			{
				case "Breast 1":
					breastGradientValues[0] = GetColorUintValue(m.R, m.G, m.B);
					break;
				case "Breast 2":
					breastGradientValues[1] = GetColorUintValue(m.R, m.G, m.B);
					break;
				case "Breast 3":
					breastGradientValues[2] = GetColorUintValue(m.R, m.G, m.B);
					break;
			}
			GradientChange(BREASTGRADIENT, breastGradientChangingElements);
		}
		
		public function VulvaGradientSlidersChange(e:Event):void
		{
			var m:RGBAMenu = e.target as RGBAMenu;
			switch(m.name)
			{
				case "Vulva 1":
					vulvaGradientValues[0] = GetColorUintValue(m.R, m.G, m.B);
					break;
				case "Vulva 2":
					vulvaGradientValues[1] = GetColorUintValue(m.R, m.G, m.B);
					break;
			}
			GradientChange(VULVAGRADIENT, vulvaGradientChangingElements);
		}
		
		public function AnusGradientSlidersChange(e:Event):void
		{
			var m:RGBAMenu = e.target as RGBAMenu;
			switch(m.name)
			{
				case "Anus 1":
					anusGradientValues[0] = GetColorUintValue(m.R, m.G, m.B);
					break;
				case "Anus 2":
					anusGradientValues[1] = GetColorUintValue(m.R, m.G, m.B);
					break;
			}
			GradientChange(ANUSGRADIENT, anusGradientChangingElements);
		}
		
		private function AutoAdjustColorHandler(e:MouseEvent):void
		{
			var cbox:CheckBox = e.target as CheckBox;
			autoAdjustGradientsToBaseSkin = cbox.selected;
		}
		
		public function ChangeSlidersToCharacterValues(character:ppppuCharacter):void
		{
			skinColorMenu.setValueFromUint(character.GetSkinColor());
			
			scleraColorMenu.setValueFromUint(character.GetScleraColor());
			lipsColorMenu.setValueFromUint(character.GetLipColor());
			irisLColorMenu.setValueFromUint(character.GetIrisLColor());
			irisRColorMenu.setValueFromUint(character.GetIrisRColor());
			nippleColorMenu.setValueFromUint(character.GetNippleColor());
			
			//Gradients
			var charFaceColors:Array = character.GetFaceGradients();
			facePoint1ColorMenu.setValueFromUint(charFaceColors[0]);
			facePoint2ColorMenu.setValueFromUint(charFaceColors[1]);
			var charBreastColors:Array = character.GetBreastGradients();
			breastPoint1ColorMenu.setValueFromUint(charBreastColors[0]);
			breastPoint2ColorMenu.setValueFromUint(charBreastColors[1]);
			breastPoint3ColorMenu.setValueFromUint(charBreastColors[2]);
			var charVulvaColors:Array = character.GetVulvaGradients();
			vulvaPoint1ColorMenu.setValueFromUint(charVulvaColors[0]);
			vulvaPoint2ColorMenu.setValueFromUint(charVulvaColors[1]);
			var charAnusColors:Array = character.GetAnusGradients();
			anusPoint1ColorMenu.setValueFromUint(charAnusColors[0]);
			anusPoint2ColorMenu.setValueFromUint(charAnusColors[1]);
			
			//BG
			innerDiamondColor1Menu.setValueFromUint(character.GetDiamondColor1());
			innerDiamondColor2Menu.setValueFromUint(character.GetDiamondColor2());
			innerDiamondColor3Menu.setValueFromUint(character.GetDiamondColor3());
			outerDiamondColorMenu.setValueFromUint(character.GetOuterDiamondColor());
			backlightColorMenu.setValueFromUint(character.GetBacklightColor());
		}
		
		public function GradientChange(type:int, skinGradientGraphics:Array/*, colorUIntValues:Array*/):void
		{
			var colorUIntValues:Array;
			switch(type)
			{
				case FACEGRADIENT:
					colorUIntValues = faceGradientValues;
					break;
				case VULVAGRADIENT:
					colorUIntValues = vulvaGradientValues;
					break;
				case ANUSGRADIENT:
					colorUIntValues = anusGradientValues;
					break;
				case BREASTGRADIENT:
					colorUIntValues = breastGradientValues;
					break;
				case AREOLAGRADIENT:
					colorUIntValues = areolaGradientValues;
					break;
			}
			for (var graphicIndex:int = 0, graphicsCount:int = skinGradientGraphics.length; graphicIndex < graphicsCount; ++graphicIndex )
			{
				if (skinGradientGraphics[graphicIndex] is Sprite)
				{
					var skinGradientGraphic:Sprite = skinGradientGraphics[graphicIndex];
					var shapeToEdit:Shape = skinGradientGraphic as Shape;
					if (skinGradientGraphic.numChildren >= 1)
					{
						shapeToEdit = skinGradientGraphic.getChildAt(0) as Shape;
					}
					var graphicsData:Vector.<IGraphicsData> = shapeToEdit.graphics.readGraphicsData(false);
					
					for (var i:uint = 0, l:uint = graphicsData.length; i < l; ++i)
					{
						if (graphicsData[i] is GraphicsGradientFill)
						{
							var gradientFill:GraphicsGradientFill = graphicsData[i] as GraphicsGradientFill;
							for (var x:int = 0, fillLength:int = gradientFill.colors.length; x < fillLength; ++x)
							{
								if (x < colorUIntValues.length)
								{
									gradientFill.colors[x] = colorUIntValues[x];
									gradientFill.alphas[x] = (colorUIntValues[x] >>> 24) * 0.3921568627450980392156862745098;
								}
								else
								{
									gradientFill.colors[x] = colorUIntValues[colorUIntValues.length];
									gradientFill.alphas[x] = (colorUIntValues[colorUIntValues.length] >>> 24) * 0.3921568627450980392156862745098;
								}
								
							}
							//For the ears, their colors are the same as the face but in reverse order.
							if (type == FACEGRADIENT && skinGradientGraphic.parent.parent.name.indexOf("Ear") != -1)
							{
								//Hardcoded nastiness to "correct" the color order for the ears
								var earEdgeColor:uint = gradientFill.colors[0];
								gradientFill.colors[0] = gradientFill.colors[1];
								gradientFill.colors[1] = earEdgeColor;
							}
							graphicsData[i] = gradientFill;
						}
					}
					
					shapeToEdit.graphics.clear();
					shapeToEdit.graphics.drawGraphicsData(graphicsData);
				}
			}
		}
	
		private function GetColorUintValue(red:uint=0, green:uint=0, blue:uint=0, alpha:uint = 255):uint
		{
			if (red > 0xFF) red = 0xFF; if (green > 0xFF) green = 0xFF; if (blue > 0xFF) blue = 0xFF; if (alpha > 0xFF) alpha = 0xFF;
			if (red < 0x00) red = 0x00; if (green < 0x00) green = 0x00; if (blue < 0x00) blue = 0x00; if (alpha < 0x00) alpha = 0x00;
			var colorValue:uint = 0;
			colorValue += (alpha << 24) + (red << 16) + (green << 8) + blue;
			return colorValue;
		}
		
		private function InitializeBackgroundSubMenu(parentPanel:Panel):void
		{
			var p_BackgroundSubMenu:Sprite = new Sprite();
			
			//Add labels for skin gradients sub menu
			var l_IDiamond:Label = new Label(p_BackgroundSubMenu, 0, 0, "Inner Diamond");
			//var l_IDiamond2:Label = new Label(p_BackgroundSubMenu, 0, 20, "Inner Diamond 2");
			//var l_IDiamond3:Label = new Label(p_BackgroundSubMenu, 0, 40, "Inner Diamond 3");
			var l_ODiamond:Label = new Label(p_BackgroundSubMenu, 0, 20, "Outer Diamond");
			var l_Backlight:Label = new Label(p_BackgroundSubMenu, 0, 40, "Back Light");
			
			var pb_IDiamond1:PopupButton = new PopupButton(p_BackgroundSubMenu, 75, 1, "I. Diamond 1");
			pb_IDiamond1.setSize(16, 16);
			pb_IDiamond1.addChild(new ColorButtonGraphic);
			//Disables the colorButtonGraphic instance from dealing with mouse events.
			pb_IDiamond1.mouseChildren = false;
			pb_IDiamond1.bindPopup(innerDiamondColor1Menu, "rightOuter", "bottomInner");
			
			var pb_IDiamond2:PopupButton = new PopupButton(p_BackgroundSubMenu, 95, 1, "I. Diamond 2");
			pb_IDiamond2.setSize(16, 16);
			pb_IDiamond2.addChild(new ColorButtonGraphic);
			pb_IDiamond2.mouseChildren = false;
			pb_IDiamond2.bindPopup(innerDiamondColor2Menu, "leftOuter", "bottomInner");
			
			var pb_IDiamond3:PopupButton = new PopupButton(p_BackgroundSubMenu, 115, 1, "I. Diamond 3");
			pb_IDiamond3.setSize(16, 16);
			pb_IDiamond3.addChild(new ColorButtonGraphic);
			pb_IDiamond3.mouseChildren = false;
			pb_IDiamond3.bindPopup(innerDiamondColor3Menu, "leftOuter", "bottomInner");
			
			var pb_ODiamond:PopupButton = new PopupButton(p_BackgroundSubMenu, 75, 21, "O. Diamond");
			pb_ODiamond.setSize(16, 16);
			pb_ODiamond.addChild(new ColorButtonGraphic);
			pb_ODiamond.mouseChildren = false;
			pb_ODiamond.bindPopup(outerDiamondColorMenu, "rightOuter", "bottomInner");
			
			var pb_backlight:PopupButton = new PopupButton(p_BackgroundSubMenu, 75, 41, "Backlight");
			pb_backlight.setSize(16, 16);
			pb_backlight.addChild(new ColorButtonGraphic);
			pb_backlight.mouseChildren = false;
			pb_backlight.bindPopup(backlightColorMenu, "rightOuter", "bottomInner");
			
			var pb_background:PopupButton = new PopupButton(parentPanel, 120, 30, "Background");
			pb_background.bindPopup(p_BackgroundSubMenu, "rightOuter", "bottomInner");
			
			outerDiamondColorMenu.addEventListener(Event.CHANGE, OuterDiamondSliderChange);
			innerDiamondColor1Menu.addEventListener(Event.CHANGE, InnerDiamondSlidersChange);
			innerDiamondColor2Menu.addEventListener(Event.CHANGE, InnerDiamondSlidersChange);
			innerDiamondColor3Menu.addEventListener(Event.CHANGE, InnerDiamondSlidersChange);
			backlightColorMenu.addEventListener(Event.CHANGE, BacklightSliderChange);
		}
		
		private function OuterDiamondSliderChange(e:Event):void
		{
			var m:RGBAMenu = e.target as RGBAMenu;
			var mainStage:PPPPU_Stage = templateInUse.GetPPPPU_Stage() as PPPPU_Stage;
			var ct:ColorTransform = new ColorTransform(0, 0, 0, 0, m.R, m.G, m.B, m.A);
			mainStage.OuterDiamondBG.OuterDiamond.Color.transform.colorTransform = ct;
			mainStage.TransitionDiamondBG.TransitionDiamond.Color4.transform.colorTransform = ct;
		}
		
		private function InnerDiamondSlidersChange(e:Event):void
		{
			var m:RGBAMenu = e.target as RGBAMenu;
			var mainStage:PPPPU_Stage = templateInUse.GetPPPPU_Stage() as PPPPU_Stage;
			var ct:ColorTransform = new ColorTransform(0, 0, 0, 0, m.R, m.G, m.B, m.A);
			switch(m.name)
			{
				case "TopLeft":
					mainStage.InnerDiamondBG.InnerDiamond.Color1.transform.colorTransform = ct;
					mainStage.TransitionDiamondBG.TransitionDiamond.Color1.transform.colorTransform = ct;
					break;
				case "Middle":
					mainStage.InnerDiamondBG.InnerDiamond.Color2.transform.colorTransform = ct;
					mainStage.TransitionDiamondBG.TransitionDiamond.Color2.transform.colorTransform = ct;
					break;
				case "BottomRight":
					mainStage.InnerDiamondBG.InnerDiamond.Color3.transform.colorTransform = ct;
					mainStage.TransitionDiamondBG.TransitionDiamond.Color3.transform.colorTransform = ct;
					break;
			}
		}
		
		private function BacklightSliderChange(e:Event):void
		{
			var m:RGBAMenu = e.target as RGBAMenu;
			var ct:ColorTransform = new ColorTransform(0, 0, 0, 1, m.R, m.G, m.B, 0);
			var mainStage:PPPPU_Stage = templateInUse.GetPPPPU_Stage() as PPPPU_Stage;
			mainStage.BacklightBG.Backlight.BacklightGfx.transform.colorTransform = ct;
		}
		
		//Checks to see if the menu's slider panel is active (visible). If it is, return true
		public function MenuNeedsInputFocus():Boolean
		{
			//If the sliding panel is active, then the menu needs input focus
			return sp_Menu.IsPanelActive();
		}
	}
	
}