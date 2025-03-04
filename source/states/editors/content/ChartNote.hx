package states.editors.content;

class ChartNote {
    public var strumTime:Float;
    public var noteData:Int;
    public var holdLength:Float;
    public var noteType:String;

    public function fromMetaNote(n:MetaNote) {
        strumTime = n.strumTime;
        noteData = n.noteData;
        holdLength = n.sustainLength;
        noteType = n.noteType;
    }

    public function fromDynamic(n:Dynamic) {
        strumTime = n[0];
        noteData = n[1];
        holdLength = n[2];
        noteType = n[3];
    }

    public function toMetaNote():MetaNote {
        return new MetaNote(strumTime, noteData, [strumTime, noteData, holdLength, noteType]);
    }
}