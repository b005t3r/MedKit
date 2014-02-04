/**
 * User: booster
 * Date: 2/17/13
 * Time: 16:36
 */

package medkit.object.suite {
import medkit.object.ComplexCloneableTest;
import medkit.object.SelectiveCloneTest;
import medkit.object.SimpleCloneableTest;

[Suite]
[RunWith("org.flexunit.runners.Suite")]
public class CloningTestSuite {
    public var simpleCloneableTest:SimpleCloneableTest;
    public var complexCloneableTest:ComplexCloneableTest;
    public var selectiveCloneTest:SelectiveCloneTest;
}

}
