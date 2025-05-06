package objects;

import haxe.ds.ArraySort;
import objects.Note.CastNote;

class NoteGroup extends FlxTypedGroup<Note>
{
    var pool:Array<Note> = [];
    var poolAvail:Array<Bool> = [];
    var _ecyc_e:Note;
    var living:Int = 0;
    
    // for sorting
    var sortArr:Array<Note> = [];
    var indexArr:Array<Int> = [];
    var range:Int = 0;

    public function push(n:Note) {
        pool.push(n);
    }

    public function spawnNote(castNote:CastNote, ?oldNote:Note) {
        if (pool.length > 0) {
            _ecyc_e = pool.pop();
            _ecyc_e.exists = true;
        } else {
            _ecyc_e = null;
            _ecyc_e = new Note();
            members.push(_ecyc_e);
            ++length;
        }
        return _ecyc_e.recycleNote(castNote, oldNote);
    }

    override function update(elapsed:Float) {
		if (PlayState.inPlayState && PlayState.instance.cpuControlled) return;
        super.update(elapsed);
    }

    public function fasterSort(reverse:Bool = false) {
        // sortArr = members.filter(note -> note.visible);
        range = 0;
        for (i => note in members) {
            if (note.visible) {
                sortArr[range] = note;
                indexArr[range++] = i;
            }
        }

        if (sortArr.length > range) {
            sortArr.resize(range);
            indexArr.resize(range);
        }
        
        // ???
        // sortArr.sort((a,b) -> reverse ? FlxMath.signOf(a.distance - b.distance) : FlxMath.signOf(b.distance - a.distance));
        // indexArr.sort((a,b) -> reverse ? b-a : a-b);

        // Merge sort
        ArraySort.sort(sortArr, (a,b) -> noteSort(a, b, reverse));
        ArraySort.sort(indexArr, (a,b) -> reverse ? b-a : a-b);

        for (index => i in indexArr) members[i] = sortArr[index];
    }

    public static function noteSort(a:Note, b:Note, reverse:Bool = false):Int {
        if (a.distance != b.distance) 
            return FlxMath.signOf(reverse ? b.distance - a.distance : a.distance - b.distance);
        else if (a.isSustainNote != b.isSustainNote) {
            return a.isSustainNote ? -1 : 1;
        } else return 0;
    }

    public function debugInfo():Array<Float> {
        living = countLiving();
        return [living, length, living * 100.0 / Math.max(length, 1), poolAvail.length];
    }
}