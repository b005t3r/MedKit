/**
 * User: booster
 * Date: 21/05/14
 * Time: 9:18
 */
package medkit.object.test {
import medkit.object.Equalable;
import medkit.object.ObjectInputStream;
import medkit.object.ObjectOutputStream;
import medkit.object.Serializable;

public class ComplexSerializable implements Serializable, Equalable {
    public var name:String;
    public var other:ComplexSerializable;

    public function ComplexSerializable(name:String = null, other:ComplexSerializable = null) {
        this.name = name;
        this.other = other;
    }

    public function readObject(input:ObjectInputStream):void {
        name    = input.readString("name");
        other = input.readObject("sibling") as ComplexSerializable;
    }

    public function writeObject(output:ObjectOutputStream):void {
        output.writeString(name, "name");
        output.writeObject(other, "sibling");
    }

    public function equals(object:Equalable):Boolean {
        var serializable:ComplexSerializable = object as ComplexSerializable;

        if(serializable == null)
            return false;

        // don't check 'other' to prevent looped equals() call
        return serializable.name == name;
    }
}
}
