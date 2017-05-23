/**
 * User: booster
 * Date: 22/10/16
 * Time: 11:58
 */
package medkit.collection {
import medkit.collection.iterator.ListIterator;

public class CombinedListIterator implements ListIterator {
    private var list:CombinedList;
    private var cursor:int;
    private var lastRet:int;

    public function CombinedListIterator(list:CombinedList) {
        this.list = list;
        cursor = 0;
        lastRet = -1;
    }

    public function next():* {
        var i:int = cursor;
        var next:* = list.get(i);
        lastRet = i;
        cursor = i + 1;

        return next;
    }

    public function previous():* {
        var i:int = cursor - 1;
        var previous:* = list.get(i);
        lastRet = cursor = i;

        return previous;
    }

    public function hasNext():Boolean { return cursor != list.size(); }
    public function hasPrevious():Boolean { return cursor != 0; }
    public function nextIndex():int { return cursor; }
    public function previousIndex():int { return cursor - 1; }

    public function remove():void { throw new Error("unsupported operation"); }
    public function set(e:*):void { throw new Error("unsupported operation"); }
    public function add(e:*):void { throw new Error("unsupported operation"); }
}
}
