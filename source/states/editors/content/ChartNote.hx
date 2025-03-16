package states.editors.content;

import states.editors.content.MetaNote.EventMetaNote;

class ChartNote {
    public var strumTime:Float;
    public var noteData:Int;
    public var holdLength:Float;
    public var noteType:String;

    public function new() {
        strumTime = 0;
        noteData = 0;
        holdLength = 0;
        noteType = null;
    }

    public function fromMetaNote(n:MetaNote) {
        strumTime = n.strumTime;
        noteData = n.noteData;
        holdLength = n.sustainLength;
        noteType = n.noteType;
    }

    public function fromDynamic(n:Array<Dynamic>) {
        trace('given data: $n');
        strumTime = n[0] ?? 0;
        noteData = n[1] ?? 0;
        holdLength = n[2] ?? 0;
        noteType = n[3] ?? null;
    }

    public function toMetaNote():MetaNote {
        return new MetaNote(strumTime, noteData, [strumTime, noteData, holdLength, noteType]);
    }

    public function toDynamic():Array<Dynamic> {
        return [strumTime, noteData, [strumTime, noteData, holdLength, noteType]];
    }
}

class ChartEvent extends ChartNote{
    public var eventData:Dynamic;
    
    override public function new() {
        super();
        eventData = null;
        noteData = -1;
    }

    public function fromEventMetaNote(n:EventMetaNote) {
        strumTime = n.strumTime;
        eventData = n.songData;
        noteData = -1;
    }

    override public function fromDynamic(n:Array<Dynamic>) {
        trace('given data: $n');
        strumTime = n[0];
        eventData = n[1];
    }
    
    public function toEventMetaNote():EventMetaNote {
        return new EventMetaNote(strumTime, eventData);
    }

    override public function toDynamic():Array<Dynamic> {
        return [strumTime, eventData];
    }
}