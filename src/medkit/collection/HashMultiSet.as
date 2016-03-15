/**
 * User: booster
 * Date: 18/09/15
 * Time: 20:38
 */
package medkit.collection {
import medkit.collection.iterator.Iterator;
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Equalable;
import medkit.object.ObjectInputStream;
import medkit.object.ObjectOutputStream;
import medkit.object.ObjectUtil;

public class HashMultiSet extends AbstractSet implements MultiSet {
    private var map:HashMap;

    public function HashMultiSet(initialCapacity:int = HashSet.DEFAULT_INITIAL_CAPACITY, loadFactor:Number = HashSet.DEFAULT_LOAD_FACTOR) {
        map = new HashMap(initialCapacity, loadFactor);
    }

    public function addCount(o:*, count:int):Boolean {
        if(count == 0)
            return false;

        var entry:MapEntry = map.getEntry(o);

        if(entry == null) {
            map.put(o, count);

            return true;
        }
        else {
            entry.setValue(int(entry.getValue()) + count);

            return true;
        }
    }

    public function removeCount(o:*, count:int):Boolean {
        if(count == 0)
            return false;

        var entry:MapEntry = map.getEntry(o);

        if(entry == null) {
            return false;
        }
        else {
            var c:int = int(entry.getValue());

            if(c > count)
                entry.setValue(c - count);
            else
                map.removeKey(o);

            return true;
        }
    }

    public function setCount(o:*, count:int):Boolean {
        if(count == 0)
            return map.removeKey(o) != null;

        var entry:MapEntry = map.getEntry(o);

        if(entry == null) {
            map.put(o, count);

            return true;
        }
        else {
            var c:int = int(entry.getValue());
            entry.setValue(count);

            return c != count;
        }
    }

    public function elementCount(o:*):int {
        var entry:MapEntry = map.getEntry(o);

        return entry != null ? entry.getValue() : 0;
    }

    override public function iterator():Iterator {
        return map.keySet().iterator();
    }

    override public function size():int {
        return map.size();
    }

    override public function isEmpty():Boolean {
        return map.isEmpty();
    }

    override public function contains(o:*):Boolean {
        return map.containsKey(o);
    }

    override public function containsAll(c:Collection):Boolean {
        if(c is MultiSet == false)
            return super.containsAll(c);

        var ms:MultiSet = MultiSet(c);
        var it:Iterator = ms.iterator();
        while(it.hasNext()) {
            var next:* = it.next();

            if(elementCount(next) < ms.elementCount(next))
                return false;
        }

        return true;
    }

    override public function add(o:*):Boolean {
        var entry:MapEntry = map.getEntry(o);

        if(entry == null) {
            map.put(o, 1);

            return true;
        }
        else {
            entry.setValue(int(entry.getValue()) + 1);

            return true;
        }
    }

    override public function addAll(c:Collection):Boolean {
        if(c is MultiSet == false)
            return super.addAll(c);

        if(c.isEmpty())
            return false;

        var ms:MultiSet         = MultiSet(c);
        var it:Iterator         = ms.iterator();

        while(it.hasNext()) {
            var next:*          = it.next();
            var entry:MapEntry  = map.getEntry(next);

            if(entry == null) {
                map.put(next, ms.elementCount(next));
            }
            else {
                var count:int = entry.getValue() + ms.elementCount(next);
                entry.setValue(count);
            }
        }

        return true;
    }

    override public function equals(object:Equalable):Boolean {
        if (object == this)
            return true;

        var it:Iterator;

        if (object is MultiSet) {
            var ms:MultiSet = MultiSet(object);

            if(ms.size() != size())
                return false;

            it = map.entrySet().iterator();
            while(it.hasNext()) {
                var entry:MapEntry = it.next();

                if(ms.elementCount(entry.getKey()) != entry.getValue())
                    return false;
            }

            return true;
        }
        else if(object is Set) {
            var s:Set = Set(object);

            if(s.size() != size())
                return false;

            it = s.iterator();
            while(it.hasNext()) {
                var next:* = it.next();

                if(elementCount(next) != 1)
                    return false;
            }
        }

        return false;
    }

    override public function remove(o:*):Boolean {
        var entry:MapEntry = map.getEntry(o);

        if(entry == null) {
            return false;
        }
        else {
            var count:int = int(entry.getValue());

            if(count > 1)
                entry.setValue(count - 1);
            else
                map.removeKey(o);

            return true;
        }
    }

    override public function removeAll(c:Collection):Boolean {
        if(c is MultiSet == false)
            return super.removeAll(c);

        var modified:Boolean    = false;

        var ms:MultiSet         = MultiSet(c);
        var it:Iterator         = ms.iterator();

        while(it.hasNext()) {
            var next:*          = it.next();
            var entry:MapEntry  = map.getEntry(next);

            if(entry == null)
                continue;

            modified = true;

            var count:int = entry.getValue() - ms.elementCount(next);

            if(count <= 0)
                map.removeKey(next);
            else
                entry.setValue(count);
        }

        return modified;
    }

    override public function retainAll(c:Collection):Boolean {
        var modified:Boolean = false;

        var entry:MapEntry, it:Iterator = map.entrySet().iterator();
        if(c is MultiSet == false) {
            var ms:MultiSet = MultiSet(c);

            while(it.hasNext()) {
                entry = it.next();
                var thisCount:int = entry.getValue();
                var thatCount:int = ms.elementCount(entry.getKey());

                if(thisCount <= thatCount)
                    continue;

                modified = true;

                if(thatCount == 0)
                    it.remove();
                else
                    entry.setValue(thatCount);
            }
        }
        // it won't work for collections with more than one copy of an element, e.g. List
        else {
            while(it.hasNext()) {
                entry = it.next();

                if(! c.contains(entry.getKey())) {
                    modified = true;

                    it.remove();
                }
                else if(entry.getValue() != 1) {
                    modified = true;

                    entry.setValue(1);
                }
            }
        }

        return modified;
    }

    override public function clear():void {
        map.clear();
    }

    override public function clone(cloningContext:CloningContext = null):Cloneable {
        if(cloningContext != null && cloningContext.isBeingCloned(this))
            return cloningContext.fetchClone(this);

        var clone:HashMultiSet = cloningContext == null
                ? new HashMultiSet(size())
                : cloningContext.isCloneRegistered(this)
                ? cloningContext.fetchClone(this)
                : cloningContext.registerClone(this, new HashMultiSet(size()))
            ;

        var it:Iterator = map.entrySet().iterator();

        while(it.hasNext()) {
            var entry:MapEntry = it.next();
            var cloneKey:* = cloningContext != null ? ObjectUtil.clone(entry.getKey(), cloningContext) : entry.getKey();

            clone.map.put(cloneKey, entry.getValue());
        }

        return clone;
    }

    override public function readObject(input:ObjectInputStream):void {
        map = input.readObject("map") as HashMap;
    }

    override public function writeObject(output:ObjectOutputStream):void {
        output.writeObject(map, "map");
    }
}
}
