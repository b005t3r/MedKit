/**
 * User: booster
 * Date: 11/17/12
 * Time: 16:57
 */

package medkit.collection {
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Equalable;
import medkit.object.ObjectInputStream;
import medkit.object.ObjectOutputStream;
import medkit.object.ObjectUtil;

public class HashMapEntry implements MapEntry {
    internal var key:*;
    internal var value:*;
    internal var next:HashMapEntry;
    internal var hash:int;

    // undefined params for serialization purposes only
    public function HashMapEntry(h:int = undefined, k:* = undefined, v:* = undefined, n:HashMapEntry = undefined) {
        value   = v;
        next    = n;
        key     = k;
        hash    = h;
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
        if(!(object is MapEntry))
            return false;

        var e:MapEntry = object as MapEntry;
        var k1:* = getKey();
        var k2:* = e.getKey();

        if(k1 == k2 || (k1 != null &&  ObjectUtil.equals(k1, k2))) {
            var v1:* = getValue();
            var v2:* = e.getValue();

            if(v1 == v2 || (v1 != null && ObjectUtil.equals(v1, v2)))
                return true;
        }

        return false;
    }

    public function hashCode():int {
        return (key == null ? 0 : ObjectUtil.hashCode(key)) ^ (value == null ? 0 : ObjectUtil.hashCode(value));
    }

    public function clone(cloningContext:CloningContext = null):Cloneable {
        if(cloningContext != null && cloningContext.isBeingCloned(this))
            return cloningContext.fetchClone(this);

        var clone:HashMapEntry = cloningContext == null
            ? new HashMapEntry(0, 0, 0, null)
            : cloningContext.isCloneRegistered(this)
                ? cloningContext.fetchClone(this)
                : cloningContext.registerClone(this, new HashMapEntry(0, 0, 0, null))
        ;

        clone.hash  = this.hash;
        clone.key   = cloningContext != null ? ObjectUtil.clone(this.key, cloningContext) : this.key;
        clone.value = cloningContext != null ? ObjectUtil.clone(this.value, cloningContext) : this.value;
        clone.next  = ObjectUtil.clone(this.next, cloningContext);  // always clone 'next'

        return clone;
    }

    public function readObject(input:ObjectInputStream):void {
        key     = input.readObject("key");
        value   = input.readObject("value");
        next    = input.readObject("next") as HashMapEntry;
        hash    = input.readInt("hash");
    }

    public function writeObject(output:ObjectOutputStream):void {
        output.writeObject(key, "key");
        output.writeObject(value, "value");
        output.writeObject(next, "next");
        output.writeInt(hash, "hash");
    }

    public function toString():String {
        return getKey() + "=" + getValue();
    }

    /**
     * This method is invoked whenever the value in an entry is overwritten by an invocation of put(k,v) for a key k
     * that's already in the HashMap.
     */
    internal function recordAccess(m:HashMap):void {
    }

    /**
     * This method is invoked whenever the entry is removed from the table.
     */
    internal function recordRemoval(m:HashMap):void {
    }
}

}
