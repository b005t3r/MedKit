/**
 * User: booster
 * Date: 18/09/15
 * Time: 20:38
 */
package medkit.collection {
import medkit.collection.iterator.Iterator;
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.ObjectInputStream;
import medkit.object.ObjectOutputStream;
import medkit.object.ObjectUtil;

public class CountedHashSet extends AbstractSet implements CountedSet {
    private var map:HashMap;
    private var count:int;

    public function CountedHashSet(initialCapacity:int = HashSet.DEFAULT_INITIAL_CAPACITY, loadFactor:Number = HashSet.DEFAULT_LOAD_FACTOR) {
        map = new HashMap(initialCapacity, loadFactor);
        count = 0;
    }

    override public function iterator():Iterator {
        throw new Error("TODO");
    }

    override public function size():int {
        return count;
    }

    override public function isEmpty():Boolean {
        return count == 0;
    }

    override public function contains(o:*):Boolean {
        return map.containsKey(o);
    }

    override public function add(o:*):Boolean {
        var entry:MapEntry = map.getEntry(o);

        if(entry == null) {
            map.put(o, 1);
            ++count;

            return true;
        }
        else {
            entry.setValue(int(entry.getValue()) + 1);
            ++count;

            return true;
        }
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

            --count;

            return true;
        }
    }

    override public function clear():void {
        map.clear();
        count = 0;
    }

    override public function clone(cloningContext:CloningContext = null):Cloneable {
        if(cloningContext != null && cloningContext.isBeingCloned(this))
            return cloningContext.fetchClone(this);

        var clone:CountedHashSet = cloningContext == null
                ? new CountedHashSet(size())
                : cloningContext.isCloneRegistered(this)
                ? cloningContext.fetchClone(this)
                : cloningContext.registerClone(this, new CountedHashSet(size()))
            ;

        var it:Iterator = map.entrySet().iterator();

        while(it.hasNext()) {
            var entry:MapEntry = it.next();
            var cloneKey:* = cloningContext != null ? ObjectUtil.clone(entry.getKey(), cloningContext) : entry.getKey();

            clone.map.put(cloneKey, entry.getValue());
        }

        clone.count = count;

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
