package CharacterHair 
{
	import ppppu.HairDefinition;
	import flash.geom.Point;
	/**
	 * ...
	 * @author 
	 */
	public class PeachHairSide3LDef extends HairDefinition 
	{
		
		public function PeachHairSide3LDef() 
		{
			super();
			//mySprite = new PeachHairSide3();
			SetSprite(new PeachHairSide3());
			SetInitialMatrix(9.5, 9.5);
			
			pairedCharacter = "Peach";
			
			SetScaleFactors([1.029, .6086], "Cowgirl", "Swivel", "LeanBack", "LeanForward", "Paizuri");
			//SetAttachPoints(new Point(-34.975 - 15, 19.25 - 3.5), "Cowgirl", "Swivel", "LeanBack", "LeanForward", "Paizuri");
			SetAttachPoints(new Point(-43.45+8, -54.95), "Cowgirl", "Swivel", "LeanBack", "LeanForward", "Paizuri");
			
			SetScaleFactors([.377, .538], "Anal", "ReverseCowgirl");
			SetAttachPoints(new Point(98.85, 102.8), "Anal", "ReverseCowgirl");
			
			SetScaleFactors([.3059, .552], "SideRide", "Grind");
			SetAttachPoints(new Point(-41.4, 135.25), "SideRide", "Grind");
			
			scaleFactors["Blowjob"] = [.347, .588];
			attachPoints["Blowjob"] = new Point(38.5, 154.5);
			
			depthOffsets["Cowgirl"] = -3;
		}
		
	}

}