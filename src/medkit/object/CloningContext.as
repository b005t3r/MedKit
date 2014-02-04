/**
 * User: booster
 * Date: 11/17/12
 * Time: 11:52
 */

package medkit.object {

import medkit.collection.HashMap;
import medkit.collection.HashSet;
import medkit.collection.Map;
import medkit.collection.Set;

/**
 * Used during deep cloning of an object.
 */
public class CloningContext {
    protected static const Null:Object = { nullObject:true };

    protected var clonedMap:Map;
    protected var currentlyCloned:Set;
    protected var clonedToPassIsBeingClonedCall:Set;

    public function CloningContext() {
        clonedMap                       = new HashMap();
        currentlyCloned                 = new HashSet();
        clonedToPassIsBeingClonedCall   = new HashSet();
    }

    /**
     * Checks if given instance is already cloned.
     * @param o instance to check
     * @return true if clone of this instance is already registered, false otherwise
     */
    public function isCloneRegistered(o:*):Boolean {
        return clonedMap.containsKey(o);
    }

    /**
     * Registers cloned instance.
     * @param original  original instance
     * @param clone     cloned instance
     * @return          instance passed as clone
     */
    public function registerClone(original:*, clone:*):* {
        clonedMap.put(original != null ? original : Null, clone);

        return clone;
    }

    /**
     * Returns cloned instance.
     * @param original  original instance
     * @return cloned instance registered for given original instance or null if no instance was registered
     */
    public function fetchClone(original:*):* {
        var clone:* = clonedMap.get(original);

        return clone != Null
            ? clone
            : null
        ;
    }

    /**
     * Checks if the given instance is currently being cloned (its <code>clone()</code> method was called
     * but haven't returned yet).
     * @param o object to check
     * @return true if this object if currently being cloned, false otherwise
     */
    public function isBeingCloned(o:*):Boolean {
        if(clonedToPassIsBeingClonedCall.contains(o)) {
            clonedToPassIsBeingClonedCall.remove(o);

            return false;
        }

        return currentlyCloned.contains(o);
    }

    /**
     * Returns <code>CloningType</code> for the given object.
     * Default implementation always returns <code>CloningType.DeepClone</code>.
     * @param o object to return <code>CloningType</code> for
     * @return <code>CloningType</code>
     */
    public function getObjectCloningType(o:*):CloningType {
        return CloningType.DeepClone;
    }

    internal function gatherMetadata(o:*):void {
        // do nothing by default
    }

    internal function beginCloning(o:*):void {
        currentlyCloned.add(o);
    }

    internal function finishCloning(o:*):void {
        currentlyCloned.remove(o);
        clonedToPassIsBeingClonedCall.remove(o);
    }

    internal function addPassIsBeingClonedInstance(instance:*):void {
        clonedToPassIsBeingClonedCall.add(instance);
    }
}

}
