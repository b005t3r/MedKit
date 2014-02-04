/**
 * User: booster
 * Date: 2/17/13
 * Time: 12:58
 */

package medkit.object {
import flash.errors.IllegalOperationError;
import flash.utils.describeType;

import medkit.collection.HashMap;
import medkit.collection.Map;
import medkit.enum.Enum;

/**
 * Used during selective deep cloning of an object.
 * Using SelectiveCloningContext allows you to clone only some object of a object hierarchy while
 * shallow cloning the other ones or simply setting them to <code>null</code>.
 */
public class SelectiveCloningContext extends CloningContext {
    private var _configurationName:String;

    private var cloningTypeByClass:Map;
    private var cloningTypeByObject:Map;

    public function SelectiveCloningContext(configurationName:String) {
        this._configurationName = configurationName;

        cloningTypeByClass      = new HashMap();
        cloningTypeByObject     = new HashMap();
    }

    public function get configurationName():String {
        return _configurationName;
    }

    public function setObjectCloningType(object:*, type:CloningType):void {
        cloningTypeByObject.put(object, type);
    }

    override public function getObjectCloningType(object:*):CloningType {
        var cloningType:CloningType = cloningTypeByObject.get(object);
        if(cloningType != null)
            return cloningType;

        cloningType = cloningTypeByClass.get(ObjectUtil.getClass(object));
        if(cloningType != null)
            return cloningType;

        return CloningType.DeepClone;
    }

    override internal function gatherMetadata(o:*):void {
        // no need to gather metadata
        if(configurationName == null)
            return;

        var clazz:Class = ObjectUtil.getClass(o);

        // no need to gather metadata
        if(cloningTypeByClass.containsKey(clazz))
            return;

        var typeXML:XML = describeType(clazz);

        for each (var metadataXML:XML in typeXML.factory.metadata) {
            var index:int = indexOfCloningConstant(String(metadataXML.@name));

            if(index == -1)
                continue;

            var cloningType:CloningType = Enum.allEnums(CloningType)[index];

            if(cloningType == CloningType.DeepClone)
                continue;

            for each(var argXML:XML in metadataXML.arg) {
                if(String(argXML.@value) != configurationName)
                    continue;

                var prevValue:* = cloningTypeByClass.put(clazz, cloningType);

                if(prevValue != null)
                    throw new IllegalOperationError("metadata for class: '" + clazz + "' overwritten");

                return;
            }
        }
    }

    private function indexOfCloningConstant(constantName:String):int {
        for(var i:int = 0; i < Enum.allEnums(CloningType).length; i++) {
            var cloningType:CloningType = Enum.allEnums(CloningType)[i];

            if(cloningType.toString() == constantName)
                return i;
        }

        return -1;
    }
}

}
