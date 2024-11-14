package debug;

import openfl.display.Sprite;

class FPSBg extends Sprite
{
	var bgCard:Sprite;
    var isShow:Bool = false;
    public function new()
    {
        super();

		bgCard = new Sprite();
		bgCard.graphics.beginFill(0x000000, 0.5);
		bgCard.graphics.drawRect(0, 0, 300, 55);
		bgCard.graphics.endFill();
		addChild(bgCard);
    }
}