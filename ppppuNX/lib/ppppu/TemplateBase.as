package ppppu 
{
	import com.greensock.TimelineLite;
	import com.greensock.TimelineMax;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	//import EyeContainer;
	//import MouthContainer;
	/**
	 * ...
	 * @author 
	 */
	public dynamic class TemplateBase extends MovieClip
	{
		/*Master timeline for the template animation. Contains all the timelines for parts of the animation that are 
		 * controlled  by series of tweens defined by a motion xml.*/
		private var masterTimeline:TimelineLite = new TimelineLite( { useFrames:true, smoothChildTiming:true, paused:true } );
		//Master template version this array contains arrays of timelines. To access the index of the appropriate animation, refer to the animationNameIndexes array in ppppuCore.
		private var defaultTimelines:Vector.<Vector.<TimelineMax>> = new Vector.<Vector.<TimelineMax>>();
		
		private var customElementsList:Vector.<AnchoredElementBase> = new Vector.<AnchoredElementBase>();
		public var currentAnimationName:String = "None";
		
		//An Object that contains a number of depth layout change Objects for specified frames of the current animation.
		private var currentAnimationElementDepthLayout:Object;
		//The element depth layout for the latest frame based depth change of the animation.
		private var latestFrameDepthLayout:Object;
		private var elementDepthLayoutChangeFrames:Array;
		
		/*public var EyeL:EyeContainer;
		public var EyeR:EyeContainer;*/
		public var EarringL:EarringContainer;
		public var EarringR:EarringContainer;
		public var Headwear:HeadwearContainer;
		public var Mouth:MouthContainer;
		/*public var HairBack:HairBackContainer;
		public var HairSideL:BaseHairSide;
		public var HairSideR:BaseHairSide;
		public var HairSide2L:BaseHairSide2;
		public var HairSide2R:BaseHairSide2;
		public var HairSide3L:BaseHairSide3;
		public var HairSide3R:BaseHairSide3;
		public var HairFront:BaseHairFront;
		public var HairFrontAngled:BaseFrontAngledHair;
		public var HairFrontAngled2:BaseFrontAngled2Hair;*/
		public var LowerLegL:LowerLegContainer;
		public var LowerLegR:LowerLegContainer;
		public var EarL:MovieClip;
		public var EarR:MovieClip;
		public var EyeL:EyeContainer;
		public var EyeR:EyeContainer;
		
		//private var millisecPerFrame:Number;
		/*public var HairFront:BaseHairFront;*/
		
		public var customSkinElements:Vector.<AnchoredElementBase> = new Vector.<AnchoredElementBase>();
		public var customHairElements:Vector.<AnchoredElementBase> = new Vector.<AnchoredElementBase>();
		
		public function TemplateBase()
		{
			//addEventListener(Event.ADDED_TO_STAGE, StageSetup);
			SetupEyeContainer(EyeL);
			SetupEyeContainer(EyeR);
			if (EarL) { EarL.Element.gotoAndStop(1); EarL.Element.SkinGradient.gotoAndStop(1); EarL.Element.Lines.gotoAndStop(1); }
			if(EarR) {EarR.Element.gotoAndStop(1); EarR.Element.SkinGradient.gotoAndStop(1); EarR.Element.Lines.gotoAndStop(1);}
			EarringL.Element.gotoAndStop(1);
			EarringR.Element.gotoAndStop(1);
			Mouth.MouthBase.gotoAndStop(1);
			Mouth.LipsColor.gotoAndStop(1);
			Mouth.LipsHighlight.gotoAndStop(1);
			Mouth.Tongue.Element.gotoAndStop(1);
			Mouth.Tongue.visible = false;
			Headwear.Element.gotoAndStop(1);
			//SetupHair();
			if(LowerLegL) LowerLegL.Element.Color.gotoAndStop(1);
			if(LowerLegR) LowerLegR.Element.Color.gotoAndStop(1);
		}
		
		//Used to obtain the time spent per frame for the flash.
		/*private function StageSetup(e:Event):void
		{
			millisecPerFrame = 1000.0 / stage.frameRate;
			removeEventListener(Event.ADDED_TO_STAGE, StageSetup);
		}*/
		public function AddNewElementToTemplate(element:AnchoredElementBase):void
		{
			if (element)
			{
				//Add the object to the display object list
				addChild(element);
				//Add a property for the element.
				this[element.name] = element;
				//Add the element to the custom elements list. This is for updating purposes.
				customElementsList[customElementsList.length] = element;
				if (element.type == AnchoredElementBase.HAIRELEMENT)
				{
					customHairElements[customHairElements.length] = element;
				}
			}
		}
		
		/*Function that tests if there is a element depth layout change that it to occur on the specified frame and if so, start using
		 * that layout. Should be called every frame.*/
		public function Update(animFrame:int):void
		{
			var depthChangeIndex:int = elementDepthLayoutChangeFrames.indexOf("F"+animFrame);
			if (depthChangeIndex != -1)
			{
				//var currentFrameDepthLayout:Object = currentElementDepthLayout.("F" + animFrame);
				latestFrameDepthLayout = currentAnimationElementDepthLayout[elementDepthLayoutChangeFrames[depthChangeIndex]];
				ChangeElementDepths(latestFrameDepthLayout);
			}
		}
		
		/*Modifies the elements depth layout to match the latest layout that should be used. For example, if an animation has 3 layout changes
		 * at frame 1, 34 and 90 and there is a switch to this animation on the 89th frame, the layout for the 34th frame will be used. 
		 * This function should be called when the animation is switched*/
		public function ImmediantLayoutUpdate(animFrame:int):void
		{
			//Start at the end and work backwards
			for (var i:int = elementDepthLayoutChangeFrames.length - 1; i >= 0; --i)
			{
				var frame:String = elementDepthLayoutChangeFrames[i];
				frame = frame.substring(1);
				var depthChangeFrame:int = parseInt(frame, 10);
				if (animFrame >= depthChangeFrame)
				{
					latestFrameDepthLayout = currentAnimationElementDepthLayout[elementDepthLayoutChangeFrames[i]];
					ChangeElementDepths(latestFrameDepthLayout);
				}
			}
		}
		
		public function ChangeElementDepths(depthLayout:Object):void
		{
			var templateChildrenCount:uint = numChildren;
			var templateElements:Vector.<DisplayObject> = new Vector.<DisplayObject>(templateChildrenCount);
			var ShaftMask:DisplayObject = null, Shaft:DisplayObject = null, HeadMask:DisplayObject = null, Head:DisplayObject = null;
			for (var i:uint = 0; i < templateChildrenCount; ++i)
			{
				templateElements[i] = getChildAt(i);
			}
			var sortedDepthElements:Array = new Array();
			for (var childIndex:uint = 0; childIndex < templateChildrenCount; ++childIndex)
			{
				var element:DisplayObject = templateElements[childIndex];
				element.visible = false;
				var elementName:String = element.name;

				if (elementName in depthLayout)
				{	
					sortedDepthElements[depthLayout[elementName]] = element;
					//Mask checking
					
					//Shaft
					if (elementName.indexOf("PenisShaft") != -1 && elementName.indexOf("Mask") != -1)
					{
						ShaftMask = element;
					}
					else if (elementName.indexOf("PenisShaft") != -1)
					{
						Shaft = element;
					}
					
					//Head
					if (elementName.indexOf("PenisHead") != -1 && elementName.indexOf("Mask") != -1)
					{
						HeadMask = element;
					}
					else if (elementName.indexOf("PenisHead") != -1)
					{
						Head = element;
					}
				}
			}
			
			//With the base list sorted, now custom elements can be added.
			var sortedCustomHairElements:Vector.<AnchoredElementBase> = customHairElements.sort(Helper_SortCustomElementDepthsFunc);
			var firstNegativeDepthElement:Boolean = true;
			var lastNegativeNumber:int = 0;
			//var 
			for (var customHairIndex:int = 0, customHairLength:int = customHairElements.length; customHairIndex < customHairLength; ++customHairIndex)
			{
				var customElement:AnchoredElementBase = sortedCustomHairElements[customHairIndex];
				if (currentAnimationName in customElement.anchoredDisplayObjectDict)
				{
					//sortedCustomHairElements[customHairIndex];
					var hairDepthOffset:int = customElement.GetCurrentDepthOffset();
					
					var anchoredObjectIndex:int = sortedDepthElements.indexOf(this[customElement.GetAnchoredObjectName()]);
					var anchoredObjectBaseDepth:int = depthLayout[customElement.GetAnchoredObjectName()];
					var anchorDepthDiff:int = anchoredObjectIndex - anchoredObjectBaseDepth;
					var combinedDepth:int = hairDepthOffset + anchoredObjectIndex;
					if (hairDepthOffset < 0) 
					{
						combinedDepth -= anchorDepthDiff;
						//if(firstNegativeDepthElement)
						//{++combinedDepth; firstNegativeDepthElement = false; }
					}
					sortedDepthElements.splice(combinedDepth, 0, customElement);
				}
				//First, sort the custom hair elements by their depth offsets
				/*var customElement:AnchoredElementBase = customHairElements[customHairIndex];
				if (currentAnimationName in customElement.anchoredDisplayObjectDict)
				{
					if (sortedCustomHairElements.length == 0)
					{
						sortedCustomHairElements[sortedCustomHairElements.length] = customElement;
					}
					else
					{
						if(customElement.GetCurrentDepthOffset() > 
					}
				}*/
				
				//var customElement:AnchoredElementBase = customHairElements[customHairIndex];
				/*if (currentAnimationName in customElement.anchoredDisplayObjectDict)
				{
					var hairDepthOffset:int = customElement.GetCurrentDepthOffset();
					var anchoredObjectIndex:int = sortedDepthElements.indexOf(this[customElement.GetAnchoredObjectName()]);
					//trace(anchoredObjectIndex);
					var anchoredObjectBaseDepth:int = depthLayout[customElement.GetAnchoredObjectName()];
					//var anchoredObjectCurrentDepth:int = getChildIndex(this[customElement.GetAnchoredObjectName()]);
					//var anchorDepthDiff:int = anchoredObjectCurrentDepth - anchoredObjectBaseDepth;
					//var combinedDepth:int = hairDepthOffset + anchoredObjectCurrentDepth + anchorDepthDiff;
					var combinedDepth:int = hairDepthOffset + anchoredObjectIndex + ( anchoredObjectIndex - anchoredObjectBaseDepth);
					sortedDepthElements.splice(combinedDepth, 0, customElement);
				}*/
				//customHairElements[customHairIndex].ChangeLayerDepth(latestFrameDepthLayout);
			}
			//orig version
			/*for (var customHairIndex:int = 0, customHairLength:int = customHairElements.length; customHairIndex < customHairLength; ++customHairIndex)
			{
				//First, sort the custom hair elements by their depth offsets
				
				var customElement:AnchoredElementBase = customHairElements[customHairIndex];
				if (currentAnimationName in customElement.anchoredDisplayObjectDict)
				{
					var hairDepthOffset:int = customElement.GetCurrentDepthOffset();
					var anchoredObjectIndex:int = sortedDepthElements.indexOf(this[customElement.GetAnchoredObjectName()]);
					//trace(anchoredObjectIndex);
					var anchoredObjectBaseDepth:int = depthLayout[customElement.GetAnchoredObjectName()];
					//var anchoredObjectCurrentDepth:int = getChildIndex(this[customElement.GetAnchoredObjectName()]);
					//var anchorDepthDiff:int = anchoredObjectCurrentDepth - anchoredObjectBaseDepth;
					//var combinedDepth:int = hairDepthOffset + anchoredObjectCurrentDepth + anchorDepthDiff;
					var combinedDepth:int = hairDepthOffset + anchoredObjectIndex + ( anchoredObjectIndex - anchoredObjectBaseDepth);
					sortedDepthElements.splice(combinedDepth, 0, customElement);
				}
				//customHairElements[customHairIndex].ChangeLayerDepth(latestFrameDepthLayout);
			}*/
			
			var topDepth:int = templateChildrenCount - 1;
			for (var arrayPosition:int = 0, length:int = sortedDepthElements.length; arrayPosition < length; ++arrayPosition )
			{
				if(sortedDepthElements[arrayPosition])
				{
					setChildIndex(sortedDepthElements[arrayPosition], numChildren - 1);
					(sortedDepthElements[arrayPosition] as Sprite).visible = true;
					trace(arrayPosition + ": " + sortedDepthElements[arrayPosition].name);
				}
			}
			//version for layer info json files that used 0 as front 
			/*for (var arrayPosition:int = sortedDepthElements.length -1; arrayPosition >= 0; --arrayPosition )
			{
				if(sortedDepthElements[arrayPosition])
				{
					setChildIndex(sortedDepthElements[arrayPosition], topDepth - arrayPosition);
					(sortedDepthElements[arrayPosition] as Sprite).visible = true;
				}
			}*/
			
			
			//If a mask-masked pair exists, set the mask. Otherwise, nullify the mask.
			if (Shaft && ShaftMask)
			{
				Shaft.mask = ShaftMask;
			}
			else if (Shaft && !ShaftMask)
			{
				Shaft.mask = null;
			}
			
			if (Head && HeadMask)
			{
				Head.mask = HeadMask;
			}
			else if (Head && !HeadMask)
			{
				Head.mask = null;
			}
		}
		
		public function UpdateAnchoredElements():void
		{
			for (var i:int = 0, l:int = customElementsList.length; i < l; ++i )
			{
				customElementsList[i].Update();
			}
		}
		
		/*private function SetupHair():void
		{
			HairBack.Element.gotoAndStop(1);
			HairSideL.gotoAndStop(1);
			HairSideR.gotoAndStop(1);
			HairSide2L.gotoAndStop(1);
			HairSide2R.gotoAndStop(1);
			HairSide3L.gotoAndStop(1);
			HairSide3R.gotoAndStop(1);
			if (HairFront)
			{
				HairFront.gotoAndStop(1);
			}
			HairFrontAngled.gotoAndStop(1);
			HairFrontAngled2.gotoAndStop(1);
		}*/
		
		/*public function ChangeHair(character:String):void
		{
			HairBack.Element.gotoAndStop(character);
			HairSideL.gotoAndStop(character);
			HairSideR.gotoAndStop(character);
			HairSide2L.gotoAndStop(character);
			HairSide2R.gotoAndStop(character);
			HairSide3L.gotoAndStop(character);
			HairSide3R.gotoAndStop(character);
			if (HairFront)
			{
				HairFront.gotoAndStop(character);
			}
			HairFrontAngled.gotoAndStop(character);
			HairFrontAngled2.gotoAndStop(character);
		}*/
		
		public function ChangeHeadwear(character:String):void
		{
			Headwear.Element.gotoAndStop(character);
		}
		
		public function ChangeEarring(character:String):void
		{
			EarringL.Element.gotoAndStop(character);
			EarringR.Element.gotoAndStop(character);
		}
		
		//Initializes the eye container to go to it's default look (and to stop cycling through the other possible visual it can take.)
		private function SetupEyeContainer(EyeC:EyeContainer):void
		{
			EyeC.Element.EyebrowSettings.gotoAndStop(1);
			EyeC.Element.EyebrowSettings.Eyebrow.gotoAndStop(1);
			EyeC.Element.EyelashSettings.gotoAndStop(1);
			EyeC.Element.EyelashSettings.Eyelash.gotoAndStop(1);
			EyeC.Element.EyeMaskSettings.EyeMask.gotoAndStop(1);
			EyeC.Element.EyelidSettings.gotoAndStop(1);
			EyeC.Element.EyelidSettings.Eyelid.gotoAndStop(1);
			EyeC.Element.EyelashSettings.Eyelash.EyelashTypes.gotoAndStop(1);
			EyeC.Element.InnerEyeSettings.gotoAndStop(1);
			EyeC.Element.InnerEyeSettings.InnerEye.gotoAndStop(1);
			EyeC.Element.InnerEyeSettings.InnerEye.Highlight.gotoAndStop(1);
			EyeC.Element.InnerEyeSettings.InnerEye.Pupil.gotoAndStop(1);
			EyeC.Element.InnerEyeSettings.InnerEye.Iris.gotoAndStop(1);
			EyeC.Element.ScleraSettings.gotoAndStop(1);
			EyeC.Element.ScleraSettings.Sclera.gotoAndStop(1);
		}
		
		/*Sets the vector of timelines passed to it as the default timelines used for a specified animation.
		For reference, ppppuCore's animationNameIndexes variable details which index is linked to a specific animation name*/
		public function SetDefaultTimelines(defTimelines:Vector.<TimelineMax>, animationIndex:uint):void
		{
			//Quick check to make sure that there are timelines in the vector
			if (defTimelines.length > 0)
			{
				for (var i:int = 0, l:int = animationIndex; i < l; ++i)
				{
					if (animationIndex > defaultTimelines.length)
					{
						defaultTimelines.push(null);
					}
				}
				defaultTimelines[animationIndex] = defTimelines;
			}
		}
		
		//Starts playing the currently set animation at a specified frame.
		public function PlayAnimation(startAtFrame:uint):void
		{
			--startAtFrame;
			masterTimeline.play(startAtFrame);
			//Get all timelines currently used
			var childTimelines:Array = masterTimeline.getChildren(!true, false);
			for (var i:int = 0, l:int = childTimelines.length; i < l; ++i)
			{
				//Tell the child timeline to play at the specified time
				(childTimelines[i] as TimelineMax).play(startAtFrame);
			}
			
			//masterTimeline.
			//The timelines and tweens are time based, so there needs to be a conversion from frame to time (in milliseconds)
			//masterTimeline.play((startAtFrame * millisecPerFrame) / 1000.0);
			//Get all timelines currently used
			/*var childTimelines:Array = masterTimeline.getChildren(!true, false);
			for (var i:int = 0, l:int = childTimelines.length; i < l; ++i)
			{
				//Tell the child timeline to play at the specified time
				(childTimelines[i] as TimelineMax).play((startAtFrame * millisecPerFrame)/1000.0 );
			}*/
		}
		
		public function ResumePlayingAnimation():void
		{
			masterTimeline.play();
			//Get all timelines currently used
			var childTimelines:Array = masterTimeline.getChildren(!true, false);
			for (var i:int = 0, l:int = childTimelines.length; i < l; ++i)
			{
				//Tell the child timeline to play at the specified time
				(childTimelines[i] as TimelineMax).play();
			}
		}
		
		public function JumpToFrameAnimation(startAtFrame:uint):void
		{
			--startAtFrame;
			var time:int = startAtFrame; //useFrames version
			if (masterTimeline.paused() == false)
			{
				masterTimeline.seek(time);
			}
			else
			{
				var childTimelines:Array = masterTimeline.getChildren(true, false);
				//var time:Number = ((startAtFrame * millisecPerFrame) / 1000.0)+0.01;
				
				for (var i:int = 0, l:int = childTimelines.length; i < l; ++i)
				{
					(childTimelines[i] as TimelineMax).seek(time);
				}
			}
			//trace(time);
		}
		
		/*Pauses the animation. Currently used, it's just here in case there is a time where the animation needs to be paused. 
		Might be useful when character editing facilities are better and they need a still to look at.*/
		public function StopAnimation():void
		{
			masterTimeline.stop();
			/*var childTimelines:Array = masterTimeline.getChildren(true, false);
			for (var i:int = 0, l:int = childTimelines.length; i < l; ++i)
			{
				(childTimelines[i] as TimelineLite).stop();
			}*/
		}
		
		/*Removes all currently active timelines and adds the default timelines for a specified animation by it's index number.*/
		public function ChangeDefaultTimelinesUsed(animationIndex:uint):void
		{
			if (animationIndex < defaultTimelines.length)
			{
				ClearTimelines();
				AddTimelines(defaultTimelines[animationIndex]);
			}
		}
		
		/*public function ResetToDefaultTimelines()
		{
			masterTimeline.clear();
			masterTimeline.add(defaultTimelines);
			//UpdateTimelines();
		}*/
		
		/*Removes all children timelines, which control the various body part elements of the master template, from the master timeline.
		 Additionally, these body part elements are set to be invisible. */
		public function ClearTimelines():void
		{
			//Get the timelines used currently
			var childTimelines:Array = masterTimeline.getChildren(true, false);
			var currentChildTimeline:TimelineMax;
			//Iterate through all the timelines 
			for (var i:int = 0, l:int = childTimelines.length; i < l; ++i)
			{
				currentChildTimeline = childTimelines[i] as TimelineMax;
				//The element that the timeline controls is to become invisible.
				//TODO: Test if it is more efficient, performance wise, to remove the element from the master template.
				(currentChildTimeline.data.targetElement as DisplayObject).visible = false;
			}
			//Remove the array of timelines from the master timeline, leaving it clear for another animation.
			masterTimeline.remove(childTimelines);
		}
		
		//Adds the timelines contained in a vector to the master timeline.
		public function AddTimelines(timelinesToAdd:Vector.<TimelineMax>):void
		{
			for (var i:uint = 0, l:uint = timelinesToAdd.length; i < l; ++i)
			{
				AddTimeline(timelinesToAdd[i] as TimelineMax);
				//trace(i + ": " + timelinesToAdd[i].data.targetElement.name )
			}
		}
		
		//Adds a specified Timeline to the master timeline.
		public function AddTimeline(tlToAdd:TimelineMax):void
		{
			//If the timeline to add is null, return out the function.
			if (tlToAdd == null) { return; }
			
			//The display object that the timeline controls
			var timelineDisplayObject:DisplayObject = tlToAdd.data.targetElement as DisplayObject;
			//Get the name of the element that the timeline controls
			var timelineForPart:String = timelineDisplayObject.name;
			//Make the display object visible
			timelineDisplayObject.visible = true;
			var currentFrame:int = this.currentFrame;
			
			if (timelineForPart)
			{
				//Check to see if the master timeline already has a nested timeline for the specified display object.
				//If it does, then replace it. Otherwise, add it.
				
				//Get all active timelines
				var childTimelines:Array = masterTimeline.getChildren(true, false);
				var childTlForPart:String;
				var childTimeline:TimelineMax;
				//Iterating through the active timelines array.
				for (var i:int = 0, l:int = childTimelines.length; i < l; ++i)
				{
					childTimeline = childTimelines[i] as TimelineMax;
					if (childTimeline)
					{
						childTlForPart = childTimeline.data.targetElement.name as String;
						if (timelineForPart == childTlForPart)
						{
							//Match was found, so replace the match with tlToAdd.
							ReplaceTimeline(childTimeline, tlToAdd);
							return; //Finished, so return to exit out the function early. 
						}
					}
				}
				//Looked through all the timelines nested in the master timeline and there were no matches for tlToAdd to override.
				masterTimeline.add(tlToAdd);
				//tlToAdd.seek(this.currentFrame);
				//tlToAdd.seek(((((this.parent as MovieClip).currentFrame-2) % 120) * millisecPerFrame) / 1000.0);
			}
		}
		
		//Replaces a specified timeline with another and then sets the newly added timeline to the frame that the removed one was on.
		public function ReplaceTimeline(tlToRemove:TimelineMax, tlToAdd:TimelineMax):void
		{
			if (tlToRemove != tlToAdd)
			{
				masterTimeline.remove(tlToRemove);
				masterTimeline.add(tlToAdd);
				//tlToAdd.seek(this.currentFrame);
				//tlToAdd.seek(((((this.parent as MovieClip).currentFrame-2) % 120) * millisecPerFrame) / 1000.0);
			}
		}
		
		public function SetElementDepthLayout(layout:Object):void
		{
			
			elementDepthLayoutChangeFrames  = new Array();
			for(var index:String in layout)
			{
				elementDepthLayoutChangeFrames[elementDepthLayoutChangeFrames.length] = index;
			}
			currentAnimationElementDepthLayout = layout;
			
		}
		//public function GetName():String{return this.name}
		
		/*public function TemplateBase() 
		{
			//EyeL.gotoAndStop(1);
			//EyeR.gotoAndStop(1);
			Mouth.gotoAndStop(1);
		}*/
		
		/*public function OnAnimationRestart()
		{
			EyeL.ResetInitialTransforms();
			EyeR.ResetInitialTransforms();
		}*/
		
		private function Helper_SortCustomElementDepthsFunc(elementOne:AnchoredElementBase, elementTwo:AnchoredElementBase):int
		{
			var eOneDepth:int = elementOne.GetCurrentDepthOffset(); 
			var eTwoDepth:int = elementTwo.GetCurrentDepthOffset();
			
			if (eOneDepth < eTwoDepth){return -1;}
			else if (eOneDepth > eTwoDepth){return 1;}
			else { return 0;}
		}
		
	}

}