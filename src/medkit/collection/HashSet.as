/**
 * User: booster
 * Date: 11/18/12
 * Time: 11:58
 */

package medkit.collection {

import medkit.collection.iterator.Iterator;
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.ObjectInputStream;
import medkit.object.ObjectOutputStream;
import medkit.object.ObjectUtil;

public class HashSet extends AbstractSet {
    public static const DEFAULT_INITIAL_CAPACITY:int    = 16;
    public static const DEFAULT_LOAD_FACTOR:Number      = 0.75;

    private var map:HashMap;

    private static const PRESENT:Boolean = true; // dummy, empty object value

    public function HashSet(initialCapacity:int = HashSet.DEFAULT_INITIAL_CAPACITY, loadFactor:Number = HashSet.DEFAULT_LOAD_FACTOR) {
        map = new HashMap(initialCapacity, loadFactor)
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

    override public function add(o:*):Boolean {
        return map.put(o, PRESENT ) == null;
    }

    override public function remove(o:*):Boolean {
        return map.removeKey(o) === PRESENT;
    }

    override public function clear():void {
        map.clear();
    }

    override public function clone(cloningContext:CloningContext = null):Cloneable {
        if(cloningContext != null && cloningContext.isBeingCloned(this))
            return cloningContext.fetchClone(this);

        var clone:HashSet = cloningContext == null
            ? new HashSet(size())
            : cloningContext.isCloneRegistered(this)
                ? cloningContext.fetchClone(this)
                : cloningContext.registerClone(this, new HashSet(size()))
        ;

        var it:Iterator = map.keySet().iterator();

        while(it.hasNext()) {
            var cloneKey:* = cloningContext != null ? ObjectUtil.clone(it.next(), cloningContext) : it.next();
            clone.map.put(cloneKey, PRESENT);
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
