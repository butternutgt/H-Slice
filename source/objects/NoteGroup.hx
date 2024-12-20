package objects;

import objects.Note.CastNote;

class NoteGroup extends FlxTypedGroup<Note>
{
    public var pool:Array<Note> = [];
    var _ecyc_e:Note = new Note();
    var index:Int = -1;
    var living:Int = 0;

    public function new() {
        super();
    }

    public function spawnNote(castNote:CastNote, ?oldNote:Note) {
        index = pool.lastIndexOf(null);
        if (index >= 0) {
            _ecyc_e = pool[index];
            pool[index] = null;
        } else {
            _ecyc_e.exists = false;
            _ecyc_e.recycleNote(castNote, oldNote);
            add(_ecyc_e);
        }
        return _ecyc_e;
    }

    public function debugInfo():Array<Float> {
        living = 0;
        for (obj in pool) {
            if (obj != null) ++living;
        }
        return [living, length, (living * 100.0 / Math.max(length, 1))];
    }
}