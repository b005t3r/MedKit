/**
 * User: booster
 * Date: 24/11/16
 * Time: 09:47
 */
package medkit.random {
public interface Randomizer {
    /** Heart of the generator - a simple XorShift. */
    function nextUnsignedInteger():uint;

    function nextIntegerInRange(min:int, max:int):int;

    /** Produce a uniform random sample from the open interval (0, 1). The method will not return either end point. */
    function nextNumber():Number;

    function nextNumberInRange(min:Number, max:Number):Number;

    /** Get normal (Gaussian) random sample with specified mean and standard deviation. */
    function nextNormal(mean:Number = 0, standardDeviation:Number = 1):Number;

    /** Get exponential random sample with specified mean. */
    function nextExponential(mean:Number = 1):Number;

    function nextGamma(shape:Number, scale:Number):Number;

    function nextChiSquare(degreesOfFreedom:Number):Number;

    function nextInverseGamma(shape:Number, scale:Number):Number;

    function nextWeibull(shape:Number, scale:Number):Number;

    function nextCauchy(median:Number, scale:Number):Number;

    function nextStudentT(degreesOfFreedom:Number):Number;

    /** The Laplace distribution is also known as the double exponential distribution. */
    function nextLaplace(mean:Number, scale:Number):Number;

    function nextLogNormal(mu:Number, sigma:Number):Number;

    function nextBeta(a:Number, b:Number):Number;
}
}
