/**
 * User: booster
 * Date: 9/9/12
 * Time: 16:01
 */

package medkit.collection {

import flash.errors.IllegalOperationError;

import medkit.collection.iterator.Iterator;
import medkit.collection.iterator.ListIterator;
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Equalable;
import medkit.object.Hashable;
import medkit.object.ObjectUtil;

public class AbstractList extends AbstractCollection implements List, Hashable {
    internal var modCount:int = 0;

    public function get(index:int):* {
        throw new DefinitionError("This method is not implemented");
    }

    public function set(index:int, o:*):* {
        throw new IllegalOperationError("This operation is not supported by this Collection");
    }

    public function addAt(index:int, o:*):void {
        throw new IllegalOperationError("This operation is not supported by this Collection");
    }

    public function removeAt(index:int):* {
        throw new IllegalOperationError("This operation is not supported by this Collection");
    }

    override public function size():int {
        throw new DefinitionError("This method is not implemented");
    }

    override public function add(o:*):Boolean {
        addAt(size(), o);

        return true;
    }

    override public function clear():void {
        removeRangeInternal(0, size());
    }

    public function addAllAt(index:int, c:Collection):Boolean {
        rangeCheckForAdd(index);
        var modified:Boolean = false;
        var e:Iterator = c.iterator();

        while(e.hasNext()) {
            addAt(index++, e.next());
            modified = true;
        }

        return modified;
    }

    public function indexOf(o:*):int {
        var e:ListIterator = listIterator();
        if(o == null) {
            while(e.hasNext())
                if(e.next() == null)
                    return e.previousIndex();
        }
        else {
            while(e.hasNext())
                if(o.equals(e.next()))
                    return e.previousIndex();
        }
        return -1;
    }

    public function lastIndexOf(o:*):int {
        var e:ListIterator = listIterator(size());

        if(o == null) {
            while(e.hasPrevious())
                if(e.previous() == null)
                    return e.nextIndex();
        }
        else {
            while(e.hasPrevious())
                if(o.equals(e.previous()))
                    return e.nextIndex();
        }

        return -1;
    }

    override public function iterator():Iterator {
        return new AbstractListItr(this);
    }

    public function listIterator(index:int = 0):ListIterator {
        return new AbstractListListItr(this, index);
    }

    public function subList(fromIndex:int, toIndex:int):List {
        return new SubList(this, fromIndex, toIndex);
    }

    override public function equals(o:Equalable):Boolean {
        if (o === this)
            return true;

        if (! (o is List))
            return false;

        var list:List       = o as List;
        var e1:ListIterator = listIterator();
        var e2:ListIterator = list.listIterator();

        while(e1.hasNext() && e2.hasNext()) {
            var o1:* = e1.next();
            var o2:* = e2.next();

            if(! ObjectUtil.equals(o1, o2))
                return false;
        }

        return ! (e1.hasNext() || e2.hasNext());
    }

    override public function hashCode():int {
        var hashCode:int = 1;

        var e:*;
        var it:Iterator = iterator();

        while(it.hasNext()) {
            e = it.next();

            hashCode = 31 * hashCode + ObjectUtil.hashCode(e);
        }

        return hashCode;
    }

    override public function clone(cloningContext:CloningContext = null):Cloneable {
        throw new DefinitionError("This method is not implemented");
    }

    public function removeRange(fromIndex:int, toIndex:int):void {
        rangeCheckInternal(fromIndex, toIndex, size());
        removeRangeInternal(fromIndex, toIndex);
    }

    internal function removeRangeInternal(fromIndex:int, toIndex:int):void {
        var it:ListIterator = listIterator(fromIndex);

        for (var i:int = 0, n:int = toIndex - fromIndex; i < n; i++) {
            it.next();
            it.remove();
        }
    }

    private final function rangeCheckForAdd(index:int):void {
        if(index < 0 || index > size())
            throw new RangeError(outOfBoundsMsg(index));
    }

    internal final function rangeCheckInternal(fromIndex:int, toIndex:int, size:int):void {
        if (fromIndex < 0)
            throw new RangeError("fromIndex = " + fromIndex);
        if (toIndex > size)
            throw new RangeError("toIndex = " + toIndex);
        if (fromIndex > toIndex)
            throw new RangeError("fromIndex(" + fromIndex + ") > toIndex(" + toIndex + ")");
    }

    private final function outOfBoundsMsg(index:int):String {
        return "Index: " + index + ", Size: " + size();
    }
}

}
