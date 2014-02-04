/**
 * User: booster
 * Date: 11/14/12
 * Time: 18:01
 */

package medkit.collection {

import medkit.collection.iterator.Iterator;

public class AbstractMapKeySetIterator implements Iterator {
    private var iterator:Iterator;

    public function AbstractMapKeySetIterator(iterator:Iterator) {
        this.iterator = iterator;
    }

    public function hasNext():Boolean {
        return iterator.hasNext();
    }

    public function next():* {
        return (iterator.next() as MapEntry).getKey();
    }

    public function remove():void {
        iterator.remove();
    }
}

}
