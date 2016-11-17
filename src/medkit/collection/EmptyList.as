/**
 * User: booster
 * Date: 17/11/16
 * Time: 12:30
 */
package medkit.collection {
import medkit.collection.iterator.Iterator;
import medkit.collection.iterator.ListIterator;
import medkit.enum.Enum;
import medkit.object.Equalable;
import medkit.object.ObjectInputStream;
import medkit.object.ObjectOutputStream;

public class EmptyList extends Enum implements List {
    { initEnums(EmptyList); }

    public static const Instance:EmptyList = new EmptyList();

    public function indexOf(o:*):int { return -1; }
    public function indexOfClass(c:Class):int { return -1; }
    public function lastIndexOf(o:*):int { return -1; }
    public function lastIndexOfClass(c:Class):int { return -1; }

    public function listIterator(index:int = 0):ListIterator { return index == 0 ? new EmptyListIterator() : throwEmptyListError(); }

    public function subList(fromIndex:int, toIndex:int):List { return Instance; }

    public function contains(o:*):Boolean { return false; }
    public function containsAll(c:Collection):Boolean { return false; }
    public function isEmpty():Boolean { return true; }
    public function iterator():Iterator { return listIterator(); }

    public function size():int { return 0; }
    public function toArray():Array { return []; }

    override public function equals(object:Equalable):Boolean {
        var collection:Collection = object as Collection;

        if(collection == null)
            return false;

        return collection.isEmpty();
    }

    // these are never called because it's an Enum
    public function readObject(input:ObjectInputStream):void { }
    public function writeObject(output:ObjectOutputStream):void { }

    public function get first():* { return throwEmptyListError(); }
    public function get last():* { return throwEmptyListError(); }
    public function addAt(index:int, o:*):void { throwEmptyListError(); }
    public function addAllAt(index:int, c:Collection):Boolean { return throwEmptyListError(); }
    public function indexToReversedIndex(index:int):int { return throwEmptyListError(); }
    public function reversedIndexToIndex(reversedIndex:int):int { return throwEmptyListError(); }
    public function get(index:int):* { return throwEmptyListError(); }
    public function getReversed(index:int):* { return throwEmptyListError(); }
    public function removeAt(index:int):* { return throwEmptyListError(); }
    public function set(index:int, o:*):* { return throwEmptyListError(); }
    public function removeRange(fromIndex:int, toIndex:int):void { throwEmptyListError(); }
    public function add(o:*):Boolean { return throwEmptyListError(); }
    public function addAll(c:Collection):Boolean { return throwEmptyListError(); }
    public function addArray(arr:Array):Boolean { return throwEmptyListError(); }
    public function clear():void { throwEmptyListError(); }
    public function remove(o:*):Boolean { return throwEmptyListError(); }
    public function removeAll(c:Collection):Boolean { return throwEmptyListError(); }
    public function retainAll(c:Collection):Boolean { return throwEmptyListError(); }

    private function throwEmptyListError():* { throw new Error("this list is empty"); }
}
}

import medkit.collection.iterator.ListIterator;

class EmptyListIterator implements ListIterator {
    public function hasNext():Boolean { return false; }
    public function hasPrevious():Boolean { return false; }

    public function previous():* { return throwEmptyListError(); }
    public function nextIndex():int { return throwEmptyListError(); }
    public function previousIndex():int { return throwEmptyListError(); }
    public function add(o:*):void { throwEmptyListError(); }
    public function set(o:*):void { throwEmptyListError(); }
    public function next():* { return throwEmptyListError(); }
    public function remove():void { throwEmptyListError(); }

    private function throwEmptyListError():* { throw new Error("iterating over an empty list"); }
}