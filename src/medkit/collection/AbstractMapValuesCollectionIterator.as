/**
 * User: booster
 * Date: 11/14/12
 * Time: 18:09
 */

package medkit.collection {

import medkit.collection.iterator.Iterator;

public class AbstractMapValuesCollectionIterator implements Iterator {
    private var iterator:Iterator;

    public function AbstractMapValuesCollectionIterator(iterator:Iterator) {
        this.iterator = iterator;
    }

    public function hasNext():Boolean {
        return iterator.hasNext();
    }

    public function next():* {
        return (iterator.next() as MapEntry).getValue();
    }

    public function remove():void {
        iterator.remove();
    }
}

}
