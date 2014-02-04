/**
 * User: booster
 * Date: 11/17/12
 * Time: 10:23
 */

package medkit.collection {
import medkit.collection.iterator.Iterator;
import medkit.collection.iterator.ListIterator;
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.ObjectUtil;

public class LinkedList extends AbstractSequentialList {
    internal var header:LinkedListEntry = new LinkedListEntry(null, null, null);
    internal var _size:int              = 0;

    public function LinkedList() {
        header.next = header.previous = header;
    }

    public function getFirst():* {
        if(_size == 0)
            throw new RangeError();

        return header.next.element;
    }

    public function getLast():* {
        if(_size == 0)
            throw new RangeError();

        return header.previous.element;
    }

    public function removeFirst():* {
        return removeEntry(header.next);
    }

    public function removeLast():* {
        return removeEntry(header.previous);
    }

    public function addFirst(e:*):void {
        addBeforeEntry(e, header.next);
    }

    public function addLast(e:*):void {
        addBeforeEntry(e, header);
    }

    override public function contains(o:*):Boolean {
        return indexOf(o) != -1;
    }

    override public function size():int {
        return _size;
    }

    override public function add(e:*):Boolean {
        addBeforeEntry(e, header);
        return true;
    }

    override public function remove(o:*):Boolean{
        if(o == null) {
            for(var e:LinkedListEntry = header.next; e != header; e = e.next) {
                if(e.element == null) {
                    removeEntry(e);

                    return true;
                }
            }
        }
        else {
            for(var en:LinkedListEntry = header.next; en != header; en = en.next) {
                if(ObjectUtil.equals(o, en.element)) {
                    removeEntry(en);

                    return true;
                }
            }
        }

        return false;
    }

    override public function addAll(c:Collection):Boolean {
        return addAllAt(_size, c);
    }

    override public function addAllAt(index:int, c:Collection):Boolean {
        if(index < 0 || index > _size)
            throw new RangeError("Index: " + index + ", Size: " + _size);

        var numNew:int = c.size();

        if(numNew == 0)
            return false;

        modCount++;

        var successor:LinkedListEntry   = (index == _size ? header : entry(index));
        var predecessor:LinkedListEntry = successor.previous;
        var i:Iterator                  = c.iterator();

        while (i.hasNext()) {
            var e:LinkedListEntry   = new LinkedListEntry(i.next(), successor, predecessor);
            predecessor.next        = e;
            predecessor             = e;
        }

        successor.previous = predecessor;

        _size += numNew;

        return true;
    }

    override public function clear():void {
        var e:LinkedListEntry = header.next;

        while (e != header) {
            var next:LinkedListEntry  = e.next;
            e.next          = e.previous = null;
            e.element       = null;
            e               = next;
        }

        header.next = header.previous = header;
        _size = 0;
        modCount++;
    }

    override public function get (index:int):* {
        return entry(index).element;
    }

    override public function set (index:int, o:*):* {
        var e:LinkedListEntry     = entry(index);
        var oldVal:*    = e.element;
        e.element       = o;

        return oldVal;
    }

    override public function addAt(index:int, o:*):void {
        addBeforeEntry(o, (index == _size ? header : entry(index)));
    }

    override public function removeAt(index:int):* {
        return removeEntry(entry(index));
    }

    override public function indexOf(o:*):int {
        var index:int = 0;

        if(o == null) {
            for(var e:LinkedListEntry = header.next; e != header; e = e.next) {
                if(e.element == null)
                    return index;

                index++;
            }
        }
        else {
            for(var en:LinkedListEntry = header.next; en != header; en = en.next) {
                if(ObjectUtil.equals(o, en.element))
                    return index;

                index++;
            }
        }

        return -1;
    }

    override public function lastIndexOf(o:*):int {
        var index:int = _size;

        if(o == null) {
            for(var e:LinkedListEntry = header.previous; e != header; e = e.previous) {
                --index;

                if(e.element == null)
                    return index;
            }
        }
        else {
            for(var en:LinkedListEntry = header.previous; en != header; en = en.previous) {
                --index;

                if(ObjectUtil.equals(o, en.element))
                    return index;
            }
        }

        return -1;
    }

    override public function listIterator(index:int = 0):ListIterator {
        return new LinkedListListItr(this, index);
    }

    override public function clone(cloningContext:CloningContext = null):Cloneable {
        if(cloningContext != null && cloningContext.isBeingCloned(this))
            return cloningContext.fetchClone(this);

        var clone:LinkedList = cloningContext == null
            ? new LinkedList()
            : cloningContext.isCloneRegistered(this)
                ? cloningContext.fetchClone(this)
                : cloningContext.registerClone(this, new LinkedList())
        ;

        // put clone into "virgin" state
        clone.header    = new LinkedListEntry(null, null, null);
        clone._size     = 0;
        clone.header.next = clone.header.previous = clone.header;

        // initialize clone with our elements
        for (var e:LinkedListEntry = header.next; e != header; e = e.next) {
            var elem:* = cloningContext != null ? ObjectUtil.clone(e.element, cloningContext) : e.element;

            clone.add(elem);
        }

        return clone;
    }

    override public function toArray():Array {
        var result:Array    = new Array(_size);
        var i:int           = 0;

        for (var e:LinkedListEntry = header.next; e != header; e = e.next)
            result[i++] = e.element;

        return result;
    }

    private final function entry(index:int):LinkedListEntry {
        if(index < 0 || index >= _size)
            throw new RangeError("Index: " + index + ", Size: " + _size);

        var e:LinkedListEntry = header;

        if(index < (_size >> 1)) {
            for(var i:int = 0; i <= index; ++i)
                e = e.next;
        }
        else {
            for(var j:int = _size; j > index; --j)
                e = e.previous;
        }

        return e;
    }

    internal final function addBeforeEntry(e:*, entry:LinkedListEntry):LinkedListEntry {
        var newEntry:LinkedListEntry    = new LinkedListEntry(e, entry, entry.previous);
        newEntry.previous.next          = newEntry;
        newEntry.next.previous          = newEntry;

        _size++;
        modCount++;

        return newEntry;
    }

    internal final function removeEntry(e:LinkedListEntry):* {
        if (e == header)
            throw new RangeError();

        var result:*        = e.element;
        e.previous.next     = e.next;
        e.next.previous     = e.previous;
        e.next              = e.previous = null;
        e.element           = null;

        _size--;
        modCount++;

        return result;
    }
}

}

