/**
 * User: booster
 * Date: 17/02/14
 * Time: 8:47
 */
package medkit.collection.spatial {
import medkit.geom.*;
import medkit.collection.HashSet;
import medkit.collection.List;
import medkit.collection.error.ConcurrentModificationError;
import medkit.collection.iterator.Iterator;
import medkit.collection.spatial.BucketData;

public class SpatialSetIterator implements Iterator {
    private var _set:SpatialSet;

    private var _tempSet:HashSet;
    private var _tempSetIt:Iterator;

    private var _lastRet:BucketData;
    private var _expectedModCount:int;

    public function SpatialSetIterator(spatialSet:SpatialSet) {
        _set = spatialSet;
        _tempSet = new HashSet();
        _expectedModCount = _set._modCount;

        var bucketCount:int = spatialSet._bucketContents.length;
        for(var i:int = 0; i < bucketCount; i++) {
            var list:List = spatialSet._bucketContents[i];

            if(list == null)
                continue;

            var listSize:int = list.size();
            for(var j:int = 0; j < listSize; j++) {
                var data:BucketData = list.get(j);

                _tempSet.add(data);
            }
        }

        _tempSetIt = _tempSet.iterator();
    }

    public function hasNext():Boolean { return _tempSetIt.hasNext(); }

    public function next():* {
        checkForConcurrentModification();

        _lastRet = _tempSetIt.next();

        return _lastRet.object;
    }

    public function remove():void {
        if(_lastRet == null)
            throw new UninitializedError();

        checkForConcurrentModification();

        _tempSetIt.remove();

        try {
            _set.remove(_lastRet.object);

            _lastRet = null;
            _expectedModCount = _set._modCount;
        } catch (e:RangeError) {
            throw new ConcurrentModificationError("collection modified while iterating");
        }
    }

    private function checkForConcurrentModification():void {
        if (_set._modCount != _expectedModCount)
            throw new ConcurrentModificationError("collection modified while iterating");
    }
}
}
