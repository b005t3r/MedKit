/**
 * User: booster
 * Date: 11/14/12
 * Time: 19:17
 */

package medkit.collection {

import flash.errors.IllegalOperationError;

import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Equalable;
import medkit.object.ObjectUtil;

public class SimpleImmutableMapEntry implements MapEntry {
    private var key:*;
    private var value:*;

    public function SimpleImmutableMapEntry(key:*, value:*) {
        this.key = key;
        this.value = value;
    }

    public function getKey():* {
        return key;
    }

    public function getValue():* {
        return value;
    }

    public function setValue(value:*):* {
        throw new IllegalOperationError("This operation is not supported");
    }

    public function equals(object:Equalable):Boolean {
        if (! (object is MapEntry))
            return false;

        var e:MapEntry = object as MapEntry;

        return ObjectUtil.equals(key, e.getKey()) && ObjectUtil.equals(value, e.getValue());
    }

    public function hashCode():int {
        return ObjectUtil.hashCode(getKey()) ^ ObjectUtil.hashCode(getValue());
    }

    public function clone(cloningContext:CloningContext = null):Cloneable {
        var e:SimpleImmutableMapEntry  = new SimpleImmutableMapEntry(
            cloningContext != null ? ObjectUtil.clone(getKey(), cloningContext) : getKey(),
            cloningContext != null ? ObjectUtil.clone(getValue(), cloningContext) : getValue()
        );

        return e;
    }

    public function toString():String {
        return key + "=" + value;
    }
}

}
