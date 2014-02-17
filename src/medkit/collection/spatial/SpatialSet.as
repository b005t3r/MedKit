/**
 * User: booster
 * Date: 16/02/14
 * Time: 7:45
 */
package medkit.collection.spatial {
import medkit.collection.AbstractSet;
import medkit.collection.LinkedList;
import medkit.collection.List;
import medkit.collection.iterator.Iterator;
import medkit.collection.spatial.BucketData;
import medkit.collection.spatial.BucketDefinition;
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.ObjectUtil;

public class SpatialSet extends AbstractSet {
    private var _size:int = 0;
    private var _maxBuckets:int;

    internal var _bucketContents:Vector.<List>;
    private var _bucketDefs:Vector.<BucketDefinition>;

    private var _spatializer:Spatializer;

    private var _tempLeftRight:Vector.<int>;
    private var _tempIndex:Vector.<int>;
    private var _tempBucketData:BucketData;

    internal var _modCount:int;

    public function SpatialSet(bucketDefs:Array, spatializer:Spatializer = null, maxBuckets:int = 50) {
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

        _bucketContents = new Vector.<List>(maxBuckets, true);
        _spatializer    = spatializer;
        _maxBuckets     = maxBuckets;

        _tempIndex      = new Vector.<int>((count / 3), true);
        _tempLeftRight  = new Vector.<int>(2 * _tempIndex.length, true);
        _tempBucketData = new BucketData(null, _tempLeftRight);
    }

    override public function iterator():Iterator {
        return new SpatialSetIterator(this);
    }

    override public function size():int {
        return _size;
    }

    override public function isEmpty():Boolean {
        return _size == 0;
    }

    override public function contains(o:*):Boolean {
        calculateRange(o, _tempLeftRight, _tempIndex);

        _tempBucketData.object = o;

        do {
            var hash:uint   = calculateHash(_tempIndex);
            var bucket:List = _bucketContents[int(hash % _maxBuckets)];

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
            var hash:uint   = calculateHash(_tempIndex);
            var bucket:List = _bucketContents[int(hash % _maxBuckets)];

            if(bucket == null) {
                bucket = new LinkedList();
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

        do {
            var hash:uint   = calculateHash(_tempIndex);
            var bucket:List = _bucketContents[int(hash % _maxBuckets)];

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
            var bucket:List = _bucketContents[i];

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
            var bucket:List = _bucketContents[b];

            if(bucket == null)
                continue;

            var clonedBucket:List = new LinkedList();

            var dataCount:int = bucket.size();
            for(var i:int = 0; i < dataCount; i++) {
                var data:BucketData = bucket.get(i);

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

    private function calculateHash(index:Vector.<int>):uint {
        var hash:uint = 1;

        var count:int = index.length;
        for(var i:int = 0; i < count; i++)
            hash = 31 * hash + index[i];

        return hash;
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

    private function calculateIndex(v:Number, bucketDef:BucketDefinition):int {
        var i:int = Math.floor((v - bucketDef.min) / (bucketDef.max - bucketDef.min) * bucketDef.size);

        return i < 0 ? -1 : i >= bucketDef.size ? bucketDef.size : i;
    }
}
}
