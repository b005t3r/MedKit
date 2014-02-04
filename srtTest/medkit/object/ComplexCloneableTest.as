/**
 * User: booster
 * Date: 11/18/12
 * Time: 10:22
 */
package medkit.object {

import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertNotNull;
import org.flexunit.asserts.assertTrue;

public class ComplexCloneableTest {

    [Test]
    public function testSimpleRetainLoop():void {
        var subjectA:TestSubject = new TestSubject();
        var subjectB:TestSubject = new TestSubject();

        subjectA.leftSubject = subjectB;
        subjectB.leftSubject = subjectA;

        var shallowClone:TestSubject   = ObjectUtil.clone(subjectA, null);
        var deepClone:TestSubject      = ObjectUtil.clone(subjectA, new CloningContext());

        assertNotNull(shallowClone);
        assertNotNull(deepClone);

        assertTrue(shallowClone.leftSubject === subjectB);

        assertFalse(deepClone.leftSubject === subjectB);
        assertTrue(deepClone.leftSubject.leftSubject === deepClone);
    }

    [Test]
    public function testThreeElementRetainLoop():void {
        var subjectA:TestSubject = new TestSubject();
        var subjectB:TestSubject = new TestSubject();
        var subjectC:TestSubject = new TestSubject();

        // C <- B <- A <- C ...
        subjectA.leftSubject = subjectB;
        subjectB.leftSubject = subjectC;
        subjectC.leftSubject = subjectA;

        var shallowClone:TestSubject   = ObjectUtil.clone(subjectA, null);
        var deepClone:TestSubject      = ObjectUtil.clone(subjectA, new CloningContext());

        assertNotNull(shallowClone);
        assertNotNull(deepClone);

        assertTrue(shallowClone.leftSubject === subjectB);
        assertTrue(shallowClone.leftSubject.leftSubject === subjectC);
        assertTrue(shallowClone.leftSubject.leftSubject.leftSubject === subjectA);

        assertTrue(deepClone === deepClone.leftSubject.leftSubject.leftSubject);

        // B -> A -> C -> B
        subjectB.rightSubject = subjectA;
        subjectA.rightSubject = subjectC;
        subjectC.rightSubject = subjectB;

        shallowClone    = ObjectUtil.clone(subjectA, null);
        deepClone       = ObjectUtil.clone(subjectA, new CloningContext());

        assertNotNull(shallowClone);
        assertNotNull(deepClone);

        assertTrue(shallowClone.leftSubject === subjectB);
        assertTrue(shallowClone.leftSubject.leftSubject === subjectC);
        assertTrue(shallowClone.leftSubject.leftSubject.leftSubject === subjectA);

        assertTrue(deepClone === deepClone.leftSubject.leftSubject.leftSubject);

        assertTrue(shallowClone.rightSubject === subjectC);
        assertTrue(shallowClone.rightSubject.leftSubject === subjectA);
        assertTrue(shallowClone.rightSubject.rightSubject === subjectB);
        assertTrue(shallowClone.rightSubject.leftSubject.leftSubject === subjectB);
        assertTrue(shallowClone.rightSubject.rightSubject.leftSubject === subjectC);
        assertTrue(shallowClone.rightSubject.leftSubject.rightSubject=== subjectC);
        assertTrue(shallowClone.rightSubject.rightSubject.rightSubject=== subjectA);

        assertTrue(deepClone === deepClone.rightSubject.rightSubject.rightSubject);
        assertTrue(deepClone.leftSubject === deepClone.rightSubject.rightSubject);
        assertTrue(deepClone.leftSubject.leftSubject === deepClone.rightSubject);
    }
}

}

import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Equalable;
import medkit.object.ObjectUtil;

internal class TestSubject implements Cloneable, Equalable {
    private var _leftSubject:TestSubject;
    private var _rightSubject:TestSubject;

    public function TestSubject(leftSubject:TestSubject = null, rightSubject:TestSubject = null) {
        this._leftSubject    = leftSubject;
        this._rightSubject   = rightSubject;
    }

    public function get leftSubject():TestSubject {
        return _leftSubject;
    }

    public function set leftSubject(value:TestSubject):void {
        _leftSubject = value;
    }

    public function get rightSubject():TestSubject {
        return _rightSubject;
    }

    public function set rightSubject(value:TestSubject):void {
        _rightSubject = value;
    }

    public function clone(cloningContext:CloningContext = null):Cloneable {
        if(cloningContext != null && cloningContext.isBeingCloned(this))
            return cloningContext.fetchClone(this);

        var clone:TestSubject = cloningContext == null
            ? new TestSubject()
            : cloningContext.isCloneRegistered(this)
                ? cloningContext.fetchClone(this)
                : cloningContext.registerClone(this, new TestSubject())
        ;

        clone.leftSubject   = cloningContext != null ? ObjectUtil.clone(this.leftSubject, cloningContext) : this.leftSubject;
        clone.rightSubject  = cloningContext != null ? ObjectUtil.clone(this.rightSubject, cloningContext) : this.rightSubject;

        return clone;
    }

    public function equals(object:Equalable):Boolean {
        if(! (object is TestSubject))
            return false;

        var subject:TestSubject = object as TestSubject;

        return ObjectUtil.equals(this.leftSubject, subject.leftSubject)
            && ObjectUtil.equals(this.rightSubject, subject.rightSubject);
    }
}
