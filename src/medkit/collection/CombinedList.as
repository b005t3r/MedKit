/**
 * User: booster
 * Date: 22/05/17
 * Time: 09:39
 */
package medkit.collection {
import medkit.collection.iterator.Iterator;
import medkit.collection.iterator.ListIterator;
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Equalable;
import medkit.object.ObjectInputStream;
import medkit.object.ObjectOutputStream;
import medkit.string.StringBuilder;

public class CombinedList implements List {
    private static var combinedListPool:Vector.<CombinedList> = new <CombinedList>[];

    /** Retrieves a CombinedList instance from the pool. */
    public static function getCombinedList():CombinedList {
        if (combinedListPool.length == 0)
            return new CombinedList();

        var rectangle:CombinedList = combinedListPool.pop();
        return rectangle;
    }

    /** Stores a CombinedList instance in the pool.
     *  Don't keep any references to the object after moving it to the pool! */
    public static function putCombinedList(list:CombinedList):void {
        if (list == null)
            throw new ArgumentError("cannot put back null");

        list.internalCollections.clear();
        list.internalTargets.clear();
        combinedListPool[combinedListPool.length] = list;
    }

    private var _internalTargets:List = new ArrayList();
    private var _internalCollections:List = new ArrayList();

    public function get internalTargets():List { return _internalTargets; }
    public function get internalCollections():List { return _internalCollections; }

    public function get first():* { return get(0); }
    public function get last():* { return getReversed(0); }

    public function get(index:int):* {
        CONFIG::dev {
            if(index < 0 || index >= size())
                throw new ArgumentError("index out of bounds: " + index);
        }

        var targetCount:int = _internalTargets.size();

        if(index < targetCount)
            return _internalTargets.get(index);

        index -= targetCount;

        var collectionCount:int = _internalCollections.size();
        for(var c:int = 0; c < collectionCount; ++c) {
            var list:List = _internalCollections.get(c);

            if(index >= list.size()) {
                index -= list.size();
                continue;
            }

            return list.get(index);
        }

        throw new Error("it's impossible to get here!");
    }

    public function getReversed(index:int):* { return get(size() - 1 - index); }
    public function indexToReversedIndex(index:int):int { return size() - 1 - index; }
    public function reversedIndexToIndex(reversedIndex:int):int { return size() - 1 - reversedIndex; }

    public function indexOf(o:*):int {
        var index:int = _internalTargets.indexOf(o);

        if(index >= 0)
            return index;

        var total:int = _internalTargets.size();

        var collectionCount:int = _internalCollections.size();
        for(var c:int = 0; c < collectionCount; ++c) {
            var list:List = _internalCollections.get(c);

            index = list.indexOf(o);

            if(index >= 0)
                return total + index;

            total += list.size();
        }

        return -1;
    }

    public function indexOfClass(c:Class):int {
        var index:int = _internalTargets.indexOfClass(c);

        if(index >= 0)
            return index;

        var total:int = _internalTargets.size();

        var collectionCount:int = _internalCollections.size();
        for(var col:int = 0; col < collectionCount; ++col) {
            var list:List = _internalCollections.get(col);

            index = list.indexOfClass(c);

            if(index >= 0)
                return total + index;

            total += list.size();
        }

        return -1;
    }

    public function lastIndexOf(o:*):int {
        var total:int = size();

        var collectionCount:int = _internalCollections.size();
        for(var c:int = collectionCount - 1; c >= 0; --c) {
            var list:List = _internalCollections.get(c);

            total -= list.size();

            var index:int = list.lastIndexOf(o);

            if(index >= 0)
                return total + index;
        }

        return _internalTargets.lastIndexOf(o);
    }

    public function lastIndexOfClass(c:Class):int {
        var total:int = size();

        var collectionCount:int = _internalCollections.size();
        for(var col:int = collectionCount - 1; col >= 0; --col) {
            var list:List = _internalCollections.get(col);

            total -= list.size();

            var index:int = list.lastIndexOfClass(c);

            if(index >= 0)
                return total + index;
        }

        return _internalTargets.lastIndexOfClass(c);
    }

    public function listIterator(index:int = 0):ListIterator { return new CombinedListIterator(this); }

    public function contains(o:*):Boolean { return indexOf(o) >= 0; }

    public function containsAll(c:Collection):Boolean {
        var it:Iterator = c.iterator();
        while(it.hasNext()) {
            var o:* = it.next();

            if(indexOf(o) < 0)
                return false;
        }

        return true;
    }

    public function isEmpty():Boolean { return false; }

    public function iterator():Iterator { return listIterator(0); }

    public function size():int {
        var total:int = _internalTargets.size();

        var count:int = _internalCollections.size();
        for(var i:int = 0; i < count; ++i) {
            var list:List = _internalCollections.get(i);

            total += list.size();
        }

        return total;
    }

    public function equals(object:Equalable):Boolean {
        if(object === this)
            return true;

        var list:List = object as List;

        if(list == null)
            return false;

        if(list.size() != size())
            return false;

        if(!containsAll(list))
            return false;

        return true;
    }

    public function toString():String {
        var i:Iterator = iterator();

        if(!i.hasNext())
            return "[]";

        var sb:StringBuilder = new StringBuilder();

        sb.append('[');

        while(true) {
            var e:* = i.next();

            sb.append(e === this ? "(this Collection)" : e);

            if(!i.hasNext())
                break;

            sb.append(", ");
        }

        return sb.append(']').toString();
    }

    public function hashCode():int { return _internalTargets.hashCode(); }
    public function clone(cloningContext:CloningContext = null):Cloneable { return this; }
    public function toArray():Array { throw new Error("operation not supported"); }
    public function addAt(index:int, o:*):void { throw new Error("operation not supported"); }
    public function addAllAt(index:int, c:Collection):Boolean { throw new Error("operation not supported"); }
    public function removeAt(index:int):* { throw new Error("operation not supported"); }
    public function set(index:int, o:*):* { throw new Error("operation not supported"); }
    public function swap(i:int, j:int):void { throw new Error("operation not supported"); }
    public function subList(fromIndex:int, toIndex:int):List { throw new Error("operation not supported"); }
    public function removeRange(fromIndex:int, toIndex:int):void { throw new Error("operation not supported"); }
    public function add(o:*):Boolean { throw new Error("operation not supported"); }
    public function addAll(c:Collection):Boolean { throw new Error("operation not supported"); }
    public function addArray(arr:Array):Boolean { throw new Error("operation not supported"); }
    public function clear():void { throw new Error("operation not supported"); }
    public function remove(o:*):Boolean { throw new Error("operation not supported"); }
    public function removeAll(c:Collection):Boolean { throw new Error("operation not supported"); }
    public function retainAll(c:Collection):Boolean { throw new Error("operation not supported"); }
    public function readObject(input:ObjectInputStream):void { throw new Error("operation not supported"); }
    public function writeObject(output:ObjectOutputStream):void { throw new Error("operation not supported"); }
}
}
