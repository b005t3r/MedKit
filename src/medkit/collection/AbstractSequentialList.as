/**
 * User: booster
 * Date: 11/17/12
 * Time: 10:27
 */

package medkit.collection {
import medkit.collection.iterator.Iterator;
import medkit.collection.iterator.ListIterator;

public class AbstractSequentialList extends AbstractList {
    public function AbstractSequentialList() {
    }

    override public function get (index:int):* {
        try {
            return listIterator(index).next();
        }
        catch (e:RangeError) {
            throw new RangeError("Index: " + index);
        }
    }

    override public function set (index:int, o:*):* {
        try {
            var e:ListIterator  = listIterator(index);
            var oldVal:*        = e.next();

            e.set(o);

            return oldVal;
        }
        catch (e:RangeError) {
            throw new RangeError("Index: " + index);
        }
    }

    override public function addAt(index:int, o:*):void {
        try {
            listIterator(index).add(o);
        }
        catch (e:RangeError) {
            throw new RangeError("Index: " + index);
        }
    }

    override public function removeAt(index:int):* {
        try {
            var e:ListIterator  = listIterator(index);
            var outCast:*       = e.next();

            e.remove();

            return outCast;
        }
        catch (e:RangeError) {
            throw new RangeError("Index: " + index);
        }
    }

    override public function addAllAt(index:int, c:Collection):Boolean {
        var modified:Boolean = false;

        try {
            var e1:ListIterator     = listIterator(index);
            var e2:Iterator         = c.iterator();

            while (e2.hasNext()) {
                e1.add(e2.next());
                modified = true;
            }
        }
        catch (e:RangeError) {
            throw new RangeError("Index: " + index);
        }
        finally {
            return modified;
        }
    }

    override public function iterator():Iterator {
        return listIterator();
    }

    override public function listIterator(index:int = 0):ListIterator {
        throw new DefinitionError("This method is not implemented");
    }
}

}
