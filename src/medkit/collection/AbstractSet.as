/**
 * User: booster
 * Date: 11/14/12
 * Time: 16:52
 */

package medkit.collection {
import medkit.collection.iterator.Iterator;
import medkit.object.Equalable;
import medkit.object.ObjectUtil;

public class AbstractSet extends AbstractCollection implements Set {
    public function AbstractSet() {
    }

    override public function equals(object:Equalable):Boolean {
        if (object == this)
            return true;

        if (! (object is Set))
            return false;

        var c:Collection = object as Collection;

        if (c.size() != size())
            return false;

        return containsAll(c);
    }

    override public function hashCode():int {
        var h:int       = 0;
        var i:Iterator  = iterator();

        while (i.hasNext()) {
            var obj:* = i.next();

            if(obj != null)
                h += ObjectUtil.hashCode(obj);
        }

        return h;
    }

    override public function removeAll(c:Collection):Boolean {
        return super.removeAll(c);
    }
}

}
