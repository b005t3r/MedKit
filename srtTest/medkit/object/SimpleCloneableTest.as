/**
 * User: booster
 * Date: 11/17/12
 * Time: 13:58
 */

package medkit.object {

import org.flexunit.asserts.assertTrue;

public class SimpleCloneableTest {
    [Test]
    public function testSimpleClone():void {
        var subjectA:TestSubject        = new TestSubject();
        subjectA.name                   = "Subject A";
        var shallowClone:TestSubject    = ObjectUtil.clone(subjectA, new CloningContext());
        var deepClone:TestSubject       = ObjectUtil.clone(subjectA, new CloningContext());

        assertTrue(subjectA.equals(shallowClone));
        assertTrue(subjectA.equals(deepClone));
        assertTrue(shallowClone.equals(deepClone));
        assertTrue(deepClone.equals(shallowClone));
    }
}

}

import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Equalable;
import medkit.object.ObjectUtil;

class TestSubject implements Cloneable, Equalable {
    private var _name:String;

    public function TestSubject() {
    }

    public function clone(cloningContext:CloningContext = null):Cloneable {
        if(cloningContext != null && cloningContext.isCloneRegistered(this))
            return cloningContext.fetchClone(this);

        var clone:TestSubject = cloningContext == null
            ? new TestSubject()
            : cloningContext.isCloneRegistered(this)
                ? cloningContext.fetchClone(this)
                : cloningContext.registerClone(this, new TestSubject())
        ;

        clone.name = cloningContext != null ? ObjectUtil.clone(this.name, cloningContext) : this.name;

        return clone;
    }

    public function equals(object:Equalable):Boolean {
        if(! object is TestSubject)
            return false;

        var subject:TestSubject = object as TestSubject;

        if(this.name != subject.name)
            return false;

        return true;
    }

    public function get name():String           { return _name; }
    public function set name(name:String):void  { _name = name; }
}
