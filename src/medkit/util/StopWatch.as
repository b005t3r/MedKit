/**
 * User: booster
 * Date: 13/02/14
 * Time: 18:17
 */
package medkit.util {
import flash.utils.Dictionary;
import flash.utils.getTimer;

public class StopWatch {
    private static var _watchesByName:Dictionary = new Dictionary();

    public static function startWatch(name:String):void {
        var watch:StopWatch = _watchesByName[name];

        if(watch != null)
            throw new UninitializedError("stop watch for name \'" + name + "\'already started");

        _watchesByName[name] = watch = new StopWatch();

        watch.start();
    }

    public static function stopWatch(name:String):Number {
        var watch:StopWatch = _watchesByName[name];

        if(watch == null)
            throw new UninitializedError("stop watch for name \'" + name + "\'not started");

        var retVal:Number = watch.stop();
        delete _watchesByName[name];

        return retVal;
    }

    private var _startMilis:int;

    public function StopWatch() { }

    public function start():void {
        _startMilis = getTimer();
    }

    public function stop():Number {
        var currMilis:int = getTimer();

        return (currMilis - _startMilis) / 1000.0;
    }
}
}
