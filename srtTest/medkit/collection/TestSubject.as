/**
 * User: booster
 * Date: 12/8/12
 * Time: 11:38
 */

package medkit.collection {

import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Comparable;
import medkit.object.Equalable;
import medkit.object.Hashable;
import medkit.object.ObjectUtil;

public class TestSubject implements Comparable, Hashable, Equalable, Cloneable {
    private var _str:String;

    public function TestSubject(str:String) {
        this._str = str;
    }

    public function hashCode():int {
        return ObjectUtil.hashCode(_str);
    }

    public function equals(object:Equalable):Boolean {
        if(! (object is TestSubject))
            return false;

        var subject:TestSubject = object as TestSubject;

        return this._str == subject._str;
    }

    public function clone(cloningContext:CloningContext = null):Cloneable {
        if(cloningContext != null && cloningContext.isBeingCloned(this))
            return cloningContext.fetchClone(this);

        var clone:TestSubject = cloningContext == null
            ? new TestSubject(null)
            : cloningContext.isCloneRegistered(this)
                ? cloningContext.fetchClone(this)
                : cloningContext.registerClone(this, new TestSubject(null))
        ;

        clone._str = cloningContext != null ? ObjectUtil.clone(this._str, cloningContext) : this._str;

        return clone;
    }

    public function compareTo(object:Comparable):int {
        if(! (object is TestSubject))
            throw new TypeError("object is not a TestSubject instance");

        var ts:TestSubject = object as TestSubject;

        return ObjectUtil.compare(_str, ts._str);
    }

    public function get str():String {
        return _str;
    }

    public function toString():String {
        return "TestSubject(" + str +")";
    }
}

}
