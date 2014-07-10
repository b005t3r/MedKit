/**
 * User: booster
 * Date: 11/17/12
 * Time: 16:48
 */

package medkit.collection {

import medkit.collection.iterator.Iterator;
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.ObjectInputStream;
import medkit.object.ObjectOutputStream;
import medkit.object.ObjectUtil;

public class HashMap extends AbstractMap {
    public static const DEFAULT_INITIAL_CAPACITY:int    = 16;
    public static const MAXIMUM_CAPACITY:int            = 1 << 30;
    public static const DEFAULT_LOAD_FACTOR:Number      = 0.75;

    internal var table:Array;
    internal var _size:int;
    internal var threshold:int;
    internal var loadFactor:Number;
    internal var modCount:int;

    protected var _entrySet:Set;

    /**
     * This function ensures that hashCodes that differ only by constant multiples at each bit position have a bounded
     * number of collisions (approximately 8 at default load factor).
     *
     * @param h
     */
    public static function hash(h:int):int {
        h ^= (h >>> 20) ^ (h >>> 12);
        return h ^ (h >>> 7) ^ (h >>> 4);
    }

    /**
     * Returns index for hash code h.
     */
    public static function indexFor(h:int, length:int):int {
        return h & (length - 1);
    }

    public function HashMap(initialCapacity:int = DEFAULT_INITIAL_CAPACITY, loadFactor:Number = DEFAULT_LOAD_FACTOR) {
        if(initialCapacity < 0)
            throw new ArgumentError("Illegal initial capacity: " + initialCapacity);

        if(initialCapacity > MAXIMUM_CAPACITY)
            initialCapacity = MAXIMUM_CAPACITY;

        if(loadFactor <= 0 || isNaN(loadFactor))
            throw new ArgumentError("Illegal load factor: " + loadFactor);

        // Find a power of 2 >= initialCapacity
        var capacity:int = 1;

        while(capacity < initialCapacity)
            capacity <<= 1;

        this.loadFactor = loadFactor;
        threshold       = (capacity * loadFactor) as int;
        table           = new Array(capacity);

        init();
    }

    override public function size():int {
        return _size;
    }

    override public function isEmpty():Boolean {
        return _size == 0;
    }

    override public function get (key:*):* {
        if (key == null)
            return getForNullKey();

        var hash:int = HashMap.hash(ObjectUtil.hashCode(key));

        for(var e:HashMapEntry = table[HashMap.indexFor(hash, table.length)]; e != null; e = e.next) {
            var k:*;

            if(e.hash == hash && ((k = e.key) == key || ObjectUtil.equals(key, k)))
                return e.value;
        }

        return null;
    }

    override public function put(key:*, value:*):* {
        if (key == null)
            return putForNullKey(value);

        var hash:int    = HashMap.hash(ObjectUtil.hashCode(key));
        var i:int       = indexFor(hash, table.length);

        for(var e:HashMapEntry = table[i]; e != null; e = e.next) {
            var k:*;

            if(e.hash == hash && ((k = e.key) == key || ObjectUtil.equals(key, k))) {
                var oldValue:*  = e.value;
                e.value         = value;

                e.recordAccess(this);

                return oldValue;
            }
        }

        modCount++;

        addEntry(hash, key, value, i);

        return null;
    }

    override public function putAll(map:Map):void {
        var numKeysToBeAdded:int    = map.size();

        if(numKeysToBeAdded == 0)
            return;

        /*
         * Expand the map if the number of mappings to be added is greater than or equal to threshold.
         * This is conservative; the obvious condition is (m.size() + size) >= threshold, but this
         * condition could result in a map with twice the appropriate capacity, if the keys to be added
         * overlap with the keys already in this map. By using the conservative calculation, we subject ourself
         * to at most one extra resize.
         */
        if(numKeysToBeAdded > threshold) {
            var targetCapacity:int = (numKeysToBeAdded / loadFactor + 1) as int;

            if(targetCapacity > MAXIMUM_CAPACITY)
                targetCapacity = MAXIMUM_CAPACITY;

            var newCapacity:int = table.length;

            while(newCapacity < targetCapacity)
                newCapacity <<= 1;

            if(newCapacity > table.length)
                resize(newCapacity);
        }

        for (var i:Iterator = map.entrySet().iterator(); i.hasNext(); ) {
            var e:MapEntry = i.next();

            put(e.getKey(), e.getValue());
        }
    }

    override public function containsKey(key:*):Boolean {
        return getEntry(key) != null;
    }

    override public function removeKey(key:*):* {
        var e:HashMapEntry = removeEntryForKey(key);

        return (e == null ? null : e.value);
    }

    override public function clear():void {
        modCount++;

        for(var i:int = 0; i < table.length; i++)
            table[i] = null;

        _size = 0;
    }

    override public function containsValue(value:*):Boolean {
        if(value == null)
            return containsNullValue();

        for(var i:int = 0; i < table.length; i++)
            for(var e:HashMapEntry = table[i]; e != null; e = e.next)
                if(ObjectUtil.equals(value, e.value))
                    return true;

        return false;
    }

    override public function clone(cloningContext:CloningContext = null):Cloneable {
        if(cloningContext != null && cloningContext.isBeingCloned(this))
            return cloningContext.fetchClone(this);

        var clone:HashMap = cloningContext == null
            ? new HashMap(1, loadFactor)
            : cloningContext.isCloneRegistered(this)
                ? cloningContext.fetchClone(this)
                : cloningContext.registerClone(this, new HashMap(1, loadFactor))
        ;

        clone.table         = ObjectUtil.clone(this.table, cloningContext);
        clone._size         = this._size;
        clone.threshold     = this.threshold;
        clone.loadFactor    = this.loadFactor;
        clone.modCount      = 0;

        clone._entrySet     = null;
        clone._keySet       = null;
        clone._values       = null;

        return clone;
    }

    override public function readObject(input:ObjectInputStream):void {
        table         = input.readObject("table") as Array;
        _size         = input.readInt("size");
        threshold     = input.readInt("threshold");
        loadFactor    = input.readNumber("loadFactor");
    }

    override public function writeObject(output:ObjectOutputStream):void {
        output.writeObject(table, "table");
        output.writeInt(_size, "size");
        output.writeInt(threshold, "threshold");
        output.writeNumber(loadFactor, "loadFactor");
    }

    override public function keySet():Set {
        var ks:Set = _keySet;

        return (ks != null ? ks : (_keySet = new HashMapKeySet(this)));
    }

    override public function entrySet():Set {
        var es:Set = _entrySet;
        return es != null ? es : (_entrySet = new HashMapEntrySet(this));
    }

    override public function values():Collection {
        var vs:Collection = _values;

        return (vs != null ? vs : (_values = new HashMapValues(this)));
    }

    internal final function getForNullKey():* {
        for(var e:HashMapEntry = table[0]; e != null; e = e.next) {
            if(e.key == null)
                return e.value;
        }

        return null;
    }

    internal final function getEntry(key:*):HashMapEntry {
        var hash:int = (key == null) ? 0 : HashMap.hash(ObjectUtil.hashCode(key));

        for (var e:HashMapEntry = table[HashMap.indexFor(hash, table.length)]; e != null; e = e.next) {
            var k:*;

            if(e.hash == hash && ((k = e.key) == key || (key != null && ObjectUtil.equals(key, k))))
                return e;
        }

        return null;
    }

    internal final function putForNullKey(value:*):* {
        for (var e:HashMapEntry = table[0]; e != null; e = e.next) {
            if (e.key == null) {
                var oldValue:*  = e.value;
                e.value         = value;

                e.recordAccess(this);

                return oldValue;
            }
        }

        modCount++;

        addEntry(0, null, value, 0);

        return null;
    }

    internal final function putForCreate(key:*, value:*):void {
        var hash:int    = (key == null) ? 0 : HashMap.hash(ObjectUtil.hashCode(key));
        var i:int       = HashMap.indexFor(hash, table.length);

        for(var e:HashMapEntry = table[i]; e != null; e = e.next) {
            var k:*;

            if(e.hash == hash && ((k = e.key) == key || (key != null && ObjectUtil.equals(key, k)))) {
                e.value = value;
                return;
            }
        }

        createEntry(hash, key, value, i);
    }

    internal final function putAllForCreate(m:Map):void {
        for(var i:Iterator = m.entrySet().iterator(); i.hasNext(); ) {
            var e:MapEntry = i.next();

            putForCreate(e.getKey(), e.getValue());
        }
    }

    internal final function resize(newCapacity:int):void {
        var oldCapacity:int = table.length;

        if(oldCapacity == MAXIMUM_CAPACITY) {
            threshold = int.MAX_VALUE;
            return;
        }

        var newTable:Array = new Array(newCapacity);

        transfer(newTable);

        table       = newTable;
        threshold   = (newCapacity * loadFactor) as int;
    }

    internal final function transfer(newTable:Array):void {
        var src:Array       = table;
        var newCapacity:int = newTable.length;

        for (var j:int = 0; j < src.length; j++) {
            var e:HashMapEntry = src[j];

            if(e != null) {
                src[j] = null;

                do {
                    var next:HashMapEntry   = e.next;
                    var i:int               = indexFor(e.hash, newCapacity);
                    e.next                  = newTable[i];
                    newTable[i]             = e;
                    e                       = next;
                } while(e != null);
            }
        }
    }

    internal final function removeEntryForKey(key:*):HashMapEntry {
        var hash:int            = (key == null) ? 0 : HashMap.hash(ObjectUtil.hashCode(key));
        var i:int               = HashMap.indexFor(hash, table.length);
        var prev:HashMapEntry   = table[i];
        var e:HashMapEntry      = prev;

        while(e != null) {
            var next:HashMapEntry = e.next;
            var k:*;

            if(e.hash == hash && ((k = e.key) == key || (key != null && ObjectUtil.equals(key, k)))) {
                modCount++;
                _size--;

                if(prev == e)
                    table[i] = next;
                else
                    prev.next = next;

                e.recordRemoval(this);

                return e;
            }

            prev    = e;
            e       = next;
        }

        return e;
    }

    internal final function removeMapping(o:*):HashMapEntry {
        if (! (o is MapEntry))
            return null;

        var entry:MapEntry  = o as MapEntry;
        var key:*           = entry.getKey();
        var hash:int        = (key == null) ? 0 : HashMap.hash(ObjectUtil.hashCode(key));
        var i:int           = HashMap.indexFor(hash, table.length);

        var prev:HashMapEntry   = table[i];
        var e:HashMapEntry      = prev;

        while (e != null) {
            var next:HashMapEntry = e.next;

            if (e.hash == hash && ObjectUtil.equals(e, entry)) {
                modCount++;
                _size--;

                if(prev == e)
                    table[i] = next;
                else
                    prev.next = next;

                e.recordRemoval(this);

                return e;
            }

            prev    = e;
            e       = next;
        }

        return e;
    }

    internal final function containsNullValue():Boolean {
        var tab:Array = table;

        for (var i:int = 0; i < tab.length; i++)
            for (var e:HashMapEntry = tab[i]; e != null ; e = e.next)
                if (e.value == null)
                    return true;

        return false;
    }


    internal function newKeyIterator():Iterator {
        return new KeyIterator(this);
    }

    internal function newValueIterator():Iterator   {
        return new ValueIterator(this);
    }

    internal function newEntryIterator():Iterator   {
        return new EntryIterator(this);
    }

    /**
     * Adds a new entry with the specified key, value and hash code to the specified bucket.
     * It is the responsibility of this method to resize the table if appropriate.
     *
     * Subclass overrides this to alter the behavior of put method.
     */
    protected function addEntry(hash:int, key:*, value:*, bucketIndex:int):void {
        var e:HashMapEntry = table[bucketIndex];
        table[bucketIndex] = new HashMapEntry(hash, key, value, e);

        if (_size++ >= threshold)
            resize(2 * table.length);
    }

    /**
     * Like addEntry except that this version is used when creating entries as part of Map construction or
     * "pseudo-construction" (cloning, deserialization). This version needn't worry about resizing the table.
     *
     * Subclass overrides this to alter the behavior of HashMap(Map), clone, and readObject.
     */
    protected function createEntry(hash:int, key:*, value:*, bucketIndex:int):void {
        var e:HashMapEntry = table[bucketIndex];
        table[bucketIndex] = new HashMapEntry(hash, key, value, e);

        _size++;
    }

    /**
     * Initialization hook for subclasses. This method is called in all constructors and pseudo-constructors
     * (clone, readObject) after HashMap has been initialized but before any entries have been inserted.
     * (In the absence of this method, readObject would require explicit knowledge of subclasses.)
     */
    protected function init():void {
    }
}

}

import medkit.collection.HashMap;
import medkit.collection.HashMapItr;

internal class ValueIterator extends HashMapItr {
    function ValueIterator(map:HashMap) {
        super(map);
    }

    override public function next():* {
        return nextEntry().getValue();
    }
}

internal class KeyIterator extends HashMapItr {
    function KeyIterator(map:HashMap) {
        super(map);
    }

    override public function next():* {
        return nextEntry().getKey();
    }
}

internal class EntryIterator extends HashMapItr {
    function EntryIterator(map:HashMap) {
        super(map);
    }

    override public function next():* {
        return nextEntry();
    }
}
