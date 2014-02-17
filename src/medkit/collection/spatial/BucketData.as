/**
 * User: booster
 * Date: 17/02/14
 * Time: 9:18
 */
package medkit.collection.spatial {
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Equalable;
import medkit.object.Hashable;
import medkit.object.ObjectUtil;

public class BucketData implements Equalable, Hashable, Cloneable {
    public var object:*;
    public var leftRight:Vector.<int>;

    public function BucketData(object:*, leftRight:Vector.<int>) {
        this.object = object;
        this.leftRight = new Vector.<int>(leftRight.length, true);

        var count:int = leftRight.length;
        for(var i:int = 0; i < count; i++)
            this.leftRight[i] = leftRight[i];
    }

    public function equals(o:Equalable):Boolean {
        var data:BucketData = o as BucketData;

        if(data == null) return false;

        return ObjectUtil.equals(object, data.object);
    }

    public function hashCode():int {
        var hashCode:int = 1;

        var count:int = leftRight.length;
        for(var i:int = 0; i < count; i++) {
            var v:int = leftRight[i];

            hashCode += hashCode * 31 + v;
        }

        return hashCode;
    }

    public function clone(cloningContext:CloningContext = null):Cloneable {
        if(cloningContext != null && cloningContext.isBeingCloned(this))
            return cloningContext.fetchClone(this);

        var clone:BucketData = cloningContext == null
                ? new BucketData(object, leftRight)
                : cloningContext.isCloneRegistered(this)
                ? cloningContext.fetchClone(this)
                : cloningContext.registerClone(this, new BucketData(object, leftRight))
            ;

        return clone;
    }

    public function toString():String {
        return "{object: " + String(object) + ", leftRight: " + String(leftRight) + "}";
    }
}
}
