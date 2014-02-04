/**
 * User: booster
 * Date: 2/16/13
 * Time: 17:14
 */

package medkit.object {
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;

public class SelectiveCloneTest {
    private var model:PlaneModel;

    [Before]
    public function setUp():void {
        model = new PlaneModel();
    }

    [After]
    public function tearDown():void {
        model = null;
    }

    [Test]
    public function testCloneAll():void {
        var deepCloneContext:SelectiveCloningContext = new SelectiveCloningContext(null);

        var deepClone:PlaneModel = ObjectUtil.clone(model, deepCloneContext);

        assertTrue(deepClone.equals(model));
        assertFalse(deepClone === model);

        assertTrue(deepClone.hull.equals(model.hull));
        assertTrue(deepClone.leftWing.equals(model.leftWing));
        assertTrue(deepClone.rightWing.equals(model.rightWing));

        assertFalse(deepClone.hull === model.hull);
        assertFalse(deepClone.leftWing === model.leftWing);
        assertFalse(deepClone.rightWing === model.rightWing);

        assertTrue(deepClone.hull.cabin.equals(model.hull.cabin));
        assertTrue(deepClone.hull.propeller.equals(model.hull.propeller));

        assertFalse(deepClone.hull.cabin === model.hull.cabin);
        assertFalse(deepClone.hull.propeller === model.hull.propeller);
    }

    [Test]
    public function testCloneShallowHull():void {
        var partialCloningContext:SelectiveCloningContext = new SelectiveCloningContext("ShallowHull");

        var partialClone:PlaneModel = ObjectUtil.clone(model, partialCloningContext);

        assertTrue(partialClone.equals(model));
        assertFalse(partialClone === model);

        assertTrue(partialClone.hull.equals(model.hull));
        assertTrue(partialClone.leftWing.equals(model.leftWing));
        assertTrue(partialClone.rightWing.equals(model.rightWing));

        assertFalse(partialClone.hull === model.hull);
        assertFalse(partialClone.leftWing === model.leftWing);
        assertFalse(partialClone.rightWing === model.rightWing);

        assertTrue(partialClone.hull.cabin.equals(model.hull.cabin));
        assertTrue(partialClone.hull.propeller.equals(model.hull.propeller));

        assertTrue(partialClone.hull.cabin === model.hull.cabin);
        assertTrue(partialClone.hull.propeller === model.hull.propeller);
    }

    [Test]
    public function testCloneRightWingTest():void {
        var partialCloningContext:SelectiveCloningContext = new SelectiveCloningContext("RightWingTest");
        partialCloningContext.setObjectCloningType(model.leftWing, CloningType.NullClone);

        var partialClone:PlaneModel = ObjectUtil.clone(model, partialCloningContext);

        assertFalse(partialClone.equals(model));
        assertFalse(partialClone === model);

        assertTrue(partialClone.rightWing.equals(model.rightWing));

        assertTrue(partialClone.hull === null);
        assertTrue(partialClone.leftWing === null);
        assertFalse(partialClone.rightWing === model.rightWing);
    }
}

}

import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Equalable;
import medkit.object.ObjectUtil;

class PlaneModel implements Equalable, Cloneable {
    private var _hull:Hull;
    private var _leftWing:Wing;
    private var _rightWing:Wing;

    public function PlaneModel() {
        _hull = new Hull();
        _leftWing = new Wing(4);
        _rightWing = new Wing(4);
    }

    public function get hull():Hull         { return _hull; }
    public function get leftWing():Wing     { return _leftWing; }
    public function get rightWing():Wing    { return _rightWing; }

    public function equals(object:Equalable):Boolean {
        if(object is PlaneModel) {
            var plane:PlaneModel = object as PlaneModel;

            return ObjectUtil.equals(this._hull, plane._hull)
                && ObjectUtil.equals(this._leftWing, plane._leftWing)
                && ObjectUtil.equals(this._rightWing, plane._rightWing)
            ;
        }

        return false;
    }

