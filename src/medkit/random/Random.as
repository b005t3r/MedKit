/**
 * User: booster
 * Date: 07/02/14
 * Time: 8:55
 */
package medkit.random {
/**
 * SimpleRNG is a simple random number generator based on George Marsaglia's MWC (multiply with carry) generator.
 * Although it is very simple, it passes Marsaglia's DIEHARD series of random number generator tests.
 *
 * Ported from John D. Cook SimpleRNG
 * http://www.johndcook.com
 */
public class Random {
    private var _w:uint;
    private var _z:uint;

    public static function fromDate(date:Date = null):Random {
        if(date == null)
            date = new Date();

        var x:Number = date.getTime();

        var w:uint = (uint)(x / (1 << 16));
        var z:uint = (uint)(x % (1 << 16));

        return new Random(w, z);
    }

    public static function fromExisting(random:Random):Random {
        return new Random(random.w, random.z);
    }

    public static function fromSerialized(obj:Object):Random {
        return new Random(obj["w"], obj["z"]);
    }

    public static function toSerialized(random:Random):Object {
        return { "w" : random.w, "z" : random.z };
    }

    /** These values are not magical, just the default values Marsaglia used. Any pair of unsigned integers should be fine. */
    public function Random(u:uint = 521288629, v:uint = 362436069) {
        if(u == 0 || v == 0)
            throw new ArgumentError("seeds must be greater than 0");

        _w = u;
        _z = v;
    }

    public function get w():uint { return _w; }
    public function set w(value:uint):void { _w = value; }

    public function get z():uint { return _z; }
    public function set z(value:uint):void { _z = value; }

    /**
     * This is the heart of the generator. It uses George Marsaglia's MWC algorithm to produce an unsigned integer.
     * See http://www.bobwheeler.com/statistics/Password/MarsagliaPost.txt
     */
    public function nextUnsignedInteger():uint {
        _z = 36969 * (_z & 65535) + (_z >> 16);
        _w = 18000 * (_w & 65535) + (_w >> 16);

        return (_z << 16) + _w;
    }

    /** Produce a uniform random sample from the open interval (0, 1). The method will not return either end point. */
    public function nextNumber():Number {
        // 0 <= u < 2^32
        var u:uint = nextUnsignedInteger();
        // The magic number below is 1/(2^32 + 2).
        // The result is strictly between 0 and 1.
        return (u + 1.0) * 2.328306435454494e-10;
    }

    /** Get normal (Gaussian) random sample with specified mean and standard deviation. */
    public function nextNormal(mean:Number = 0, standardDeviation:Number = 1):Number {
        if(standardDeviation <= 0.0)
            throw new ArgumentError("Shape must be positive. Received: " + standardDeviation);

        // Use Box-Muller algorithm
        var u1:Number = nextNumber();
        var u2:Number = nextNumber();
        var r:Number = Math.sqrt(-2.0 * Math.log(u1));
        var theta:Number = 2.0 * Math.PI * u2;

        var retVal:Number = r * Math.sin(theta);

        return mean + standardDeviation * retVal;
    }

    /** Get exponential random sample with specified mean. */
    public function nextExponential(mean:Number = 1):Number {
        if(mean <= 0.0)
            throw new ArgumentError("Mean must be positive. Received: " + mean);

        return mean * -Math.log(nextNumber());
    }

    public function nextGamma(shape:Number, scale:Number):Number {
        // Implementation based on "A Simple Method for Generating Gamma Variables"
        // by George Marsaglia and Wai Wan Tsang.  ACM Transactions on Mathematical Software
        // Vol 26, No 3, September 2000, pages 363-372.

        var d:Number, c:Number, x:Number, xsquared:Number, v:Number, u:Number;

        if(shape >= 1.0) {
            d = shape - 1.0 / 3.0;
            c = 1.0 / Math.sqrt(9.0 * d);
            for(; ;) {
                do
                {
                    x = nextNormal();
                    v = 1.0 + c * x;
                }
                while(v <= 0.0);
                v = v * v * v;
                u = nextNumber();
                xsquared = x * x;
                if(u < 1.0 - .0331 * xsquared * xsquared || Math.log(u) < 0.5 * xsquared + d * (1.0 - v + Math.log(v)))
                    return scale * d * v;
            }
        }
        else if(shape <= 0.0) {
            throw new ArgumentError("Shape must be positive. Received: " + shape);
        }
        else {
            var g:Number = nextGamma(shape + 1.0, 1.0);
            var w:Number = nextNumber();
            return scale * g * Math.pow(w, 1.0 / shape);
        }
    }

    public function nextChiSquare(degreesOfFreedom:Number):Number {
        // A chi squared distribution with n degrees of freedom
        // is a gamma distribution with shape n/2 and scale 2.
        return nextGamma(0.5 * degreesOfFreedom, 2.0);
    }

    public function nextInverseGamma(shape:Number, scale:Number):Number {
        // If X is gamma(shape, scale) then
        // 1/Y is inverse gamma(shape, 1/scale)
        return 1.0 / nextGamma(shape, 1.0 / scale);
    }

    public function nextWeibull(shape:Number, scale:Number):Number {
        if(shape <= 0.0 || scale <= 0.0)
            throw new ArgumentError("Shape and scale parameters must be positive. Received shape: " + shape + " and scale: " + scale);

        return scale * Math.pow(-Math.log(nextNumber()), 1.0 / shape);
    }

    public function nextCauchy(median:Number, scale:Number):Number {
        if(scale <= 0)
            throw new ArgumentError("Scale must be positive. Received: " + scale);

        var p:Number = nextNumber();

        // Apply inverse of the Cauchy distribution function to a uniform
        return median + scale * Math.tan(Math.PI * (p - 0.5));
    }

    public function nextStudentT(degreesOfFreedom:Number):Number {
        if(degreesOfFreedom <= 0)
            throw new ArgumentError("Degrees of freedom must be positive. Received: " + degreesOfFreedom);

        // See Seminumerical Algorithms by Knuth
        var y1:Number = nextNormal();
        var y2:Number = nextChiSquare(degreesOfFreedom);

        return y1 / Math.sqrt(y2 / degreesOfFreedom);
    }

    /** The Laplace distribution is also known as the double exponential distribution. */
    public function nextLaplace(mean:Number, scale:Number):Number {
        var u:Number = nextNumber();

        return (u < 0.5) ?
            mean + scale * Math.log(2.0 * u) :
            mean - scale * Math.log(2 * (1 - u));
    }

    public function nextLogNormal(mu:Number, sigma:Number):Number {
        return Math.exp(nextNormal(mu, sigma));
    }

    public function nextBeta(a:Number, b:Number):Number {
        if(a <= 0.0 || b <= 0.0)
            throw new ArgumentError("Beta parameters must be positive. Received a: " + a + " and b: " + b);

        // There are more efficient methods for generating beta samples.
        // However such methods are a little more efficient and much more complicated.
        // For an explanation of why the following method works, see
        // http://www.johndcook.com/distribution_chart.html#gamma_beta

        var u:Number = nextGamma(a, 1.0);
        var v:Number = nextGamma(b, 1.0);
        return u / (u + v);
    }
}
}