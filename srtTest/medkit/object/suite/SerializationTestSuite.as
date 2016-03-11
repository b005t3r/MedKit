/**
 * User: booster
 * Date: 2/17/13
 * Time: 16:36
 */

package medkit.object.suite {
import medkit.object.ComplexSerializableTest;
import medkit.object.SimpleSerializableTest;

[Suite]
[RunWith("org.flexunit.runners.Suite")]
public class SerializationTestSuite {
    public var simpleSerializableTest:SimpleSerializableTest;
    public var complexSerializableTest:ComplexSerializableTest;
}
}
