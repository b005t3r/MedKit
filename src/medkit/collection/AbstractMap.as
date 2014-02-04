/**
 * User: booster
 * Date: 11/14/12
 * Time: 17:37
 */

package medkit.collection {
import medkit.collection.iterator.Iterator;
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Equalable;
import medkit.object.ObjectUtil;
import medkit.string.StringBuilder;

public class AbstractMap implements Map {
    protected var _keySet:Set;
    protected var _values:Collection;

    public function AbstractMap() {
    }

    public function containsKey(key:*):Boolean {
        var i:Iterator = entrySet().iterator();

        if(key == null) {
            while(i.hasNext()) {
                var e:MapEntry = i.next();

                if(e.getKey() == null)
                    return true;
            }
        }
        else {
            while(i.hasNext()) {
                var en:MapEntry = i.next();

                if(ObjectUtil.equals(key, en.getKey()))
                    return true;
            }
        }

        return false;
    }

    public function containsValue(value:*):Boolean {
        var i:Iterator = entrySet().iterator();

        if (value == null) {
            while (i.hasNext()) {
                var e:MapEntry = i.next();

                if(e.getValue() == null)
                    return true;
            }
        }
        else {
            while (i.hasNext()) {
                var en:MapEntry = i.next();

                if (ObjectUtil.equals(value, en.getValue()))
                    return true;
            }
        }

        return false;
    }

    public function get (key:*):* {
        var i:Iterator = entrySet().iterator();

        if(key == null) {
            while(i.hasNext()) {
                var e:MapEntry = i.next();

                if(e.getKey() == null)
                    return e.getValue();
            }
        }
        else {
            while(i.hasNext()) {
                var en:MapEntry = i.next();

                if (ObjectUtil.equals(key, en.getKey()))
                    return en.getValue();
            }
        }

        return null;
    }

    public function keySet():Set {
        if(_keySet == null)
            _keySet = new AbstractMapKeySet(this);

        return _keySet;
    }

    public function entrySet():Set {
        throw new DefinitionError("This method is not implemented");
    }

    public function put(key:*, value:*):* {
        throw new DefinitionError("This method is not implemented");
    }

    public function removeKey(key:*):* {
        var i:Iterator = entrySet().iterator();

        var correctEntry:MapEntry = null;

        if(key == null) {
            while(correctEntry == null && i.hasNext()) {
                var e:MapEntry = i.next();

                if(e.getKey() == null)
                    correctEntry = e;
            }
        }
        else {
            while(correctEntry == null && i.hasNext()) {
                var en:MapEntry = i.next();
                if(ObjectUtil.equals(key, en.getKey()))
                    correctEntry = en;
            }
        }

        var oldValue:* = null;

        if(correctEntry != null) {
            oldValue = correctEntry.getValue();
            i.remove();
        }

        return oldValue;
    }

    public function putAll(map:Map):void {
        var i:Iterator = map.entrySet().iterator();

        while(i.hasNext()) {
            var e:MapEntry = i.next();

            put(e.getKey(), e.getValue());
        }
    }

    public function values():Collection {
        if(_values == null)
            _values = new AbstractMapValuesCollection(this);

        return _values;
    }

    public function clear():void {
        entrySet().clear();
    }

    public function isEmpty():Boolean {
        return size() == 0;
    }

    public function size():int {
        return entrySet().size();
    }

    public function equals(object:Equalable):Boolean {
        if (object == this)
            return true;

        if (! (object is Map))
            return false;

        var m:Map = object as Map;

        if (m.size() != size())
            return false;

        var i:Iterator = entrySet().iterator();

        while (i.hasNext()) {
            var e:MapEntry  = i.next();
            var key:*       = e.getKey();
            var value:*     = e.getValue();

            if (value == null) {
                if (! (m.get(key) == null && m.containsKey(key)))
                    return false;
            }
            else {
                if (! ObjectUtil.equals(value, m.get(key)))
                    return false;
            }
        }

        return true;
    }

    public function hashCode():int {
        var h:int = 0;
        var i:Iterator = entrySet().iterator();

        while (i.hasNext())
            h += ObjectUtil.hashCode(i.next());

        return h;
    }

    public function clone(cloningContext:CloningContext = null):Cloneable {
        throw new DefinitionError("This method is not implemented");
    }

    public function toString():String {
        var i:Iterator = entrySet().iterator();

        if (! i.hasNext())
            return "{}";

        var sb:StringBuilder = new StringBuilder();

        sb.append('{');

        while(true) {
            var e:MapEntry  = i.next();
            var key:*       = e.getKey();
            var value:* = e.getValue();

            sb.append(key   === this ? "(this Map)" : key);
            sb.append('=');
            sb.append(value === this ? "(this Map)" : value);

            if (! i.hasNext())
                return sb.append('}').toString();

            sb.append(", ");
        }

        // to silence compiler warning
        return null;
    }
}

}
