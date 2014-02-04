/**
 * User: booster
 * Date: 12/22/12
 * Time: 18:07
 */

package medkit.collection {

import medkit.object.Comparator;
import medkit.object.Equalable;
import medkit.object.ObjectUtil;

public class TestSubjectComparator implements Comparator {
    public function compare(o1:*, o2:*):int {
        var ts1:TestSubject = TestSubject(o1);
        var ts2:TestSubject = TestSubject(o2);

        return ObjectUtil.compare(ts1.str, ts2.str);
    }

    public function equals(object:Equalable):Boolean {
        return object is TestSubjectComparator;
    }

    public function hashCode():int {
        return ObjectUtil.hashCode(this);
    }
}

}
