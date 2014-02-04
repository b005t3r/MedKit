/**
 * User: booster
 * Date: 11/17/12
 * Time: 11:16
 */

package medkit.collection {
import medkit.collection.error.ConcurrentModificationError;
import medkit.collection.iterator.ListIterator;

public class LinkedListListItr implements ListIterator {
    private var list:LinkedList;

    private var lastReturned:LinkedListEntry;
    private var _next:LinkedListEntry;
    private var _nextIndex:int;
    private var expectedModCount:int;


    public function LinkedListListItr(list:LinkedList, index:int) {
        this.list           = list;
        lastReturned        = list.header;
        expectedModCount    = list.modCount;

        if(index < 0 || index > list._size)
            throw new RangeError("Index: " + index + ", Size: " + list._size);

        if(index < (list._size >> 1)) {
            _next = list.header.next;

            for(_nextIndex = 0; _nextIndex < index; ++_nextIndex)
                _next = _next.next;
        }
        else {
            _next = list.header;

            for(_nextIndex = list._size; _nextIndex > index; --_nextIndex)
                _next = _next.previous;
        }
    }

    public function hasNext():Boolean {
        return _nextIndex != list._size;
    }

    public function next():* {
        checkForCoModification();

        if (_nextIndex == list._size)
            throw new RangeError();

        lastReturned    = _next;
        _next           = _next.next;
        ++_nextIndex;

        return lastReturned.element;
    }

    public function hasPrevious():Boolean {
        return _nextIndex != 0;
    }

    public function previous():* {
        if (_nextIndex == 0)
            throw new RangeError();

        lastReturned = _next = _next.previous;
        --_nextIndex;

        checkForCoModification();

        return lastReturned.element;
    }

    public function nextIndex():int {
        return _nextIndex;
    }

    public function previousIndex():int {
        return _nextIndex - 1;
    }


    public function remove():void {
        checkForCoModification();

        var lastNext:LinkedListEntry = lastReturned.next;

        try {
            list.removeEntry(lastReturned);
        }
        catch (e:RangeError) {
            throw new UninitializedError();
        }

        if (_next==lastReturned)
            _next = lastNext;
        else
            --_nextIndex;

        lastReturned = list.header;
        ++expectedModCount;
    }

    public function set (o:*):void {
        if (lastReturned == list.header)
            throw new UninitializedError();

        checkForCoModification();

        lastReturned.element = o;
    }

    public function add(o:*):void {
        checkForCoModification();

        lastReturned = list.header;

        list.addBeforeEntry(o, _next);

        ++_nextIndex;
        ++expectedModCount;
    }

    private final function checkForCoModification():void {
        if (list.modCount != expectedModCount)
            throw new ConcurrentModificationError();
    }
}

}
