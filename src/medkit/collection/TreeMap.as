/**
 * User: booster
 * Date: 12/15/12
 * Time: 12:44
 */

package medkit.collection {

import medkit.collection.iterator.Iterator;
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Comparator;
import medkit.object.ObjectInputStream;
import medkit.object.ObjectOutputStream;
import medkit.object.ObjectUtil;

public class TreeMap extends AbstractMap implements NavigableMap {
    internal static const RED:Boolean       = false;
    internal static const BLACK:Boolean     = true;
    internal static const UNBOUNDED:Object  = {};

    private var _comparator:Comparator;
    private var root:TreeMapEntry;
    private var _size:int;
    internal var modCount:int;

    private var _entrySet:TreeMapEntrySet;
    private var _navigableKeySet:TreeMapKeySet;
    private var _descendingMap:NavigableMap;

    public function TreeMap(comparator:Comparator = null) {
        this._comparator = comparator;
    }

    override public function readObject(input:ObjectInputStream):void {
        _comparator = Comparator(input.readObject("comparator"));
        root        = TreeMapEntry(input.readObject("root"));
        _size       = input.readInt("size");
    }

    override public function writeObject(output:ObjectOutputStream):void {
        output.writeObject(_comparator, "comparator");
        output.writeObject(root, "root");
        output.writeInt(_size, "size");
    }

    override public function size():int {
        return _size;
    }

    override public function containsKey(key:*):Boolean {
        return getEntry(key) != null;
    }

    override public function containsValue(value:*):Boolean {
        for(var e:TreeMapEntry = getFirstEntry(); e != null; e = successor(e))
            if(valEquals(value, e.value))
                return true;

        return false;
    }

    override public function get(key:*):* {
        var p:TreeMapEntry = getEntry(key);
        return (p == null ? null : p.value);
    }

    public function comparator():Comparator {
        return _comparator;
    }

    public function firstKey():* {
        return key(getFirstEntry());
    }

    public function lastKey():* {
        return key(getLastEntry());
    }

    override public function putAll(map:Map):void {
        var mapSize:int = map.size();

        if(_size == 0 && mapSize != 0 && map is SortedMap) {
            var c:Comparator = (map as SortedMap).comparator();

            if(c == _comparator || (c != null && ObjectUtil.equals(c, _comparator))) {
                ++modCount;

                buildFromSorted(mapSize, map.entrySet().iterator(), /*null, */null);

                return;
            }
        }
        super.putAll(map);
    }

    internal final function getEntry(key:*):TreeMapEntry {
        // Offload comparator-based version for sake of performance
        if(_comparator != null)
            return getEntryUsingComparator(key);

        if(key == null)
            throw new ArgumentError("key must not be null");

        var p:TreeMapEntry = root;

        while(p != null) {
            var cmp:int = ObjectUtil.compare(key, p.key);

            if(cmp < 0)
                p = p.left;
            else
                if(cmp > 0)
                    p = p.right;
                else
                    return p;
        }
        return null;
    }

    internal final function getEntryUsingComparator(key:*):TreeMapEntry {
        var cpr:Comparator = _comparator;

        if(cpr != null) {
            var p:TreeMapEntry = root;

            while(p != null) {
                var cmp:int = cpr.compare(key, p.key);

                if(cmp < 0)
                    p = p.left;
                else
                    if(cmp > 0)
                        p = p.right;
                    else
                        return p;
            }
        }
        return null;
    }

    internal final function getCeilingEntry(key:*):TreeMapEntry {
        var p:TreeMapEntry = root;
        while(p != null) {
            var cmp:int = compare(key, p.key);
            if(cmp < 0) {
                if(p.left != null)
                    p = p.left;
                else
                    return p;
            }
            else
                if(cmp > 0) {
                    if(p.right != null) {
                        p = p.right;
                    }
                    else {
                        var parent:TreeMapEntry = p.parent;
                        var ch:TreeMapEntry = p;
                        while(parent != null && ch == parent.right) {
                            ch = parent;
                            parent = parent.parent;
                        }
                        return parent;
                    }
                }
                else
                    return p;
        }
        return null;
    }

    internal final function getFloorEntry(key:*):TreeMapEntry {
        var p:TreeMapEntry = root;
        while(p != null) {
            var cmp:int = compare(key, p.key);
            if(cmp > 0) {
                if(p.right != null)
                    p = p.right;
                else
                    return p;
            }
            else
                if(cmp < 0) {
                    if(p.left != null) {
                        p = p.left;
                    }
                    else {
                        var parent:TreeMapEntry = p.parent;
                        var ch:TreeMapEntry = p;
                        while(parent != null && ch == parent.left) {
                            ch = parent;
                            parent = parent.parent;
                        }
                        return parent;
                    }
                }
                else
                    return p;

        }
        return null;
    }

    internal final function getHigherEntry(key:*):TreeMapEntry {
        var p:TreeMapEntry = root;

        while(p != null) {
            var cmp:int = compare(key, p.key);

            if(cmp < 0) {
                if(p.left != null)
                    p = p.left;
                else
                    return p;
            }
            else {
                if(p.right != null) {
                    p = p.right;
                }
                else {
                    var parent:TreeMapEntry = p.parent;
                    var ch:TreeMapEntry = p;
                    while(parent != null && ch == parent.right) {
                        ch = parent;
                        parent = parent.parent;
                    }
                    return parent;
                }
            }
        }
        return null;
    }

    internal final function getLowerEntry(key:*):TreeMapEntry {
        var p:TreeMapEntry = root;

        while(p != null) {
            var cmp:int = compare(key, p.key);

            if(cmp > 0) {
                if(p.right != null)
                    p = p.right;
                else
                    return p;
            }
            else {
                if(p.left != null) {
                    p = p.left;
                }
                else {
                    var parent:TreeMapEntry = p.parent;
                    var ch:TreeMapEntry = p;

                    while(parent != null && ch == parent.left) {
                        ch = parent;
                        parent = parent.parent;
                    }
                    return parent;
                }
            }
        }
        return null;
    }

    override public function put(key:*, value:*):* {
        var t:TreeMapEntry = root;

        if(t == null) {
            // TBD:
            // 5045147: (coll) Adding null to an empty TreeSet should
            // throw NullPointerException
            //
            // compare(key, key); // type check
            root = new TreeMapEntry(key, value, null);
            _size = 1;
            modCount++;

            return null;
        }

        var cmp:int;
        var parent:TreeMapEntry;

        // split comparator and comparable paths
        var cpr:Comparator = _comparator;

        if(cpr != null) {
            do {
                parent = t;
                cmp = cpr.compare(key, t.key);
                if(cmp < 0)
                    t = t.left;
                else if(cmp > 0)
                    t = t.right;
                else
                    return t.setValue(value);
            } while(t != null);
        }
        else {
            if(key == null)
                throw new ArgumentError("key must not be null");

            do {
                parent = t;
                cmp = ObjectUtil.compare(key, t.key);

                if(cmp < 0)
                    t = t.left;
                else if(cmp > 0)
                    t = t.right;
                else
                    return t.setValue(value);

            } while(t != null);
        }

        var e:TreeMapEntry = new TreeMapEntry(key, value, parent);

        if(cmp < 0)
            parent.left = e;
        else
            parent.right = e;

        fixAfterInsertion(e);
        _size++;
        modCount++;

        return null;
    }

    public function remove(key:*):* {
        var p:TreeMapEntry = getEntry(key);

        if(p == null)
            return null;

        var oldValue:* = p.value;

        deleteEntry(p);

        return oldValue;
    }

    override public function clear():void {
        modCount++;
        _size = 0;
        root = null;
    }

    override public function clone(cloningContext:CloningContext = null):Cloneable {
        if(cloningContext != null && cloningContext.isBeingCloned(this))
            return cloningContext.fetchClone(this);

        var clone:TreeMap = cloningContext == null
            ? new TreeMap()
            : cloningContext.isCloneRegistered(this)
                ? cloningContext.fetchClone(this)
                : cloningContext.registerClone(this, new TreeMap())
        ;

        // put clone into "virgin" state (except for comparator)
        clone.root              = null;
        clone._size             = 0;
        clone.modCount          = 0;
        clone._entrySet         = null;
        clone._navigableKeySet  = null;
        clone._descendingMap    = null;

        // this is different from original implementation
        clone._comparator        = _comparator;

        if(cloningContext != null)
            clone.root = ObjectUtil.clone(root, cloningContext);
        else
            clone.buildFromSorted(_size, entrySet().iterator(), /*null, */null);

        return clone;
    }

    public function firstEntry():MapEntry {
        return exportEntry(getFirstEntry());
    }

    public function lastEntry():MapEntry {
        return exportEntry(getLastEntry());
    }

    public function pollFirstEntry():MapEntry {
        var p:TreeMapEntry = getFirstEntry();
        var result:MapEntry = exportEntry(p);

        if(p != null)
            deleteEntry(p);

        return result;
    }

    public function pollLastEntry():MapEntry {
        var p:TreeMapEntry = getLastEntry();
        var result:MapEntry = exportEntry(p);

        if(p != null)
            deleteEntry(p);

        return result;
    }

    public function lowerEntry(key:*):MapEntry {
        return exportEntry(getLowerEntry(key));
    }

    public function lowerKey(key:*):* {
        return keyOrNull(getLowerEntry(key));
    }

    public function floorEntry(key:*):MapEntry {
        return exportEntry(getFloorEntry(key));
    }

    public function floorKey(key:*):* {
        return keyOrNull(getFloorEntry(key));
    }

    public function ceilingEntry(key:*):MapEntry {
        return exportEntry(getCeilingEntry(key));
    }

    public function ceilingKey(key:*):* {
        return keyOrNull(getCeilingEntry(key));
    }

    public function higherEntry(key:*):MapEntry {
        return exportEntry(getHigherEntry(key));
    }

    public function higherKey(key:*):* {
        return keyOrNull(getHigherEntry(key));
    }

    override public function keySet():Set {
        return navigableKeySet();
    }

    public function navigableKeySet():NavigableSet {
        var nks:TreeMapKeySet = _navigableKeySet;

        return (nks != null) ? nks : (_navigableKeySet = new TreeMapKeySet(this));
    }

    public function descendingNavigableKeySet():NavigableSet {
        return descendingNavigableMap().navigableKeySet();
    }

    override public function values():Collection {
        var vs:Collection = _values;
        return (vs != null) ? vs : (_values = new TreeMapValues(this));
    }

    override public function entrySet():Set {
        var es:TreeMapEntrySet = _entrySet;
        return (es != null) ? es : (_entrySet = new TreeMapEntrySet(this));
    }

    public function descendingNavigableMap():NavigableMap {
        var km:NavigableMap = _descendingMap;

        return (km != null) ? km :
            (_descendingMap = new TreeMapDescendingSubMap(
                this, true, null, true, true, null, true
            ));
    }

    public function subNavigableMap(fromKey:*, fromInclusive:Boolean, toKey:*, toInclusive:Boolean):NavigableMap {
        return new TreeMapAscendingSubMap(
            this, false, fromKey, fromInclusive, false, toKey, toInclusive
        );
    }

    public function headNavigableMap(toKey:*, inclusive:Boolean):NavigableMap {
        return new TreeMapAscendingSubMap(
            this, true,  null,  true, false, toKey, inclusive
        );
    }

    public function tailNavigableMap(fromKey:*, inclusive:Boolean):NavigableMap {
        return new TreeMapAscendingSubMap(
            this, false, fromKey, inclusive, true, null, true
        );
    }

    public function subMap(fromKey:*, toKey:*):SortedMap {
        return subNavigableMap(fromKey, true, toKey, false);
    }

    public function headMap(toKey:*):SortedMap {
        return headNavigableMap(toKey, false);
    }

    public function tailMap(fromKey:*):SortedMap {
        return tailNavigableMap(fromKey, true);
    }

    internal function keyIterator():Iterator {
        return new TreeMapKeyIterator(this, getFirstEntry());
    }

    internal function descendingKeyIterator():Iterator {
        return new TreeMapDescendingKeyIterator(this, getLastEntry());
    }

    /**
     * Compares two keys using the correct comparison method for this TreeMap.
     */
    internal final function compare(k1:*, k2:*):int {
        return _comparator == null
            ? ObjectUtil.compare(k1, k2)
            : _comparator.compare(k1, k2)
        ;
    }

    /**
     * Test two values for equality.  Differs from o1.equals(o2) only in
     * that it copes with <tt>null</tt> o1 properly.
     */
    internal static function valEquals(o1:*, o2:*):Boolean {
        return (o1 == null ? o2 == null : ObjectUtil.equals(o1, o2));
    }

    /**
     * Return SimpleImmutableEntry for entry, or null if null
     */
    internal static function exportEntry(e:TreeMapEntry):MapEntry {
        return e == null
            ? null
            : new SimpleImmutableMapEntry(e.getKey(), e.getValue())
        ;
    }

    /**
     * Return key for entry, or null if null
     */
    internal static function keyOrNull(e:TreeMapEntry):* {
        return e == null ? null : e.key;
    }

    /**
     * Returns the key corresponding to the specified Entry.
     * @throws ArgumentError if the Entry is null
     */
    internal static function key(e:TreeMapEntry):* {
        if(e == null)
            throw new ArgumentError("e is null");

        return e.key;
    }

    /**
     * Returns the first Entry in the TreeMap (according to the TreeMap's
     * key-sort function).  Returns null if the TreeMap is empty.
     */
    internal final function getFirstEntry():TreeMapEntry {
        var p:TreeMapEntry = root;

        if(p != null)
            while(p.left != null)
                p = p.left;

        return p;
    }

    /**
     * Returns the last Entry in the TreeMap (according to the TreeMap's
     * key-sort function).  Returns null if the TreeMap is empty.
     */
    internal final function getLastEntry():TreeMapEntry {
        var p:TreeMapEntry = root;
        if(p != null)
            while(p.right != null)
                p = p.right;
        return p;
    }

    /**
     * Returns the successor of the specified Entry, or null if no such.
     */
    internal static function successor(t:TreeMapEntry):TreeMapEntry {
        if(t == null) { return null;}
        else {
            var p:TreeMapEntry;

            if(t.right != null) {
                p = t.right;
                while(p.left != null)
                    p = p.left;
                return p;
            }
            else {
                p = t.parent;
                var ch:TreeMapEntry = t;
                while(p != null && ch == p.right) {
                    ch = p;
                    p = p.parent;
                }
                return p;
            }
        }
    }

    /**
     * Returns the predecessor of the specified Entry, or null if no such.
     */
    internal static function predecessor(t:TreeMapEntry):TreeMapEntry {
        if(t == null) { return null;}
        else {
            var p:TreeMapEntry;

            if(t.left != null) {
                p = t.left;

                while(p.right != null)
                    p = p.right;

                return p;
            }
            else {
                p = t.parent;
                var ch:TreeMapEntry = t;

                while(p != null && ch == p.left) {
                    ch = p;
                    p = p.parent;
                }

                return p;
            }
        }
    }

    /**
     * Balancing operations.
     *
     * Implementations of rebalancings during insertion and deletion are
     * slightly different than the CLR version.  Rather than using dummy
     * nilnodes, we use a set of accessors that deal properly with null.  They
     * are used to avoid messiness surrounding nullness checks in the main
     * algorithms.
     */

    private static function colorOf(p:TreeMapEntry):Boolean {
        return (p == null ? BLACK : p.color);
    }

    private static function parentOf(p:TreeMapEntry):TreeMapEntry {
        return (p == null ? null : p.parent);
    }

    private static function setColor(p:TreeMapEntry, c:Boolean):void {
        if(p != null)
            p.color = c;
    }

    private static function leftOf(p:TreeMapEntry):TreeMapEntry {
        return (p == null) ? null : p.left;
    }

    private static function rightOf(p:TreeMapEntry):TreeMapEntry {
        return (p == null) ? null : p.right;
    }

    /** From CLR */
    private function rotateLeft(p:TreeMapEntry):void {
        if(p != null) {
            var r:TreeMapEntry = p.right;
            p.right = r.left;
            if(r.left != null)
                r.left.parent = p;
            r.parent = p.parent;
            if(p.parent == null)
                root = r;
            else
                if(p.parent.left == p)
                    p.parent.left = r;
                else
                    p.parent.right = r;
            r.left = p;
            p.parent = r;
        }
    }

    /** From CLR */
    private function rotateRight(p:TreeMapEntry):void {
        if(p != null) {
            var l:TreeMapEntry = p.left;
            p.left = l.right;
            if(l.right != null) l.right.parent = p;
            l.parent = p.parent;
            if(p.parent == null)
                root = l;
            else
                if(p.parent.right == p)
                    p.parent.right = l;
                else p.parent.left = l;
            l.right = p;
            p.parent = l;
        }
    }

    /** From CLR */
    private function fixAfterInsertion(x:TreeMapEntry):void {
        x.color = RED;

        while(x != null && x != root && x.parent.color == RED) {
            var y:TreeMapEntry;
            if(parentOf(x) == leftOf(parentOf(parentOf(x)))) {
                y = rightOf(parentOf(parentOf(x)));
                if(colorOf(y) == RED) {
                    setColor(parentOf(x), BLACK);
                    setColor(y, BLACK);
                    setColor(parentOf(parentOf(x)), RED);
                    x = parentOf(parentOf(x));
                }
                else {
                    if(x == rightOf(parentOf(x))) {
                        x = parentOf(x);
                        rotateLeft(x);
                    }
                    setColor(parentOf(x), BLACK);
                    setColor(parentOf(parentOf(x)), RED);
                    rotateRight(parentOf(parentOf(x)));
                }
            }
            else {
                y = leftOf(parentOf(parentOf(x)));
                if(colorOf(y) == RED) {
                    setColor(parentOf(x), BLACK);
                    setColor(y, BLACK);
                    setColor(parentOf(parentOf(x)), RED);
                    x = parentOf(parentOf(x));
                }
                else {
                    if(x == leftOf(parentOf(x))) {
                        x = parentOf(x);
                        rotateRight(x);
                    }
                    setColor(parentOf(x), BLACK);
                    setColor(parentOf(parentOf(x)), RED);
                    rotateLeft(parentOf(parentOf(x)));
                }
            }
        }
        root.color = BLACK;
    }

    /**
     * Delete node p, and then rebalance the tree.
     */
    internal function deleteEntry(p:TreeMapEntry):void {
        modCount++;
        _size--;

        // If strictly internal, copy successor's element to p and then make p
        // point to successor.
        if(p.left != null && p.right != null) {
            var s:TreeMapEntry = successor(p);
            p.key = s.key;
            p.value = s.value;
            p = s;
        } // p has 2 children

        // Start fixup at replacement node, if it exists.
        var replacement:TreeMapEntry = (p.left != null ? p.left : p.right);

        if(replacement != null) {
            // Link replacement to parent
            replacement.parent = p.parent;
            if(p.parent == null)
                root = replacement;
            else
                if(p == p.parent.left)
                    p.parent.left = replacement;
                else
                    p.parent.right = replacement;

            // Null out links so they are OK to use by fixAfterDeletion.
            p.left = p.right = p.parent = null;

            // Fix replacement
            if(p.color == BLACK)
                fixAfterDeletion(replacement);
        }
        else {
            if(p.parent == null) { // return if we are the only node.
                root = null;
            }
            else { //  No children. Use self as phantom replacement and unlink.
                if(p.color == BLACK)
                    fixAfterDeletion(p);

                if(p.parent != null) {
                    if(p == p.parent.left)
                        p.parent.left = null;
                    else
                        if(p == p.parent.right)
                            p.parent.right = null;
                    p.parent = null;
                }
            }
        }
    }

    /** From CLR */
    private function fixAfterDeletion(x:TreeMapEntry):void {
        var sib:TreeMapEntry;
        while(x != root && colorOf(x) == BLACK) {
            if(x == leftOf(parentOf(x))) {
                sib = rightOf(parentOf(x));

                if(colorOf(sib) == RED) {
                    setColor(sib, BLACK);
                    setColor(parentOf(x), RED);
                    rotateLeft(parentOf(x));
                    sib = rightOf(parentOf(x));
                }

                if(colorOf(leftOf(sib)) == BLACK &&
                   colorOf(rightOf(sib)) == BLACK) {
                    setColor(sib, RED);
                    x = parentOf(x);
                }
                else {
                    if(colorOf(rightOf(sib)) == BLACK) {
                        setColor(leftOf(sib), BLACK);
                        setColor(sib, RED);
                        rotateRight(sib);
                        sib = rightOf(parentOf(x));
                    }
                    setColor(sib, colorOf(parentOf(x)));
                    setColor(parentOf(x), BLACK);
                    setColor(rightOf(sib), BLACK);
                    rotateLeft(parentOf(x));
                    x = root;
                }
            }
            else { // symmetric
                sib = leftOf(parentOf(x));

                if(colorOf(sib) == RED) {
                    setColor(sib, BLACK);
                    setColor(parentOf(x), RED);
                    rotateRight(parentOf(x));
                    sib = leftOf(parentOf(x));
                }

                if(colorOf(rightOf(sib)) == BLACK &&
                   colorOf(leftOf(sib)) == BLACK) {
                    setColor(sib, RED);
                    x = parentOf(x);
                }
                else {
                    if(colorOf(leftOf(sib)) == BLACK) {
                        setColor(rightOf(sib), BLACK);
                        setColor(sib, RED);
                        rotateLeft(sib);
                        sib = leftOf(parentOf(x));
                    }
                    setColor(sib, colorOf(parentOf(x)));
                    setColor(parentOf(x), BLACK);
                    setColor(leftOf(sib), BLACK);
                    rotateRight(parentOf(x));
                    x = root;
                }
            }
        }

        setColor(x, BLACK);
    }

    /** Intended to be called only from TreeSet.addAll */
    internal function addAllForTreeSet(set:SortedSet, defaultVal:*):void {
        buildFromSorted(set.size(), set.iterator(), /*null, */defaultVal);
    }

    /**
     * Linear time tree building algorithm from sorted data.  Can accept keys
     * and/or values from iterator or stream. This leads to too many
     * parameters, but seems better than alternatives.  The four formats
     * that this method accepts are:
     *
     *    1) An iterator of Map.Entries.  (it != null, defaultVal == null).
     *    2) An iterator of keys.         (it != null, defaultVal != null).
     *    3) A stream of alternating serialized keys and values.
     *                                   (it == null, defaultVal == null).
     *    4) A stream of serialized keys. (it == null, defaultVal != null).
     *
     * It is assumed that the comparator of the TreeMap is already set prior
     * to calling this method.
     *
     * @param size the number of keys (or key-value pairs) to be read from
     *        the iterator or stream
     * @param it If non-null, new entries are created from entries
     *        or keys read from this iterator.
     *        possibly values read from this stream in serialized form.
     *        Exactly one of it and str should be non-null.
     * @param defaultVal if non-null, this default value is used for
     *        each value in the map.  If null, each value is read from
     *        iterator or stream, as described above.
     */
    private function buildFromSorted(size:int, it:Iterator, /*java.io.ObjectInputStream str, */ defaultVal:*):void {
        this._size = size;
        root = buildFromSortedImpl(0, 0, size - 1, computeRedLevel(size), it, /* str, */defaultVal);
    }

    /**
     * Recursive "helper method" that does the real work of the
     * previous method.  Identically named parameters have
     * identical definitions.  Additional parameters are documented below.
     * It is assumed that the comparator and size fields of the TreeMap are
     * already set prior to calling this method.  (It ignores both fields.)
     *
     * @param level the current level of tree. Initial call should be 0.
     * @param lo the first element index of this subtree. Initial should be 0.
     * @param hi the last element index of this subtree.  Initial should be size-1.
     * @param redLevel the level at which nodes should be red. Must be equal to computeRedLevel for tree of this size.
     * @param it
     * @param defaultVal
     */
    private final function buildFromSortedImpl(level:int, lo:int, hi:int, redLevel:int, it:Iterator, /*java.io.ObjectInputStream str,*/ defaultVal:*):TreeMapEntry {
        /*
         * Strategy: The root is the middlemost element. To get to it, we
         * have to first recursively construct the entire left subtree,
         * so as to grab all of its elements. We can then proceed with right
         * subtree.
         *
         * The lo and hi arguments are the minimum and maximum
         * indices to pull out of the iterator or stream for current subtree.
         * They are not actually indexed, we just proceed sequentially,
         * ensuring that items are extracted in corresponding order.
         */

        if(hi < lo)
            return null;

        var mid:int = (lo + hi) >>> 1;

        var left:TreeMapEntry = null;

        if(lo < mid)
            left = buildFromSortedImpl(level + 1, lo, mid - 1, redLevel, it, /*str, */defaultVal);

        // extract key and/or value from iterator or stream
        var key:*;
        var value:*;

        if(it != null) {
            if(defaultVal == null) {
                var entry:TreeMapEntry  = TreeMapEntry(it.next());
                key                     = entry.getKey();
                value                   = entry.getValue();
            }
            else {
                key     = it.next();
                value   = defaultVal;
            }
        }
        // use stream
//    else {
//        key = (K) str.readObject();
//        value = (defaultVal != null ? defaultVal : (V) str.readObject());
//    }

        var middle:TreeMapEntry = new TreeMapEntry(key, value, null);

        // color nodes in non-full bottommost level red
        if(level == redLevel)
            middle.color = RED;

        if(left != null) {
            middle.left = left;
            left.parent = middle;
        }

        if(mid < hi) {
            var right:TreeMapEntry = buildFromSortedImpl(level + 1, mid + 1, hi, redLevel, it, /*str, */defaultVal);
            middle.right = right;
            right.parent = middle;
        }

        return middle;
    }

    /**
     * Find the level down to which to assign all nodes BLACK.  This is the
     * last `full' level of the complete binary tree produced by
     * buildTree. The remaining nodes are colored RED. (This makes a `nice'
     * set of color assignments wrt future insertions.) This level number is
     * computed by finding the number of splits needed to reach the zeroeth
     * node. (The answer is ~lg(N), but in any case must be computed by same
     * quick O(lg(N)) loop.)
     */
    private static function computeRedLevel(sz:int):int {
        var level:int = 0;

        for(var m:int = sz - 1; m >= 0; m = m / 2 - 1)
            level++;

        return level;
    }
}

}
