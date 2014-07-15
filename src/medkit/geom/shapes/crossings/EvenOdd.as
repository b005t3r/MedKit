/**
 * User: booster
 * Date: 15/05/14
 * Time: 11:25
 */
package medkit.geom.shapes.crossings {
import medkit.collection.VectorUtil;

public class EvenOdd extends Crossings {
    public function EvenOdd(xlo:Number, ylo:Number, xhi:Number, yhi:Number) {
        super(xlo, ylo, xhi, yhi);
    }

    override public final function covers(ystart:Number, yend:Number):Boolean {
        return (limit == 2 && yranges[0] <= ystart && yranges[1] >= yend);
    }

    override public function record(ystart:Number, yend:Number, direction:int):void {
        if(ystart >= yend) {
            return;
        }
        var from:int = 0;
        // Quickly jump over all pairs that are completely "above"
        while(from < limit && ystart > yranges[from + 1])
            from += 2;

        var to:int = from;
        while(from < limit) {
            var yrlo:Number = yranges[from++];
            var yrhi:Number = yranges[from++];

            if(yend < yrlo) {
                // Quickly handle insertion of the new range
                yranges[to++] = ystart;
                yranges[to++] = yend;
                ystart = yrlo;
                yend = yrhi;
                continue;
            }

            // The ranges overlap - sort, collapse, insert, iterate
            var yll:Number, ylh:Number, yhl:Number, yhh:Number;

            if(ystart < yrlo) {
                yll = ystart;
                ylh = yrlo;
            }
            else {
                yll = yrlo;
                ylh = ystart;
            }

            if(yend < yrhi) {
                yhl = yend;
                yhh = yrhi;
            }
            else {
                yhl = yrhi;
                yhh = yend;
            }

            if(ylh == yhl) {
                ystart = yll;
                yend = yhh;
            }
            else {
                if(ylh > yhl) {
                    ystart = yhl;
                    yhl = ylh;
                    ylh = ystart;
                }

                if(yll != ylh) {
                    yranges[to++] = yll;
                    yranges[to++] = ylh;
                }

                ystart = yhl;
                yend = yhh;
            }
            if(ystart >= yend)
                break;
        }

        if(to < from && from < limit)
            VectorUtil.arrayCopy(yranges, from, yranges, to, limit - from);

        to += (limit - from);

        if(ystart < yend) {
            if(to >= yranges.length) {
                var newRanges:Vector.<Number> = new Vector.<Number>(to + 10);

                VectorUtil.arrayCopy(yranges, 0, newRanges, 0, to);
                yranges = newRanges;
            }

            yranges[to++] = ystart;
            yranges[to++] = yend;
        }

        limit = to;
    }
}
}
