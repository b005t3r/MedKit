/**
 * User: booster
 * Date: 12/15/12
 * Time: 13:02
 */

package medkit.collection {

import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Equalable;
import medkit.object.ObjectInputStream;
import medkit.object.ObjectOutputStream;
import medkit.object.ObjectUtil;

public class TreeMapEntry implements MapEntry {
    internal var key:*;
    internal var value:*;
    internal var left:TreeMapEntry;
    internal var right:TreeMapEntry;
    internal var parent:TreeMapEntry;
    internal var color:Boolean = TreeMap.BLACK;

    public function TreeMapEntry(key:*, value:*, parent:*) {
        this.key    = key;
        this.value  = value;
        this.parent = parent;
    }

    public function getKey():* {
        return key;
    }

    public function getValue():* {
        return value;
    }

    public function setValue(value:*):* {
        var oldValue:*  = this.value;
        this.value      = value;

        return oldValue;
    }

    public function equals(object:Equalable):Boolean {
        if (! (object is MapEntry))
            return false;

        var e:TreeMapEntry = object as TreeMapEntry;

        return TreeMap.valEquals(key, e.getKey()) && TreeMap.valEquals(value, e.getValue());
    }

    public function hashCode():int {
        var keyHash:int     = (key == null ? 0 : ObjectUtil.hashCode(key));
        var valueHash:int   = (value == null ? 0 : ObjectUtil.hashCode(value));

        return keyHash ^ valueHash;
    }

    public function clone(cloningContext:CloningContext = null):Cloneable {
        if(cloningContext != null && cloningContext.isBeingCloned(this))
            return cloningContext.fetchClone(this);

        var clone:TreeMapEntry = cloningContext == null
            ? new TreeMapEntry(null, null, null)
            : cloningContext.isCloneRegistered(this)
                ? cloningContext.fetchClone(this)
                : cloningContext.registerClone(this, new TreeMapEntry(null, null, null))
        ;

        clone.parent    = cloningContext != null ? ObjectUtil.clone(this.parent, cloningContext) : this.parent;
        clone.key       = cloningContext != null ? ObjectUtil.clone(this.key, cloningContext) : this.key;
        clone.value     = cloningContext != null ? ObjectUtil.clone(this.value, cloningContext) : this.value;

        return clone;
    }

    public function readObject(input:ObjectInputStream):void {
        key     = input.readObject("key");
        value   = input.readObject("value");
        left    = input.readObject("left") as TreeMapEntry;
        right   = input.readObject("right") as TreeMapEntry;
        parent  = input.readObject("parent") as TreeMapEntry;
        color   = input.readBoolean("color");
    }

    public function writeObject(output:ObjectOutputStream):void {
        output.writeObject(key, "key");
        output.writeObject(value, "value");
        output.writeObject(left, "left");
        output.writeObject(right, "right");
        output.writeObject(parent, "parent");
        output.writeBoolean(color, "color");
    }

    public function toString():String {
        return key + "=" + value;
    }
}

}
