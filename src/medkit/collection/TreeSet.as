/**
 * User: booster
 * Date: 12/22/12
 * Time: 12:56
 */

package medkit.collection {

import medkit.collection.iterator.Iterator;
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Comparator;
import medkit.object.ObjectInputStream;
import medkit.object.ObjectOutputStream;
import medkit.object.ObjectUtil;

public class TreeSet extends AbstractSet implements NavigableSet, Cloneable {
    private static const PRESENT:Boolean = true;

    private var m:NavigableMap;

    public function TreeSet(comparator:Comparator = null) {
        m = new TreeMap(comparator);
    }

    override public function iterator():Iterator {
        return m.navigableKeySet().iterator();
    }

    public function descendingIterator():Iterator {
        return m.descendingNavigableKeySet().iterator();
    }

    public function descendingNavigableSet():NavigableSet {
        var s:TreeSet = new TreeSet();

        s.m = m.descendingNavigableMap();

        return s;
    }

    override public function size():int {
        return m.size();
    }

    override public function isEmpty():Boolean {
        return m.isEmpty();
    }

    override public function contains(o:*):Boolean {
        return m.containsKey(o);
    }

    override public function add(e:*):Boolean {
        return m.put(e, PRESENT) == null;
    }

    override public function remove(o:*):Boolean {
        return m.removeKey(o) == PRESENT;
    }

    override public function clear():void {
        m.clear();
    }

    override public function addAll(c:Collection):Boolean {
        // Use linear-time version if applicable
        if(m.size() == 0 && c.size() > 0 && c is SortedSet && m is TreeMap) {
            var set:SortedSet = c as SortedSet;
            var map:TreeMap = m as TreeMap;
            var cc:Comparator = set.comparator();
            var mc:Comparator = map.comparator();

            if(cc == mc || (cc != null && cc.equals(mc))) {
                map.addAllForTreeSet(set, PRESENT);
                return true;
            }
        }

        return super.addAll(c);
    }

    public function subNavigableSet(fromElement:*, fromInclusive:Boolean, toElement:*, toInclusive:Boolean):NavigableSet {
        var s:TreeSet = new TreeSet();

        s.m = m.subNavigableMap(fromElement, fromInclusive, toElement, toInclusive);

        return s;
    }

    public function headNavigableSet(toElement:*, inclusive:Boolean):NavigableSet {
        var s:TreeSet = new TreeSet();

        s.m = m.headNavigableMap(toElement, inclusive);

        return s;
    }

    public function tailNavigableSet(fromElement:*, inclusive:Boolean):NavigableSet {
        var s:TreeSet = new TreeSet();

        s.m = m.tailNavigableMap(fromElement, inclusive);

        return s;
    }

    public function subSet(fromElement:*, toElement:*):SortedSet {
        return subNavigableSet(fromElement, true, toElement, false);
    }

    public function headSet(toElement:*):SortedSet {
        return headNavigableSet(toElement, false);
    }

    public function tailSet(fromElement:*):SortedSet {
        return tailNavigableSet(fromElement, true);
    }

    public function comparator():Comparator {
        return m.comparator();
    }

    public function first():* {
        return m.firstKey();
    }

    public function last():* {
        return m.lastKey();
    }

    public function lower(e:*):* {
        return m.lowerKey(e);
    }

    public function floor(e:*):* {
        return m.floorKey(e);
    }

    public function ceiling(e:*):* {
        return m.ceilingKey(e);
    }

    public function higher(e:*):* {
        return m.higherKey(e);
    }

    public function pollFirst():* {
        var e:MapEntry = m.pollFirstEntry();

        return (e == null) ? null : e.getKey();
    }

    public function pollLast():* {
        var e:MapEntry = m.pollLastEntry();

        return (e == null) ? null : e.getKey();
    }

    override public function clone(cloningContext:CloningContext = null):Cloneable {
        if(cloningContext != null && cloningContext.isBeingCloned(this))
            return cloningContext.fetchClone(this);

        var clone:TreeSet = cloningContext == null
            ? new TreeSet(this.m.comparator())
            : cloningContext.isCloneRegistered(this)
                ? cloningContext.fetchClone(this)
                : cloningContext.registerClone(this, new TreeSet(this.m.comparator()))
        ;

        var it:Iterator = m.keySet().iterator();

        while(it.hasNext()) {
            var cloneKey:* = cloningContext != null ? ObjectUtil.clone(it.next(), cloningContext) : it.next();
            clone.m.put(cloneKey, PRESENT);
        }

        return clone;
    }

    override public function readObject(input:ObjectInputStream):void {
        var size:int = input.readInt("size");

        for(var i:int = 0; i < size; ++i)
            add(input.readObject(String(i)));
    }

    override public function writeObject(output:ObjectOutputStream):void {
        output.writeInt(size(), "size");

        var i:int = 0, it:Iterator = this.iterator();
        while(it.hasNext()) {
            var e:* = it.next();

            output.writeObject(e, String(i));
            ++i;
        }
    }
}
}
