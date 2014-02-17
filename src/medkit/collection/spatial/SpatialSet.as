/**
 * User: booster
 * Date: 16/02/14
 * Time: 7:45
 */
package medkit.collection.spatial {
import medkit.collection.AbstractSet;
import medkit.collection.ArrayList;
import medkit.collection.Collection;
import medkit.collection.HashMap;
import medkit.collection.HashSet;
import medkit.collection.iterator.Iterator;
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.ObjectUtil;

public class SpatialSet extends AbstractSet {
    private var _size:int = 0;
    private var _maxBuckets:int;

    internal var _bucketContents:Vector.<Collection>;
    private var _bucketDefs:Vector.<BucketDefinition>;

    private var _spatializer:Spatializer;

    private var _marked:HashSet;
    private var _markedLeftRight:Vector.<int>
    private var _markedIndex:Vector.<int>;

    private var _tempLeftRight:Vector.<int>;
    private var _tempIndex:Vector.<int>;
    private var _tempBucketData:BucketData;
    private var _tempBucketDataSet:HashSet;

    internal var _modCount:int;

    public function SpatialSet(bucketDefs:Array, spatializer:Spatializer = null, maxBuckets:int = 32) {
        var totalSize:int   = 1;
        var count:int       = bucketDefs.length;

        if(count % 3 != 0)
            throw new ArgumentError("bucketDefs has to be made out of sets of three values - min, max and bucket count");

        _bucketDefs = new Vector.<BucketDefinition>(count / 3, true);

        for(var i:int = 0; i < count; i += 3) {
            var bucketSize:int  = bucketDefs[i];
            var min:Number      = bucketDefs[i + 1];
            var max:Number      = bucketDefs[i + 2];

            if(bucketSize <= 0)
                throw new ArgumentError("size of each bucket has to be greater than 0");

            if(min >= max)
                throw new ArgumentError("minimum value for each bucket has to be less than maximum value");

            totalSize *= (bucketSize + 2); // two additional left and right buckets

            _bucketDefs[i / 3] = new BucketDefinition(min, max, bucketSize);
        }

        _bucketContents     = new Vector.<Collection>(maxBuckets, true);
        _spatializer        = spatializer;
        _maxBuckets         = maxBuckets;

        _marked             = new HashSet();
        _markedIndex        = new Vector.<int>((count / 3), true);
        _markedLeftRight    = new Vector.<int>(2 * _markedIndex.length, true);

        _tempIndex          = new Vector.<int>((count / 3), true);
        _tempLeftRight      = new Vector.<int>(2 * _tempIndex.length, true);
        _tempBucketData     = new BucketData(null, _tempLeftRight);
        _tempBucketDataSet  = new HashSet();
    }

    public function search(overlapping:*, potential:Boolean = false, result:Collection = null):Collection {
        if(result == null)
            result = new ArrayList();

        calculateRange(overlapping, _tempLeftRight, _tempIndex);

        _tempBucketDataSet.clear();

        do {
            var hash:uint           = calculateHash(_tempIndex);
            var bucket:Collection   = _bucketContents[int(hash % _maxBuckets)];

            if(bucket == null)
                continue;

            var data:BucketData, it:Iterator = bucket.iterator();

            while(it.hasNext()) {
                data = it.next();

                if(_tempBucketDataSet.contains(data))
                    continue;

                if(! potential && ! intersects(overlapping, data.object))
                    continue;

                 result.add(data.object);
                _tempBucketDataSet.add(data);
            }
        } while(incIndex(_tempIndex, _tempLeftRight));

        return result;
    }

    public function mark(o:*):void {
        if(_size == 0)
            throw UninitializedError("this set is empty");

        calculateRange(o, _tempLeftRight, _tempIndex);

        _tempBucketData.object = o;
        _tempBucketData.leftRight = _tempLeftRight;

        if(_marked.contains(_tempBucketData))
            return;

        do {
            var hash:uint   = calculateHash(_tempIndex);
            var bucket:Collection = _bucketContents[int(hash % _maxBuckets)];

            if(bucket == null || ! bucket.contains(_tempBucketData))
                continue;

            _marked.add(new BucketData(o, _tempLeftRight));
            return;
        } while(incIndex(_tempIndex, _tempLeftRight));

        throw new ArgumentError("object not added to set: " + o);
    }

    public function markAll(c:Collection):void {
        var it:Iterator = c.iterator();

        while(it.hasNext())
            mark(it.next());
    }

    public function updateMarked(unmark:Boolean = true):void {
        var it:Iterator = _marked.iterator();

        while(it.hasNext()) {
            var oldData:BucketData = it.next();

            calculateRange(oldData.object, _tempLeftRight, _tempIndex);

            var newData:BucketData = new BucketData(oldData.object, _tempLeftRight);

            unionRange(oldData.leftRight, newData.leftRight, _markedLeftRight, _markedIndex);

            do {
                var hash:uint = calculateHash(_markedIndex);
                var bucket:Collection = _bucketContents[int(hash % _maxBuckets)];

                // bucket already contains this object - remove the old one
                if(inRange(_markedIndex, oldData.leftRight))
                    bucket.remove(oldData); // bucket cannot be null

                // updated object doesn't go into this bucket
                if(! inRange(_markedIndex, newData.leftRight))
                    continue;

                if(bucket == null) {
                    bucket = new HashSet();
                    _bucketContents[int(hash % _maxBuckets)] = bucket;
                }

                bucket.add(newData);
            } while(incIndex(_markedIndex, _markedLeftRight));

            if(unmark)  it.remove();
            else        oldData.leftRight = newData.leftRight;
        }
    }

    override public function iterator():Iterator { return new SpatialSetIterator(this); }

    override public function size():int { return _size; }
    override public function isEmpty():Boolean { return _size == 0; }

    override public function contains(o:*):Boolean {
        if(_size == 0)
            return false;

        calculateRange(o, _tempLeftRight, _tempIndex);

        _tempBucketData.object = o;
        _tempBucketData.leftRight = _tempLeftRight;

        do {
            var hash:uint   = calculateHash(_tempIndex);
            var bucket:Collection = _bucketContents[int(hash % _maxBuckets)];

            if(bucket != null && bucket.contains(_tempBucketData))
                return true;
        } while(incIndex(_tempIndex, _tempLeftRight));

        return false;
    }

    override public function add(o:*):Boolean {
        ++_modCount;

        calculateRange(o, _tempLeftRight, _tempIndex);

        var added:Boolean   = false;
        var data:BucketData = new BucketData(o, _tempLeftRight);

        do {
            var hash:uint           = calculateHash(_tempIndex);
            var bucket:Collection   = _bucketContents[int(hash % _maxBuckets)];

            if(bucket == null) {
                //bucket = new LinkedList();
                bucket = new HashSet();
                _bucketContents[int(hash % _maxBuckets)] = bucket;
            }

            added = bucket.add(data);
        } while(incIndex(_tempIndex, _tempLeftRight));

        if(added) _size++;

        return added;
    }

    override public function remove(o:*):Boolean {
        ++_modCount;

        calculateRange(o, _tempLeftRight, _tempIndex);

        var removed:Boolean = false;

        _tempBucketData.object = o;
        _tempBucketData.leftRight = _tempLeftRight;

        do {
            var hash:uint           = calculateHash(_tempIndex);
            var bucket:Collection   = _bucketContents[int(hash % _maxBuckets)];

            if(bucket == null)
                continue;

            var rem:Boolean = bucket.remove(_tempBucketData);
            removed         = removed ||rem;
        } while(incIndex(_tempIndex, _tempLeftRight));

        if(removed) _size--;

        return removed;
    }

    override public function clear():void {
        ++_modCount;

        _size = 0;

        var count:int = _bucketContents.length;
        for(var i:int = 0; i < count; i++) {
            var bucket:Collection = _bucketContents[i];

            if(bucket != null)
                bucket.clear();
        }
    }

    override public function clone(cloningContext:CloningContext = null):Cloneable {
        if(cloningContext != null && cloningContext.isBeingCloned(this))
            return cloningContext.fetchClone(this);

        var defCount:int = _bucketDefs.length * 3;
        var defs:Array = new Array(defCount);
        for(var d:int = 0; d < defCount; d += 3) {
            var bucketDef:BucketDefinition = _bucketDefs[d / 3];

            defs[d    ] = bucketDef.size;
            defs[d + 1] = bucketDef.min;
            defs[d + 2] = bucketDef.max;
        }

        var clone:SpatialSet = cloningContext == null
            ? new SpatialSet(defs, _spatializer, _maxBuckets)
            : cloningContext.isCloneRegistered(this)
                ? cloningContext.fetchClone(this)
                : cloningContext.registerClone(this, new SpatialSet(defs, _spatializer, _maxBuckets))
        ;

        var bucketCount:int = _bucketContents.length;
        for(var b:int = 0; b < bucketCount; b++) {
            var bucket:Collection = _bucketContents[b];

            if(bucket == null)
                continue;

            //var clonedBucket:Collection = new LinkedList();
            var clonedBucket:Collection = new HashSet();

            var it:Iterator = bucket.iterator();
            while(it.hasNext()) {
                var data:BucketData = it.next();

                var o:* = cloningContext != null
                    ? ObjectUtil.clone(data.object, cloningContext)
                    : data.object
                ;

                clonedBucket.add(new BucketData(o, data.leftRight));
            }

            clone._bucketContents[b] = clonedBucket;
        }

        clone._size = _size;

        return clone;
    }

    private function intersects(o1:*, o2:*):Boolean {
        var s1:Spatial = o1 as Spatial;
        var s2:Spatial = o2 as Spatial;

        var indexCount:int = s1 != null ? s1.indexCount : _spatializer.indexCount(o1);

        for(var i:int = 0; i < indexCount; i++) {
            var min1:Number, min2:Number, max1:Number, max2:Number;

            if(s1 != null) {
                min1 = s1.minValue(i);
                max1 = s1.maxValue(i);
            }
            else if(_spatializer != null) {
                min1 = _spatializer.minValue(o1, i);
                max1 = _spatializer.maxValue(o1, i);
            }
            else {
                throw new ArgumentError("object does not implement Spatial nor Spatializer is set: " + o1);
            }

            if(s2 != null) {
                min2 = s2.minValue(i);
                max2 = s2.maxValue(i);
            }
            else if(_spatializer != null) {
                min2 = _spatializer.minValue(o2, i);
                max2 = _spatializer.maxValue(o2, i);
            }
            else {
                throw new ArgumentError("object does not implement Spatial nor Spatializer is set: " + o1);
            }

            var x1:Number = Math.max(min1, min2), x2:Number = Math.min(max1, max2);

            if(x2 - x1 < 0)
                return false;
        }

        return true;
    }

    private function incIndex(index:Vector.<int>, leftRight:Vector.<int>):Boolean {
        var count:int = index.length;
        for(var i:int = 0; i < count; i++) {
            var ind:int     = index[i];
            var left:int    = leftRight[int(i * 2)];
            var right:int   = leftRight[int(i * 2 + 1)];

            if(ind == right) {
                if(i < count -1)
                    index[i] = left;
            }
            else {
                index[i] = ind + 1;

                return true;
            }
        }

        return false;
    }

    private function inRange(index:Vector.<int>, leftRight:Vector.<int>):Boolean {
        var count:int = index.length;
        for(var i:int = 0; i < count; i++) {
            var ind:int     = index[i];
            var left:int    = leftRight[int(i * 2)];
            var right:int   = leftRight[int(i * 2 + 1)];

            if(ind >= left && ind <= right)
                continue;

            return false;
        }

        return true;
    }

    private function calculateHash(index:Vector.<int>):uint {
        var hash:uint = 1;

        var count:int = index.length;
        for(var i:int = 0; i < count; i++)
            hash = 31 * hash + index[i];

        return HashMap.hash(hash);
    }

    private function calculateRange(obj:*, leftRight:Vector.<int>, index:Vector.<int>):void {
        var spatial:Spatial = obj as Spatial;

        var i:int, bucketDef:BucketDefinition, bucketCount:int = _bucketDefs.length;
        var min:Number, max:Number;

        if(spatial != null) {
            if(spatial.indexCount != _bucketDefs.length)
                throw new ArgumentError("object's spatial index count: " + spatial.indexCount + ", set's: " + _bucketDefs.length);

            for(i = 0; i < bucketCount; i++) {
                bucketDef   = _bucketDefs[i];
                min         = spatial.minValue(i);
                max         = spatial.maxValue(i);

                index[i] = leftRight[int(2 * i)]    = calculateIndex(min, bucketDef) + 1;
                leftRight[int(2 * i + 1)]           = calculateIndex(max, bucketDef) + 1;
            }
        }
        else if(_spatializer != null) {
            if(_spatializer.indexCount(obj) != _bucketDefs.length)
                throw new ArgumentError("object's spatial index count: " + spatial.indexCount + ", set's: " + _bucketDefs.length);

            for(i = 0; i < bucketCount; i++) {
                bucketDef   = _bucketDefs[i];
                min         = _spatializer.minValue(obj, i);
                max         = _spatializer.maxValue(obj, i);

                index[i] = leftRight[int(2 * i)]    = calculateIndex(min, bucketDef) + 1;
                leftRight[int(2 * i + 1)]           = calculateIndex(max, bucketDef) + 1;
            }
        }
        else {
            throw new ArgumentError("object does not implement Spatial nor Spatializer is set: " + obj);
        }
    }

    private function unionRange(leftRightA:Vector.<int>, leftRightB:Vector.<int>, outLeftRight:Vector.<int>, outIndex:Vector.<int>):void {
        var count:int = outIndex.length;
        for(var i:int = 0; i < count; i++) {
            var leftA:int    = leftRightA[int(i * 2)];
            var rightA:int   = leftRightA[int(i * 2 + 1)];
            var leftB:int    = leftRightB[int(i * 2)];
            var rightB:int   = leftRightB[int(i * 2 + 1)];

            if(leftA < leftB)   outIndex[i] = outLeftRight[int(i * 2)] = leftA;
            else                outIndex[i] = outLeftRight[int(i * 2)] = leftB;

            if(rightA > rightB) outLeftRight[int(i * 2 + 1)] = rightA;
            else                outLeftRight[int(i * 2 + 1)] = rightB;
        }
    }

    private function calculateIndex(v:Number, bucketDef:BucketDefinition):int {
        var i:int = Math.floor((v - bucketDef.min) / (bucketDef.max - bucketDef.min) * bucketDef.size);

        return i < 0 ? -1 : i >= bucketDef.size ? bucketDef.size : i;
    }
}
}
