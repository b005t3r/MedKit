/**
 * User: booster
 * Date: 12/9/12
 * Time: 12:33
 */

package medkit.collection.suite {

import medkit.collection.test.*;

[Suite]
[RunWith("org.flexunit.runners.Suite")]
public class CollectionTestSuite {
    public var arrayListTest:ArrayListTest;
    public var linkedListTest:LinkedListTest;
    public var hashMapTest:HashMapTest;
    public var hashSetTest:HashSetTest;
    public var treeMapTest:TreeMapTest;
    public var treeSetTest:TreeSetTest;
    public var hashMultiSetTest:HashMultiSetTest;
}

}
