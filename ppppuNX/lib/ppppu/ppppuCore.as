package ppppu 
{
	import AnimationSettings.CowgirlInfo;
	import avmplus.DescribeTypeJSON;
	import CharacterHair.*;
	import Characters.PeachCharacter;
	import Characters.RosalinaCharacter;
	import com.greensock.easing.Linear;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.FrameLabel;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.net.registerClassAlias;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import ppppu.TweenDataParser;
	import com.greensock.plugins.*;
	import com.greensock.data.TweenLiteVars;
	import com.greensock.*;
	import flash.geom.Rectangle;
	import ppppu.TemplateBase;
	import flash.ui.Keyboard;
	
	/**
	 * Responsible for all the various aspects of ppppuNX. 
	 * @author ppppuProgrammer
	 */
	public class ppppuCore extends MovieClip
	{
		//Holds all the timelines to be used in the program.
		private var timelineLib:TimelineLibrary = new TimelineLibrary();
		
		//A movie clip that holds all the body elements used to create an animation. The elements in this class are controlled
		//TODO: Test the extendability of the master template. Can custom elements be easily added to it without big issues?
		private var masterTemplate:MasterTemplate = new MasterTemplate();
		//Responsible for holding the various timelines that will be added to a template. This dictionary is 3 levels deep, which is expressed by: timelineDict[Character][Animation][Part]
		//private var timelinesDict:Dictionary = new Dictionary();
		
		
		
		private var layerInfoDict:Dictionary = new Dictionary();
		private var animInfoDict:Dictionary = new Dictionary();
		public var mainStage:PPPPU_Stage;
		//Keeps track of what keys were pressed and/or held down
		private var keyDownStatus:Array = [];
		//Contains the names of the various animations that the master template can switch between. The names are indexed by their position in the vector.
		private var animationNameIndexes:Vector.<String> = new <String>["Cowgirl", "LeanBack", "LeanForward", "Grind", "ReverseCowgirl", "Paizuri", "Blowjob", "SideRide", "Swivel", "Anal"];
		private var characterList:Vector.<ppppuCharacter> = new <ppppuCharacter>[new PeachCharacter];
		private const defaultCharacter:ppppuCharacter = characterList[0];
		private const defaultCharacterName:String = defaultCharacter.GetName();
		private var currentCharacter:ppppuCharacter = defaultCharacter;
		//private var characterNameList:Vector.<String> = new <String>["Peach"/*, "Rosalina"*/];
		//private const defaultCharacter:String = characterNameList[0];
		//private var currentCharacter:String = defaultCharacter;
		private var currentAnimationIndex:uint = 0;
		private var embedTweenDataConverter:TweenDataParser = new TweenDataParser();
		
		//Main menu for the program.
		private var menu:ppppuMenu;
		private var charVoiceSystem:SoundEffectSystem;
		
		private var playSounds:Boolean = false;
		
		//For stopping animation
		private var lastPlayedFrame:int = -1;
		
		//private var displayWidthLimit:int;
		private var flashStartFrame:int;
		private var mainStageLoopStartFrame:int;
		
		//Settings related
		//public var settingsSaveFile:SharedObject = SharedObject.getLocal("ppppuNX");
		//public var userSettings:ppppuUserSettings = new ppppuUserSettings();
		
		//Constructor
		public function ppppuCore() 
		{
			//Create the "main stage" that holds the character template and various other movieclips such as the transition and backlight 
			mainStage = new PPPPU_Stage();
			mainStage.stop();
			addChild(mainStage);
			//masterTemplate = mainStage.CharacterLayer.MasterTemplateInstance;
			var frameLabels:Array = mainStage.currentLabels;
			for (var i:int = 0, l:int = frameLabels.length; i < l;++i)
			{
				var label:FrameLabel = frameLabels[i] as FrameLabel;
				if (label.name == "re")
				{mainStageLoopStartFrame = label.frame; }
				else if (label.name == "Start")
				{flashStartFrame = label.frame;}
			}
			//Add an event listener that'll allow for frame checking.
			mainStage.addEventListener(Event.ENTER_FRAME, RunLoop);
			this.cacheAsBitmap = true;
			//this.scrollRect = new Rectangle(0, 0, 480, 720);
			/*var test:CustomElementContainer = new CustomElementContainer();
			test.AddSprites(null, new DaisyHairBack(), null, new RosalinaHairBack());
			test.x = test.y = 200; 
			addChild(test);*/
			
			masterTemplate.Initialize(timelineLib);
			masterTemplate.visible = false;
			characterList[0].SetID(0);
			timelineLib.CheckSupplementTimelinesVectorRange(2, 5);
			timelineLib.CheckSupplementTimelinesVectorRange(0,7);
			//masterTemplate.
			
		}
		
		//Sets up the various aspects of the flash to get it ready for performing.
		public function Initialize():void
		{
			//Add the key listeners
			//TODO: Re-enable when done testing menus
			stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyPressCheck);
			stage.addEventListener(KeyboardEvent.KEY_UP, KeyReleaseCheck);
			
			//Initializing plugins for the GSAP library
			TweenPlugin.activate([FramePlugin, FrameLabelPlugin, TransformMatrixPlugin, VisiblePlugin]);
			//Set the default Ease for the tweens
			TweenLite.defaultEase = Linear.ease;
			TweenLite.defaultOverwrite = "none";
			//Disable mouse interaction for various objects
			mainStage.MenuLayer.mouseEnabled = true;
			//Disable mouse interaction for various objects
			mainStage.mouseEnabled = false;
			mainStage.CharacterLayer.mouseEnabled = false;
			mainStage.CharacterLayer.mouseChildren = false;
			mainStage.HelpLayer.mouseEnabled = false;
			mainStage.HelpLayer.mouseChildren = false;
			mainStage.BacklightBG.mouseEnabled = false;
			mainStage.BacklightBG.mouseChildren = false;
			mainStage.InnerDiamondBG.mouseEnabled = false;
			mainStage.InnerDiamondBG.mouseChildren = false;
			mainStage.OuterDiamondBG.mouseChildren = false;
			mainStage.OuterDiamondBG.mouseEnabled = false;
			mainStage.TransitionDiamondBG.mouseChildren = false;
			mainStage.TransitionDiamondBG.mouseEnabled = false;
			
			//Master template mouse event disabling
			masterTemplate.mouseChildren = false;
			masterTemplate.mouseEnabled = false;
			
			//AddCharacter(PeachCharacter);
			
			masterTemplate.currentCharacter = defaultCharacter;
			for (var childIndex:uint = 0, templateChildrenCount:uint = masterTemplate.numChildren; childIndex < templateChildrenCount; ++childIndex)
			{
				masterTemplate.getChildAt(childIndex).visible = false;
			}
			mainStage.x = (stage.stageWidth - mainStage.CharacterLayer.width) / 2;
			mainStage.CharacterLayer.addChild(masterTemplate);	
			
			animInfoDict["Cowgirl"] = new CowgirlInfo();
			
			//Switch the first animation.
			SwitchTemplateAnimation(0);
			//SwitchTemplateAnimation(8);
			//Testing new way of handling hair
			var hairFront:AnchoredElementBase = new AnchoredElementBase("HairFront", AnchoredElementBase.HAIRELEMENT);
			hairFront.AddNewDefinition(new PeachHairFrontDef());
			hairFront.AddNewDefinition(new RosalinaHairFrontDef());
			//hairFront.ChangeDisplayedSprite(0);
			hairFront.SetAnchorObjectForAnimation(masterTemplate["Face"],"Cowgirl", "LeanBack", "LeanForward", "Paizuri", "Swivel");
			
			var hairFrontAngled:AnchoredElementBase = new AnchoredElementBase("HairFrontAngled", AnchoredElementBase.HAIRELEMENT);
			hairFrontAngled.AddNewDefinition(new PeachHairFrontAngledDef);
			hairFrontAngled.SetAnchorObjectForAnimation(masterTemplate["TurnedFace2"], "Grind", "SideRide");
			hairFrontAngled.SetAnchorObjectForAnimation(masterTemplate["TurnedFace3"], "Blowjob");
			
			var hairFrontAngled2:AnchoredElementBase = new AnchoredElementBase("HairFrontAngled2", AnchoredElementBase.HAIRELEMENT);
			hairFrontAngled2.AddNewDefinition(new PeachHairFrontAngled2Def);
			hairFrontAngled2.SetAnchorObjectForAnimation(masterTemplate["TurnedFace"], "Anal", "ReverseCowgirl");
			
			
			var hairSideL:AnchoredElementBase = new AnchoredElementBase("HairSideL", AnchoredElementBase.HAIRELEMENT);
			hairSideL.AddNewDefinition(new PeachHairSideLDef);
			hairSideL.SetAnchorObjectForAnimation(masterTemplate["Face"], "Cowgirl", "LeanBack", "LeanForward", "Paizuri", "Swivel");
			hairSideL.SetAnchorObjectForAnimation(masterTemplate["TurnedFace2"], "Grind", "SideRide");
			hairSideL.SetAnchorObjectForAnimation(masterTemplate["TurnedFace3"], "Blowjob");
			hairSideL.SetAnchorObjectForAnimation(masterTemplate["TurnedFace"], "Anal", "ReverseCowgirl");
			
			var hairSideR:AnchoredElementBase = new AnchoredElementBase("HairSideR", AnchoredElementBase.HAIRELEMENT);
			hairSideR.AddNewDefinition(new PeachHairSideRDef);
			hairSideR.SetAnchorObjectForAnimation(masterTemplate["Face"], "Cowgirl", "LeanBack", "LeanForward", "Paizuri", "Swivel");
			hairSideR.SetAnchorObjectForAnimation(masterTemplate["TurnedFace2"], "Grind", "SideRide");
			hairSideR.SetAnchorObjectForAnimation(masterTemplate["TurnedFace3"], "Blowjob");
			hairSideR.SetAnchorObjectForAnimation(masterTemplate["TurnedFace"], "Anal", "ReverseCowgirl");
			
			var hairSide2L:AnchoredElementBase = new AnchoredElementBase("HairSide2L", AnchoredElementBase.HAIRELEMENT);
			hairSide2L.AddNewDefinition(new PeachHairSide2LDef);
			hairSide2L.SetAnchorObjectForAnimation(masterTemplate["Face"], "Cowgirl", "LeanBack", "LeanForward", "Paizuri", "Swivel");
			hairSide2L.SetAnchorObjectForAnimation(masterTemplate["TurnedFace2"], "Grind", "SideRide");
			hairSide2L.SetAnchorObjectForAnimation(masterTemplate["TurnedFace3"], "Blowjob");
			hairSide2L.SetAnchorObjectForAnimation(masterTemplate["TurnedFace"], "Anal", "ReverseCowgirl");
			
			var hairSide2R:AnchoredElementBase = new AnchoredElementBase("HairSide2R", AnchoredElementBase.HAIRELEMENT);
			hairSide2R.AddNewDefinition(new PeachHairSide2RDef);
			hairSide2R.SetAnchorObjectForAnimation(masterTemplate["Face"], "Cowgirl", "LeanBack", "LeanForward", "Paizuri", "Swivel");
			hairSide2R.SetAnchorObjectForAnimation(masterTemplate["TurnedFace2"], "Grind", "SideRide");
			hairSide2R.SetAnchorObjectForAnimation(masterTemplate["TurnedFace3"], "Blowjob");
			hairSide2R.SetAnchorObjectForAnimation(masterTemplate["TurnedFace"], "Anal", "ReverseCowgirl");
			
			var hairSide3L:AnchoredElementBase = new AnchoredElementBase("HairSide3L", AnchoredElementBase.HAIRELEMENT);
			hairSide3L.AddNewDefinition(new PeachHairSide3LDef);
			hairSide3L.SetAnchorObjectForAnimation(masterTemplate["Face"], "Cowgirl", "LeanBack", "LeanForward", "Paizuri", "Swivel");
			hairSide3L.SetAnchorObjectForAnimation(masterTemplate["TurnedFace2"], "Grind", "SideRide");
			hairSide3L.SetAnchorObjectForAnimation(masterTemplate["TurnedFace3"], "Blowjob");
			hairSide3L.SetAnchorObjectForAnimation(masterTemplate["TurnedFace"], "Anal", "ReverseCowgirl");
			
			var hairSide3R:AnchoredElementBase = new AnchoredElementBase("HairSide3R", AnchoredElementBase.HAIRELEMENT);
			hairSide3R.AddNewDefinition(new PeachHairSide3RDef);
			hairSide3R.SetAnchorObjectForAnimation(masterTemplate["Face"], "Cowgirl", "LeanBack", "LeanForward", "Paizuri", "Swivel");
			hairSide3R.SetAnchorObjectForAnimation(masterTemplate["TurnedFace2"], "Grind", "SideRide");
			hairSide3R.SetAnchorObjectForAnimation(masterTemplate["TurnedFace3"], "Blowjob");
			hairSide3R.SetAnchorObjectForAnimation(masterTemplate["TurnedFace"], "Anal", "ReverseCowgirl");
			
			var hairBack:AnchoredElementBase = new AnchoredElementBase("HairBack", AnchoredElementBase.HAIRELEMENT);
			hairBack.AddNewDefinition(new PeachHairBackDef);
			hairBack.SetAnchorObjectForAnimation(masterTemplate["Face"], "Cowgirl", "LeanBack", "LeanForward", "Paizuri", "Swivel");
			hairBack.SetAnchorObjectForAnimation(masterTemplate["TurnedFace2"], "Grind", "SideRide");
			hairBack.SetAnchorObjectForAnimation(masterTemplate["TurnedFace3"], "Blowjob");
			hairBack.SetAnchorObjectForAnimation(masterTemplate["TurnedFace"], "Anal", "ReverseCowgirl");
			
			//masterTemplate.AddNewElementToTemplate(hairBack);
			/*masterTemplate.AddNewElementToTemplate(hairSideL);
			masterTemplate.AddNewElementToTemplate(hairSideR);
			masterTemplate.AddNewElementToTemplate(hairSide3L);
			masterTemplate.AddNewElementToTemplate(hairSide3R);
			masterTemplate.AddNewElementToTemplate(hairSide2L);
			masterTemplate.AddNewElementToTemplate(hairSide2R);
			masterTemplate.AddNewElementToTemplate(hairFront);	
			
			masterTemplate.AddNewElementToTemplate(hairFrontAngled);
			masterTemplate.AddNewElementToTemplate(hairFrontAngled2);*/
			
			menu = new ppppuMenu(masterTemplate);
			menu.ChangeSlidersToCharacterValues(currentCharacter);
			addChild(menu);
			
			charVoiceSystem = new SoundEffectSystem();
			
			SwitchCharacter(0);
			mainStage.play();
		}
		
		//The "heart beat" of the flash. Ran every frame to monitor and react to certain, often frame sensitive, events
		private function RunLoop(e:Event):void
		{
			var mainStageMC:MovieClip = (e.target as MovieClip);
			var frameNum:int = mainStageMC.currentFrame; //The current frame that the main stage is at.
			var animationFrame:int = ((frameNum -2) % 120) + 1; //The frame that an animation should be on. Animations are typically 120 frames / 4 seconds long
			if (animationFrame && animationFrame != lastPlayedFrame)
			{
				if (frameNum == flashStartFrame)
				{
					/*if (userSettings.firstTimeRun == true)
					{
						UpdateKeyBindsForHelpScreen();
						ToggleHelpScreen(); //Show the help screen
						characterManager.ToggleMenu();
						userSettings.firstTimeRun = false;
						settingsSaveFile.data.ppppuSettings = userSettings;
						settingsSaveFile.flush();
					}
					else
					{
						if (userSettings.showMenu)
						{
							characterManager.ToggleMenu();
						}
					}*/
					mainStage.CharacterLayer.visible = true;
					/*if (userSettings.showBackground == true)
					{
						mainStage.TransitionDiamondBG.visible = mainStage.OuterDiamondBG.visible = mainStage.InnerDiamondBG.visible = true;
					}*/
					mainStage.OuterDiamondBG.gotoAndPlay(animationFrame);
					mainStage.InnerDiamondBG.gotoAndPlay(animationFrame);
					mainStage.TransitionDiamondBG.gotoAndPlay(animationFrame);
					mainStage.BacklightBG.gotoAndPlay(animationFrame);
					masterTemplate.visible = true;
					//Go to the 
					SwitchTemplateAnimation(currentAnimationIndex);
					masterTemplate.PlayAnimation(animationFrame);
					
					//mainStage.setChildIndex(masterTemplate, mainStage.numChildren - 1);
				}
				masterTemplate.Update(/*animationFrame*/);
				//masterTemplate.UpdateAnchoredElements(); //Called by master template's update functions
				if (playSounds)
				{
					charVoiceSystem.Tick(animationFrame);
				}
				//Make sure the background movie clips stay synced after reaching the loop end point on the main stage
				if (frameNum == mainStageLoopStartFrame)
				{
					mainStage.OuterDiamondBG.gotoAndPlay(animationFrame);
					mainStage.InnerDiamondBG.gotoAndPlay(animationFrame);
					mainStage.TransitionDiamondBG.gotoAndPlay(animationFrame);
					mainStage.BacklightBG.gotoAndPlay(animationFrame);
				}
			}
			lastPlayedFrame = animationFrame;
		}
		
		/*Responsible for processing all the motion xmls detailed in an animationMotions file, creating tweenLite tweens from them,
		 * and finally creating a timeline from those tweens and storing it in a dictionary*/
		private function ProcessMotionStaticClass(motionClass:Class, template:DisplayObject):Vector.<TimelineMax>
		{
			
			//Create an instance of the animation motion class
			var animationMotionInstance:Object = new motionClass();
			
			var timelineVector:Vector.<TimelineMax>;// = new Vector.<TimelineMax>();
			var templateAnimation:TemplateBase = template as TemplateBase;
			
			if (templateAnimation == null)
			{
				trace("Template animation is null for processing Motion Class: " + motionClass); 
				return null;
			}
			
			var charName:String = animationMotionInstance.CharacterName; //Character the animation motion is for
			var animName:String = animationMotionInstance.AnimationName; //The type of animation template that the animation motion is for
			var layerInfo:String = animationMotionInstance.LayerInfo; //Contains information that is used to rearrange the depth of elements displayed.
			
			//LayerInfo was found, so process it
			if (layerInfo != null && layerInfo.length > 0)
			{
				//LayerInfo strings are in JSON format, which is parsed as an Object
				var layerInfoObject:Object = JSON.parse(layerInfo);
				//If the layer info dictionary for the character doesn't exist, create it.
				if (layerInfoDict[charName] == null) { layerInfoDict[charName] = new Dictionary(); }
				//Set the layer info for an animation of the character
				layerInfoDict[charName][animName] = layerInfoObject;
			}
			
			//Get the description of the animation motion class
			var jsonClassDescriber:DescribeTypeJSON = new DescribeTypeJSON();
			var motionClassDescription:Object = jsonClassDescriber.describeType(motionClass, DescribeTypeJSON.INCLUDE_VARIABLES | DescribeTypeJSON.INCLUDE_TRAITS | DescribeTypeJSON.INCLUDE_ITRAITS);
			
			//Get an array of the animation motion class' variables
			var varsInMotionClass:Array = motionClassDescription.traits.variables as Array;
			var currentVarInfo:Object;
			var objectClassNames:Vector.<String> = new Vector.<String>();
			
			//Create the timeline vector
			timelineVector = new Vector.<TimelineMax>();
			
			//Run through the variables array 
			for (var index:int = 0, length:int = varsInMotionClass.length; index < length; ++index)
			{
				//Get the information of the variable at the index
				currentVarInfo = varsInMotionClass[index];
				var currentVarName:String = currentVarInfo.name as String;
				
				//Get the actual instance of the variable from the instance of the animation motion created at the beginning of this function.
				var currentVariable:Object = animationMotionInstance[currentVarName];
				//Only care about the variable if it's a byte array
				if (currentVariable is ByteArray)
				{
					//Add the name of the element into the objectClassNames vector
					objectClassNames[objectClassNames.length] = currentVarName;
					if (currentVariable.length != 0)
					{
						//Deserialize the byte array into a vector of tween data objects
						var vectorOfTweenData:Vector.<Object> = currentVariable.readObject() as Vector.<Object>;
						
						var templateElement:DisplayObject = templateAnimation[currentVarName];
						

						//Declare the timeline for the tweens
						var timelineForMotion:TimelineMax = embedTweenDataConverter.CreateTimelineFromData(templateElement, vectorOfTweenData); 
						
						//Dictionary existance checking. Create a dictionary if the specified one doesn't exist.
						/*if (timelinesDict[charName] == null)
						{
							//Code in here is theoretically unreachable but keep it here until that is fully tested.
							CreateTimelineDictionaryForCharacter(charName);
							timelinesDict[charName] = new Dictionary();
						}
						if (timelinesDict[charName][animName] == null)
						{
							//Creates a dictionary in the charName dictionary that's contained in timelinesDict.
							timelinesDict[charName][animName] = new Dictionary();
						}*/
						
						if (timelineForMotion)
						{
							//Setting the timelines dictionary to contain the created time line.
							//timelinesDict[charName][animName][currentVarName] = timelineForMotion;
							//Adding the created timeline to timelineVector
							timelineVector[timelineVector.length] = timelineForMotion;
							//Tell the timeline to start paused, to help save on processing a little.
							//timelineForMotion.pause();
						}
					}
					else
					{
						trace("Warning! Tween data for element " + templateElement.name + " of animation " + animName + " was empty. Timeline was not constructed.");
					}
				}	
			}
			return timelineVector;
		}
		
		//Activated if a key is detected to be released. Sets the keys "down" status to false
		private function KeyReleaseCheck(keyEvent:KeyboardEvent):void
		{
			keyDownStatus[keyEvent.keyCode] = false;
		}
		
		/*Activated if a key is detected to be pressed and after processing logic, sets the keys "down" status to true. If this is the first 
		frame a key is detected to be down, perform the action related to that key, unless the random animation key is held down. Though 
		it was an unintentional oversight at first, people were amused by this, so it has been kept as a feature.*/
		private function KeyPressCheck(keyEvent:KeyboardEvent):void
		{
			//Check if the menus need input focus. If they do, then bail so there is no changes due to both this and the menu acting on the same input simultaneously.
			if (menu.MenuNeedsInputFocus()) { return; }
			
			var keyPressed:int = keyEvent.keyCode;

			if(keyDownStatus[keyPressed] == undefined || keyDownStatus[keyPressed] == false || (keyPressed == 48 || keyPressed == 96))
			{
				if((keyPressed == 48 || keyPressed == 96))
				{
					var randomAnimIndex:int = Math.floor(Math.random() * animationNameIndexes.length);
					SwitchTemplateAnimation(randomAnimIndex);
				}
				else if((!(49 > keyPressed) && !(keyPressed > 57)) ||  (!(97 > keyPressed) && !(keyPressed > 105)))
				{
					//keypress of 1 has a keycode of 49
					if(keyPressed > 96)
					{
						keyPressed = keyPressed - 48;
					}
					SwitchTemplateAnimation(keyPressed - 49);
				}
				
				if (keyPressed == Keyboard.Z)
				{
					/*currentCharacter = defaultCharacter;
					masterTemplate.ChangeHair(currentCharacter);
					masterTemplate.ChangeHeadwear(currentCharacter);
					masterTemplate.ChangeEarring(currentCharacter);
					
					//Lazy way of updating the timelines. In the future, create a method that will swap in the necessary timelines and use that
					SwitchTemplateAnimation(currentAnimationIndex);*/
				}
				if (keyPressed == Keyboard.Q)
				{
					masterTemplate.HairFront.ChangeDisplayedSprite(0);
				}
				else if (keyPressed == Keyboard.W)
				{
					masterTemplate["HairFront"].ChangeDisplayedSprite(1);
				}
				/*if (keyPressed == Keyboard.X)
				{
					currentCharacter = "Rosalina";
					masterTemplate.ChangeHair(currentCharacter);
					masterTemplate.ChangeHeadwear(currentCharacter);
					masterTemplate.ChangeEarring(currentCharacter);
					
					//Still using the lazy way of updating the timelines.
					SwitchTemplateAnimation(currentAnimationIndex);
				}*/
				//Debugger
				if (keyPressed == Keyboard.S)
				{
					mainStage.stop();
					mainStage.OuterDiamondBG.stop();
					mainStage.InnerDiamondBG.stop();
					mainStage.TransitionDiamondBG.stop();
					mainStage.BacklightBG.stop();
					masterTemplate.StopAnimation();
				}
				else if (keyPressed == Keyboard.R)
				{
					mainStage.play();
					mainStage.OuterDiamondBG.play();
					mainStage.InnerDiamondBG.play();
					mainStage.TransitionDiamondBG.play();
					mainStage.BacklightBG.play();
					masterTemplate.ResumePlayingAnimation();
				}
				else if (keyPressed == Keyboard.D)
				{
					masterTemplate.ToggleDebugModeText();
				}
				else if (keyPressed == Keyboard.F)
				{
					masterTemplate.ToggleHairVisibility();
				}
				else if (keyPressed == Keyboard.G)
				{
					masterTemplate.DEBUG_HairBackTesting();
				}
				else if (keyPressed == Keyboard.M)
				{
					masterTemplate.Mouth.ChangeExpression("Smile");
				}
				else if (keyPressed == Keyboard.N)
				{
					masterTemplate.Mouth.ChangeExpression("TearShape");
				}
				else if (keyPressed == Keyboard.O)
				{
					masterTemplate.Mouth.ChangeExpression("Oh");
				}
				else if (keyPressed == Keyboard.L)
				{
					var myTextLoader:URLLoader = new URLLoader();
					myTextLoader.addEventListener(Event.COMPLETE, mouthLoadTest);
					myTextLoader.addEventListener(IOErrorEvent.IO_ERROR, loadFail);
					myTextLoader.load(new URLRequest("MouthTest.txt"));
				}
				
			}
			if (keyPressed == Keyboard.LEFT)
			{
				mainStage.prevFrame();
				var frame:int = (mainStage.currentFrame -2) % 120 + 1;
				
				mainStage.OuterDiamondBG.gotoAndStop(frame);
				mainStage.InnerDiamondBG.gotoAndStop(frame);
				mainStage.TransitionDiamondBG.gotoAndStop(frame);
				mainStage.BacklightBG.gotoAndStop(frame);
				masterTemplate.PlayAnimation(frame);
				masterTemplate.StopAnimation();
			}
			else if (keyPressed == Keyboard.RIGHT)
			{
				mainStage.nextFrame();
				var frame:int = (mainStage.currentFrame -2) % 120 + 1;
				
				mainStage.OuterDiamondBG.gotoAndStop(frame);
				mainStage.InnerDiamondBG.gotoAndStop(frame);
				mainStage.TransitionDiamondBG.gotoAndStop(frame);
				mainStage.BacklightBG.gotoAndStop(frame);
				masterTemplate.PlayAnimation(frame);
				masterTemplate.StopAnimation();
			}
			if (keyPressed == Keyboard.UP)
			{
				ScaleFromCenter(mainStage.CharacterLayer, mainStage.CharacterLayer.scaleX + .05, mainStage.CharacterLayer.scaleY + .05);
			}
			else if (keyPressed == Keyboard.DOWN)
			{
				ScaleFromCenter(mainStage.CharacterLayer, mainStage.CharacterLayer.scaleX - .05, mainStage.CharacterLayer.scaleY - .05);
			}
			
			keyDownStatus[keyEvent.keyCode] = true;
		}
		
		//Switches to a templated animation of a specified name
		private function SwitchTemplateAnimation(animationIndex:uint):void
		{
			var animationName:String = animationNameIndexes[animationIndex];
			var currentCharacterName:String = currentCharacter.GetName();
			masterTemplate.currentAnimationName = animationName;

			
			if(!timelineLib.DoesBaseTimelinesForAnimationExist(animationIndex))
			{
				CreateTimelinesForCharacterAnimation(defaultCharacterName, animationIndex);
			}
			var defaultLayerInfo:Object = layerInfoDict[defaultCharacterName][animationName];
			var currentCharLayerInfo:Object=null;
			if (defaultCharacter != currentCharacter)
			{
				currentCharLayerInfo = layerInfoDict[currentCharacterName][animationName];
			}
			masterTemplate.SetElementDepthLayout(defaultLayerInfo);
			masterTemplate.ImmediantLayoutUpdate((mainStage.currentFrame -2) % 120 + 1);
			
			for (var index:uint = 0, length:uint = animationNameIndexes.length; index < length; ++index)
			{
				if (animationName == animationNameIndexes[index])
				{
					masterTemplate.ChangeBaseTimelinesUsed(index);
				}
			}
			
			
			if (currentCharacter != defaultCharacter)
			{
				if (!timelineLib.DoesCharacterSetExists(animationIndex, currentCharacter.GetID(), "Standard"))
				{
					CreateTimelinesForCharacterAnimation(currentCharacterName, animationIndex);
				}
				masterTemplate.AddTimelines(timelineLib.GetReplacementTimelinesToLibrary(animationIndex, currentCharacter.GetID(), "Standard"));
			}
			
			//Change the animation info
			masterTemplate.currentAnimationInfo = animInfoDict["Cowgirl"];
			
			//Sync the animation to the main stage's timeline (main stage's current frame - animation start frame % 120 + 1 to avoid setting it to frame 0)
			masterTemplate.PlayAnimation((mainStage.currentFrame -2) % 120 + 1);
			currentAnimationIndex = animationIndex;
			
		}
		
		/*Attempts to create timelines of a specified animation for the specified character.*/
		private function CreateTimelinesForCharacterAnimation(characterName:String, animationIndex:uint):void
		{
			//Reference to the class that has the embed motion xmls
			var animationMotion:Class = null;
			//Have to specify the full package path to the animation motion class
			var packagePath:String = "MotionXML." + characterName + ".";
			var fullClassPath:String;
			var animationName:String;
			
			//Iterate through all known animations and try to find their animationmotion class.
			if(animationIndex < animationNameIndexes.length)
			{
				animationName = animationNameIndexes[animationIndex];
				fullClassPath = packagePath + characterName + animationName + "Motions";
				//
				//try
				//{
					animationMotion = getDefinitionByName(fullClassPath) as Class;
				/*}
				catch (e:ReferenceError) //animation motion wasn't found
				{
					animationMotion = null;
					trace("Character " + characterName + " has no animation motion definition for animation: " + animationName);
				}*/
				//animation motion was found, now to process it
				if (animationMotion != null)
				{
					//Checks if the character name is Default. If so, also set these timelines to be the default timelines for the template
					if (characterName == defaultCharacterName)
					{
						//masterTemplate.SetDefaultTimelines(ProcessMotionStaticClass(animationMotion, masterTemplate), animationIndex);
						timelineLib.AddBaseTimelinesToLibrary(animationIndex, ProcessMotionStaticClass(animationMotion, masterTemplate));
					}
					else //Otherwise just add the timelines to the timelines dictionary, where they'll wait to be swapped in at a later time.
					{
						var charId:int = this.characterList.indexOf(characterName);
						//TODO: Make animation set name not be hard coded. 
						var animationSetName:String = "Standard";
						timelineLib.AddReplacementTimelinesToLibrary(animationIndex, charId, animationSetName,ProcessMotionStaticClass(animationMotion, masterTemplate));
					}
				}
			}
		}
		/*private function CreateTimelineDictionaryForCharacter(characterName:String):void
		{
			if (timelinesDict[characterName] === undefined)
			{
				timelinesDict[characterName] = new Dictionary();
			}
		}*/
		
		public function SwitchCharacter(charId:int):void
		{
			if (charId >= 0 && charId < characterList.length)
			{
				currentCharacter = characterList[charId];
				charVoiceSystem.ChangeCharacterVoiceSet(currentCharacter.GetVoiceSet());
				charVoiceSystem.ChangeCharacterVoiceChance(currentCharacter.GetVoicePlayChance());
				charVoiceSystem.ChangeCharacterVoiceCooldown(currentCharacter.GetVoiceCooldown());
				charVoiceSystem.ChangeCharacterVoiceRate(currentCharacter.GetVoicePlayRate());
				menu.ChangeSlidersToCharacterValues(currentCharacter);
			}
		}
		
		public function GetListOfCharacterNames():Vector.<String>
		{
			var charNameVector:Vector.<String> = new Vector.<String>();
			for (var i:int = 0, l:int = characterList.length; i < l; ++i)
			{
				charNameVector[i] = characterList[i].GetName();
			}
			return charNameVector;
		}
		
		public function GetListOfAnimationNames():Vector.<String>
		{
			return animationNameIndexes;
		}
		
		public function AddCharacter(characterClass:Class):void
		{
			var character:ppppuCharacter = new characterClass;
			character.SetID(characterList.length);
			characterList[characterList.length] = character;
		}
		
		private function ScaleFromCenter(dis:DisplayObjectContainer,sX:Number,sY:Number):void
		{
			var posX:Number = dis.x;
			var posY:Number = dis.y;
			var oldDisBounds:Rectangle = dis.getBounds(dis.parent);
			//dis.x =dis.y = 0;
			dis.scaleX = sX;
			dis.scaleY = sY;
			
			var newDisBounds:Rectangle = dis.getBounds(dis.parent);
			var xDisplacement:Number = newDisBounds.left - oldDisBounds.left;
			var yDisplacement:Number = newDisBounds.top - oldDisBounds.top;
			dis.x += xDisplacement;
			dis.y += yDisplacement;
		}
		
		private function mouthLoadTest(e:Event):void
		{
			/*var parser:ExpressionParser = new ExpressionParser();
			var expr:TimelineMax = parser.Parse(masterTemplate, masterTemplate.Mouth.ExpressionContainer, e.target.data as String);
			//var expr:TimelineMax = ExpressionParser.ParseExpression(masterTemplate, masterTemplate.Mouth.ExpressionContainer, e.target.data);
			masterTemplate.SetExpression(expr);*/
		}
		
		private function loadFail(e:IOErrorEvent):void
		{
			trace("Was unable to load file \"MouthTest.txt\"");
		}
	}

}