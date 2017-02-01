/**
 * User: booster
 * Date: 13/01/16
 * Time: 13:47
 */
package medkit.collection {
import medkit.collection.iterator.Iterator;
import medkit.collection.iterator.ListIterator;
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Equalable;
import medkit.object.ObjectInputStream;
import medkit.object.ObjectOutputStream;
import medkit.object.ObjectUtil;

public class HashOrderedMultiSet implements OrderedMultiSet {
    private var _set:HashMultiSet;
    private var _list:ArrayList;

    public function HashOrderedMultiSet(initialCapacity:int = HashSet.DEFAULT_INITIAL_CAPACITY, loadFactor:Number = HashSet.DEFAULT_LOAD_FACTOR) {
        _set    = new HashMultiSet(initialCapacity, loadFactor);
        _list   = new ArrayList(initialCapacity);
    }

    public function add(o:*):Boolean {
        if(_set.elementCount(o) == 0)
            _list.add(o);

        return _set.add(o);
    }

    public function addAll(c:Collection):Boolean {
        var multiSet:MultiSet   = c as MultiSet;
        var it:Iterator         = c.iterator();
        var retVal:Boolean      = false;

        if(multiSet == null) {
            while(it.hasNext())
                retVal = add(it.next()) || retVal;
        }
        else {
            while(it.hasNext()) {
                var o:* = it.next();
                retVal = addCount(o, multiSet.elementCount(o)) || retVal;
            }
        }

        return retVal;
    }

    public function addArray(arr:Array):Boolean {
        var changed:Boolean = false;

        var count:int = arr.length;
        for(var i:int = 0; i < count; ++i) {
            var o:* = arr[i];

            changed = add(o) || changed;
        }

        return changed;
    }

    public function clear():void {
        _set.clear();
        _list.clear();
    }

    public function contains(o:*):Boolean {
        return _set.contains(o);
    }

    public function containsAll(c:Collection):Boolean {
        return _set.containsAll(c);
    }

    public function isEmpty():Boolean {
        return _set.isEmpty();
    }

    public function iterator():Iterator {
        return _list.iterator();
    }

    public function countedIterator():Iterator {
        return _set.countedIterator();
    }

    public function remove(o:*):Boolean {
        if(_set.elementCount(o) == 1)
            _list.remove(o);

        return _set.remove(o);
    }

    public function removeAll(c:Collection):Boolean {
        var multiSet:MultiSet   = c as MultiSet;
        var it:Iterator         = c.iterator();
        var retVal:Boolean      = false;

        if(multiSet == null) {
            while(it.hasNext())
                retVal = remove(it.next()) || retVal;
        }
        else {
            while(it.hasNext()) {
                var o:* = it.next();
                retVal = removeCount(o, multiSet.elementCount(o)) || retVal;
            }
        }

        return retVal;
    }

    public function retainAll(c:Collection):Boolean {
        var multiSet:MultiSet   = c as MultiSet;
        var it:Iterator         = iterator();
        var retVal:Boolean      = false;
        var o:*;

        if(multiSet == null) {
            while(it.hasNext()) {
                o = it.next();

                if(c.contains(o))
                    continue;

                if(elementCount(o) == 1)
                    it.remove();

                retVal = _set.remove(o) || retVal;
            }
        }
        else {
            while(it.hasNext()) {
                o = it.next();

                var setCount:int    = multiSet.elementCount(o);
                var count:int       = elementCount(o);

                if(setCount >= count)
                    continue;

                retVal = this.setCount(o, setCount) || retVal;

                if(setCount == 0)
                    it.remove();
            }
        }

        return retVal;
    }

    public function size():int {
        return _list.size();
    }

    public function toArray():Array {
        return _list.toArray();
    }

    public function equals(object:Equalable):Boolean {
        var multiSet:OrderedMultiSet = object as OrderedMultiSet;

        if(multiSet == null)
            return false;

        var count:int = _list.size();
        for(var i:int = 0; i < count; ++i) {
            var elem:* = get(i);
            var otherElem:* = multiSet.get(i);

            if(! ObjectUtil.equals(elem, otherElem))
                return false;

            if(elementCountAt(i) != multiSet.elementCountAt(i))
                return false;
        }

        return true;
    }

    public function hashCode():int {
        return _set.hashCode();
    }

    public function clone(cloningContext:CloningContext = null):Cloneable {
        if(cloningContext != null && cloningContext.isBeingCloned(this))
            return cloningContext.fetchClone(this);

        var clone:HashOrderedMultiSet = cloningContext == null
            ? new HashOrderedMultiSet(size())
            : cloningContext.isCloneRegistered(this)
                ? cloningContext.fetchClone(this)
                : cloningContext.registerClone(this, new HashOrderedMultiSet(size()))
        ;

        var count:int = size();
        for(var i:int = 0; i < count; ++i) {
            var o:* = get(i);
            var c:int = elementCountAt(i);

            clone.addCount(cloningContext != null ? ObjectUtil.clone(o, cloningContext) : o, c);
        }

        return clone;
    }

    public function readObject(input:ObjectInputStream):void {
        _set    = HashMultiSet(input.readObject("set"));
        _list   = ArrayList(input.readObject("list"));
    }

    public function writeObject(output:ObjectOutputStream):void {
        output.writeObject(_set, "set");
        output.writeObject(_list, "list");
    }

    public function addAt(index:int, o:*):void {
        throw new Error("operation not supported");
    }

    public function addAllAt(index:int, c:Collection):Boolean {
        throw new Error("operation not supported");
    }

    public function get(index:int):* {
        return _list.get(index);
    }

    public function indexOf(o:*):int {
        return _list.indexOf(o);
    }

    public function indexOfClass(c:Class):int {
        return _list.indexOfClass(c);
    }

    public function lastIndexOf(o:*):int {
        return _list.lastIndexOf(o);
    }

    public function lastIndexOfClass(c:Class):int {
        return _list.lastIndexOfClass(c);
    }

    public function listIterator(index:int = 0):ListIterator {
        return _list.listIterator(index);
    }

    public function removeAt(index:int):* {
        var removed:* = _list.get(index);

        _set.removeCount(removed, elementCountAt(index));

        return removed;
    }

    public function set(index:int, o:*):* {
        throw new Error("operation not supported");
    }

    public function swap(i:int, j:int):void {
        throw new Error("operation not supported");
    }

    public function subList(fromIndex:int, toIndex:int):List {
        throw new Error("operation not supported");
    }

    public function removeRange(fromIndex:int, toIndex:int):void {
        rangeCheckInternal(fromIndex, toIndex, size());
        removeRangeInternal(fromIndex, toIndex);
    }

    public function addCount(o:*, count:int):Boolean {
        if(_set.elementCount(o) == 0)
            _list.add(o);

        return _set.addCount(o, count);
    }

    public function removeCount(o:*, count:int):Boolean {
        if(_set.elementCount(o) <= count)
            _list.remove(o);

        return _set.removeCount(o, count);
    }

    public function setCount(o:*, count:int):Boolean {
        if(count == 0 && _set.contains(o))
            _list.remove(o);

        return _set.removeCount(o, count);
    }

    public function elementCount(o:*):int {
        return _set.elementCount(o);
    }

    public function addCountAt(i:int, count:int):Boolean {
        return _set.addCount(_list.get(i), count);
    }

    public function removeCountAt(i:int, count:int):Boolean {
        var c:int = elementCountAt(i);

        var retVal:Boolean = _set.removeCount(_list.get(i), count);

        if(c <= count)
            _list.removeAt(i);

        return retVal;
    }

    public function setCountAt(i:int, count:int):Boolean {
        var retVal:Boolean = _set.setCount(_list.get(i), count);

        if(count == 0)
            _list.removeAt(i);

        return retVal;
    }

    public function elementCountAt(i:int):int {
        return _set.elementCount(_list.get(i));
    }

    internal function removeRangeInternal(fromIndex:int, toIndex:int):void {
        var it:ListIterator = listIterator(fromIndex);

        for (var i:int = 0, n:int = toIndex - fromIndex; i < n; i++) {
            var o:* = it.next();

            _set.removeCount(o, elementCountAt(fromIndex + i));
            it.remove();
        }
    }

    internal final function rangeCheckInternal(fromIndex:int, toIndex:int, size:int):void {
        if (fromIndex < 0)
            throw new RangeError("fromIndex = " + fromIndex);
        if (toIndex > size)
            throw new RangeError("toIndex = " + toIndex);
        if (fromIndex > toIndex)
            throw new RangeError("fromIndex(" + fromIndex + ") > toIndex(" + toIndex + ")");
    }

    public function get first():* { return _list.first; }
    public function get last():* { return _list.last; }
    public function indexToReversedIndex(index:int):int { return _list.indexToReversedIndex(index); }
    public function reversedIndexToIndex(reversedIndex:int):int { return _list.reversedIndexToIndex(reversedIndex); }
    public function getReversed(index:int):* { return _list.getReversed(index); }
}
}
