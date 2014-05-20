/**
 * User: booster
 * Date: 20/05/14
 * Time: 15:03
 */
package medkit.object.test {
import medkit.object.Equalable;
import medkit.object.ObjectInputStream;
import medkit.object.ObjectOutputStream;
import medkit.object.Serializable;

public class SimpleSerializable implements Serializable, Equalable {
    public var name:String;
    public var index:int;

    public function SimpleSerializable(name:String = null, index:int = -1) {
        this.name = name;
        this.index = index;
    }

    public function readObject(input:ObjectInputStream):void {
        index = input.readInt("index");
        name = input.readString("name");
    }

    public function writeObject(output:ObjectOutputStream):void {
        output.writeString(name, "name");
        output.writeInt(index, "index");
    }

    public function equals(object:Equalable):Boolean {
        var simple:SimpleSerializable = object as SimpleSerializable;

        if(simple == null)
            return false;

        return simple.name == name && simple.index == index;
    }
}
}
