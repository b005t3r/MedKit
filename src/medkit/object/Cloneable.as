/**
 * User: booster
 * Date: 11/14/12
 * Time: 18:35
 */

package medkit.object {

public interface Cloneable {
    /**
     * Returns exact copy of this instance.
     * Call to this method with it's default parameter's value (null) results in a shallow clone creation.
     * If you need to create a deep clone simply call <code>obj.clone(new CloningContext())</code>.
     *
     * Simplest implementation of this method, which handles only shallow cloning, is quite straightforward:
     * create a new instance of your object then set its members to the current instance members and return
     * the clone.
     * However if you're going to implement a method that can also handle deep cloning, you need to take few more
     * things under your consideration. I.e. you should always check with the cloning context instance being
     * used if your instance is not currently being cloned (which may happen if it's a part of a cyclical object
     * hierarchy, i.e. where object A holds reference to B and B holds reference to A).
     *
     * All of this can be done with a simple if-else statement and <code>cloningContext</code> instance passed as a
     * parameter, like so:
     * <code>
     *     var clone:Cloneable;
     *
     *     if(cloningContext != null) {
     *         clone = cloningContext.fetchClone(this);
     *
     *         if(clone != null)
     *             return clone;
     *
     *         clone = cloningContext.registerClone(this, new Cloneable());
     *         clone.myMember = ObjectUtil.clone(this.myMember, cloningContext);
     *     }
     *     else {
     *         clone = new Cloneable();
     *         clone.myMember = this.myMember;
     *     }
     *
     *     return clone;
     * </code>
     *
     * You should always use <code>ObjectUtil.clone()</code> method for cloning members or objects of that you don't know
     * if they implement Cloneable interface.
     *
     * @see ObjectUtil.clone
     *
     * @param cloningContext    CloningContext instance used for keeping track of cloned objects
     *
     * @returns exact copy of this instance
     */
    function clone(cloningContext:CloningContext = null):Cloneable;
}

}
