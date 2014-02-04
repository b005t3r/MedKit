/**
 * User: booster
 * Date: 9/9/12
 * Time: 17:40
 */

package medkit.collection {

import medkit.collection.iterator.ListIterator;

internal class SubListIterator implements ListIterator {
    private var list:SubList;
    private var i:ListIterator;

    public function SubListIterator(list:SubList, index:int) {
        this.list   = list;
        this.i      = list.listIterator(list.offset + index);
    }

    public function hasNext():Boolean {
        return nextIndex() < list._size;
    }

    public function next():* {
        if (hasNext())
            return i.next();
        else
            throw new RangeError("Iterating beyond last element");
    }

    public function hasPrevious():Boolean {
        return previousIndex() >= 0;
    }

    public function previous():* {
        if (hasPrevious())
            return i.previous();
        else
            throw new RangeError("Iterating before first element");
    }

    public function nextIndex():int {
        return i.nextIndex() - list.offset;
    }

    public function previousIndex():int {
        return i.previousIndex() - list.offset;
    }

    public function add(o:*):void {
        i.add(o);
        list.modCount = list.l.modCount;
        list._size++;
    }

    public function set(o:*):void {
        i.set(o);
    }

    public function remove():void {
        i.remove();
        list.modCount = list.l.modCount;
        list._size--;
    }
}

}
