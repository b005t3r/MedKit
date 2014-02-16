/**
 * User: booster
 * Date: 9/9/12
 * Time: 12:41
 */

package medkit.collection {

import flash.errors.IllegalOperationError;
import flash.errors.MemoryError;

import medkit.collection.iterator.Iterator;
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Equalable;
import medkit.object.ObjectUtil;
import medkit.string.StringBuilder;

public class AbstractCollection implements Collection {
    private static function finishToArray(r:Array, it:Iterator):Array {
        var i:int = r.length;

        while(it.hasNext()) {
            var cap:int = r.length;
            if(i == cap) {
                var newCap:int = ((cap / 2) + 1) * 3;
                if(newCap <= cap) { // integer overflow
                    if(cap == int.MAX_VALUE)
                        throw new MemoryError("Required array size too large");

                    newCap = int.MAX_VALUE;
                }
                r = ArrayUtil.copyOf(r, newCap);
            }
            r[i++] = it.next();
        }

        // trim if overallocated
        return (i == r.length) ? r : ArrayUtil.copyOf(r, i);
    }

    public function iterator():Iterator {
        throw new DefinitionError("This method is not implemented");
    }

    public function size():int {
        throw new DefinitionError("This method is not implemented");
    }

    public function equals(object:Equalable):Boolean {
        throw new DefinitionError("This method is not implemented");
    }

    public function hashCode():int {
        throw new DefinitionError("This method is not implemented");
    }

    public function clone(cloningContext:CloningContext = null):Cloneable {
        throw new DefinitionError("This method is not implemented");
    }

    public function add(o:*):Boolean {
        throw new IllegalOperationError("This operation is not supported by this Collection");
    }

    public function addAll(c:Collection):Boolean {
        var modified:Boolean = false;
        var e:Iterator = c.iterator();

        while (e.hasNext()) {
            if (add(e.next()))
                modified = true;
        }

        return modified;
    }

    public function clear():void {
        var e:Iterator = iterator();

        while (e.hasNext()) {
            e.next();
            e.remove();
        }
    }

    public function contains(o:*):Boolean {
        var e:Iterator = iterator();

        if(o == null) {
            while(e.hasNext())
                if(e.next() == null)
                    return true;
        }
        else {
            while(e.hasNext())
                if(ObjectUtil.equals(o, e.next()))
                    return true;
        }

        return false;
    }

    public function containsAll(c:Collection):Boolean {
        var e:Iterator = c.iterator();

        while (e.hasNext())
            if (! contains(e.next()))
                return false;

        return true;
    }

    public function isEmpty():Boolean {
        return size() == 0;
    }

    public function remove(o:*):Boolean {
        var e:Iterator = iterator();

        if(o == null) {
            while(e.hasNext()) {
                if(e.next() == null) {
                    e.remove();

                    return true;
                }
            }
        }
        else {
            while(e.hasNext()) {
                if(ObjectUtil.equals(o, e.next())) {
                    e.remove();

                    return true;
                }
            }
        }

        return false;
    }

    public function removeAll(c:Collection):Boolean {
        var modified:Boolean = false;

        var e:Iterator = iterator();

        while(e.hasNext()) {
            if(c.contains(e.next())) {
                e.remove();

                modified = true;
            }
        }

        return modified;
    }

    public function retainAll(c:Collection):Boolean {
        var modified:Boolean = false;

        var e:Iterator = iterator();

        while(e.hasNext()) {
            if(! c.contains(e.next())) {
                e.remove();

                modified = true;
            }
        }

        return modified;
    }

    public function toArray():Array {
        // Estimate size of array; be prepared to see more or fewer elements
        var r:Array     = new Array(size());
        var it:Iterator = iterator();

        for (var i:int = 0; i < r.length; i++) {
            if (! it.hasNext()) // fewer elements than expected
                return ArrayUtil.copyOf(r, i);

            r[i] = it.next();
        }

        return it.hasNext() ? finishToArray(r, it) : r;
    }

    public function toString():String {
        var i:Iterator = iterator();

        if (! i.hasNext())
            return "[]";

        var sb:StringBuilder = new StringBuilder();

        sb.append('[');

        while(true) {
            var e:* = i.next();

            sb.append(e === this ? "(this Collection)" : e);

            if (! i.hasNext())
                break;

            sb.append(", ");
        }

        return sb.append(']').toString();
    }
}
}
