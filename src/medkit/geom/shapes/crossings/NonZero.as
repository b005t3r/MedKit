/**
 * User: booster
 * Date: 15/05/14
 * Time: 12:02
 */
package medkit.geom.shapes.crossings {
import medkit.collection.VectorUtil;

public class NonZero extends Crossings {
    private var crosscounts:Vector.<int>;

    public function NonZero(xlo:Number, ylo:Number, xhi:Number, yhi:Number) {
        super(xlo, ylo, xhi, yhi);
        crosscounts = new Vector.<int>(yranges.length / 2);
    }

    override public final function covers(ystart:Number, yend:Number):Boolean{
        var i:int= 0;
        while (i < limit) {
            var ylo:Number= yranges[i++];
            var yhi:Number= yranges[i++];
            if (ystart >= yhi) {
                continue;
            }
            if (ystart < ylo) {
                return false;
            }
            if (yend <= yhi) {
                return true;
            }
            ystart = yhi;
        }
        return (ystart >= yend);
    }

    public function remove(cur:int):void{
        limit -= 2;
        var rem:int= limit - cur;
        if (rem > 0) {
            VectorUtil.arrayCopy(yranges as Vector, cur+2, yranges as Vector, cur, rem);
            VectorUtil.arrayCopy(crosscounts as Vector, cur/2+1, crosscounts as Vector, cur/2, rem/2);
        }
    }

    public function insert(cur:int, lo:Number, hi:Number, dir:int):void{
        var rem:int= limit - cur;
        var oldranges:Vector.<Number> = yranges;
        var oldcounts:Vector.<int> = crosscounts;

        if (limit >= yranges.length) {
            yranges = Vector.<Number>(limit+10);
            VectorUtil.arrayCopy(oldranges as Vector, 0, yranges as Vector, 0, cur);
            crosscounts = new Vector.<int>((limit+10)/2);
            VectorUtil.arrayCopy(oldcounts as Vector, 0, crosscounts as Vector, 0, cur/2);
        }

        if (rem > 0) {
            VectorUtil.arrayCopy(oldranges as Vector, cur, yranges as Vector, cur+2, rem);
            VectorUtil.arrayCopy(oldcounts as Vector, cur/2, crosscounts as Vector, cur/2+1, rem/2);
        }

        yranges[cur+0] = lo;
        yranges[cur+1] = hi;
        crosscounts[cur/2] = dir;
        limit += 2;
    }

    override public function record(ystart:Number, yend:Number, direction:int):void{
        if (ystart >= yend) {
            return;
        }
        var cur:int= 0;
        // Quickly jump over all pairs that are completely "above"
        while (cur < limit && ystart > yranges[cur+1]) {
            cur += 2;
        }
        if (cur < limit) {
            var rdir:int= crosscounts[cur/2];
            var yrlo:Number= yranges[cur+0];
            var yrhi:Number= yranges[cur+1];
            if (yrhi == ystart && rdir == direction) {
                // Remove the range from the list and collapse it
                // into the range being inserted.  Note that the
                // new combined range may overlap the following range
                // so we must not simply combine the ranges in place
                // unless we are at the last range.
                if (cur+2== limit) {
                    yranges[cur+1] = yend;
                    return;
                }
                remove(cur);
                ystart = yrlo;
                rdir = crosscounts[cur/2];
                yrlo = yranges[cur+0];
                yrhi = yranges[cur+1];
            }
            if (yend < yrlo) {
                // Just insert the new range at the current location
                insert(cur, ystart, yend, direction);
                return;
            }
            if (yend == yrlo && rdir == direction) {
                // Just prepend the new range to the current one
                yranges[cur] = ystart;
                return;
            }
            // The ranges must overlap - (yend > yrlo && yrhi > ystart)
            if (ystart < yrlo) {
                insert(cur, ystart, yrlo, direction);
                cur += 2;
                ystart = yrlo;
            } else if (yrlo < ystart) {
                insert(cur, yrlo, ystart, rdir);
                cur += 2;
                yrlo = ystart;
            }
            // assert(yrlo == ystart);
            var newdir:int= rdir + direction;
            var newend:Number= Math.min(yend, yrhi);
            if (newdir == 0) {
                remove(cur);
            } else {
                crosscounts[cur/2] = newdir;
                yranges[cur++] = ystart;
                yranges[cur++] = newend;
            }
            ystart = yrlo = newend;
            if (yrlo < yrhi) {
                insert(cur, yrlo, yrhi, rdir);
            }
        }
        if (ystart < yend) {
            insert(cur, ystart, yend, direction);
        }
    }
}
}