    public function clone(cloningContext:CloningContext = null):Cloneable {
        var clone:PlaneModel;

        if(cloningContext != null) {
            clone = cloningContext.fetchClone(this);

            if(clone != null)
                return clone;

            clone            = cloningContext.registerClone(this, new PlaneModel());
            clone._hull      = ObjectUtil.clone(this._hull, cloningContext);
            clone._leftWing  = ObjectUtil.clone(this._leftWing, cloningContext);
            clone._rightWing = ObjectUtil.clone(this._rightWing, cloningContext);
        }
        else {
            clone = new PlaneModel();

            clone._hull      = this._hull;
            clone._leftWing  = this._leftWing;
            clone._rightWing = this._rightWing;
        }

        return clone;
    }
}

[ShallowClone("ShallowHull")]
[NullClone("RightWingTest")]
class Hull implements Equalable, Cloneable {
    private var _cabin:Cabin;
    private var _propeller:Propeller;

    public function Hull() {
        _cabin       = new Cabin(3);
        _propeller   = new Propeller(4);
    }

    public function get cabin():Cabin {
        return _cabin;
    }

    public function get propeller():Propeller {
        return _propeller;
    }

    public function equals(object:Equalable):Boolean {
        if(object is Hull) {
            var hull:Hull = object as Hull;

            return ObjectUtil.equals(this._cabin, hull._cabin)
                && ObjectUtil.equals(this._propeller, hull._propeller)
            ;
        }

        return false;
    }

    public function clone(cloningContext:CloningContext = null):Cloneable {
        var clone:Hull;

        if(cloningContext != null) {
            clone = cloningContext.fetchClone(this);

            if(clone != null)
                return clone;

            clone           = cloningContext.registerClone(this, new Hull());
            clone._cabin     = ObjectUtil.clone(this._cabin, cloningContext);
            clone._propeller = ObjectUtil.clone(this._propeller, cloningContext);
        }
        else {
            clone           = new Hull();
            clone._cabin     = this._cabin;
            clone._propeller = this._propeller;
        }

        return clone;
    }
}

class Wing implements Equalable, Cloneable {
    private var length:int;

    public function Wing(length:int) {
        this.length = length;
    }

    public function equals(object:Equalable):Boolean {
        if(object is Wing) {
            var wing:Wing = object as Wing;

            return ObjectUtil.equals(this.length, wing.length);
        }

        return false;
    }

    public function clone(cloningContext:CloningContext = null):Cloneable {
        var clone:Wing;

        if(cloningContext != null) {
            clone = cloningContext.fetchClone(this);

            if(clone != null)
                return clone;

            clone = cloningContext.registerClone(this, new Wing(-1));
            clone.length = ObjectUtil.clone(this.length, cloningContext);
        }
        else {
            clone = new Wing(-1);
            clone.length = this.length;
        }

        return clone;
    }
}

class Cabin implements Equalable, Cloneable {
    private var seats:int;

    public function Cabin(seats:int) {
        this.seats = seats;
    }

    public function equals(object:Equalable):Boolean {
        if(object is Cabin) {
            var cabin:Cabin = object as Cabin;

            return this.seats == cabin.seats;
        }

        return false;
    }

    public function clone(cloningContext:CloningContext = null):Cloneable {
        var clone:Cabin;

        if(cloningContext != null) {
            clone = cloningContext.fetchClone(this);

            if(clone != null)
                return clone;

            clone = cloningContext.registerClone(this, new Cabin(this.seats));
        }
        else {
            clone = new Cabin(this.seats);
        }

        return clone;
    }
}

class Propeller implements Equalable, Cloneable {
    private var arms:int;

    public function Propeller(arms:int) {
        this.arms = arms;
    }

    public function equals(object:Equalable):Boolean {
        if(object is Propeller) {
            var propeller:Propeller = object as Propeller;

            return this.arms == propeller.arms;
        }

        return false;
    }

    public function clone(cloningContext:CloningContext = null):Cloneable {
        var clone:Propeller;

        if(cloningContext != null) {
            clone = cloningContext.fetchClone(this);

            if(clone != null)
                return clone;

            clone = cloningContext.registerClone(this, new Propeller(arms));
        }
        else {
            clone = new Propeller(arms);
        }

        return clone;
    }
}
