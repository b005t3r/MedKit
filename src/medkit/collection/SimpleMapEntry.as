/**
 * User: booster
 * Date: 11/14/12
 * Time: 18:59
 */

package medkit.collection {
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Equalable;
import medkit.object.ObjectInputStream;
import medkit.object.ObjectOutputStream;
import medkit.object.ObjectUtil;

public class SimpleMapEntry implements MapEntry {
    private var key:*;
    private var value:*;

    public function SimpleMapEntry(key:*, value:*) {
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
        var oldValue:*  = getValue();
        this.value      = value;

        return oldValue;
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

    public function readObject(input:ObjectInputStream):void {
        key     = input.readObject("key");
        value   = input.readObject("value");
    }

    public function writeObject(output:ObjectOutputStream):void {
        output.writeObject(key, "key");
        output.writeObject(value, "value");
    }

    public function toString():String {
        return key + "=" + value;
    }
}

}
