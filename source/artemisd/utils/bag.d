module artemisd.utils.bag;

final class Bag(E)
{
    this() 
    {
        this(64);
    }

    this(int capacity)
    {
        data = new E[capacity];
    }
    
    E remove(size_t index) 
    {
        assert(index >= 0 && index < size);
        E e = data[index]; // make copy of element to remove so it can be returned
        data[index] = data[--size_]; // overwrite item to remove with last element
        return e;
    }

    E removeLast() 
    {
        assert(size > 0);
        E e = data[--size_];
        return e;
    }

    bool remove(E e) 
    {
        for (size_t i = 0; i < size; i++) 
        {
            E e2 = data[i];

            if (e == e2) 
            {
                data[i] = data[--size_]; // overwrite item to remove with last element
                return true;
            }
        }

        return false;
    }
 
    bool contains(E e) 
    {
        for(size_t i = 0; size > i; i++) 
        {
            if(e == data[i]) 
            {
                return true;
            }
        }
        return false;
    }

    bool removeAll(Bag!E bag)
    {
        bool modified = false;

        for (size_t i = 0; i < bag.size(); i++) 
        {
            E e1 = bag.get(i);

            for (size_t j = 0; j < size; j++) 
            {
                E e2 = data[j];

                if (e1 == e2) 
                {
                    remove(j);
                    j--;
                    modified = true;
                    break;
                }
            }
        }

        return modified;
    }

    E get(size_t index) 
    {
        assert(index >=0 && index < data.length);
        return data[index];
    }

    @property size_t size() 
    {
        return size_;
    }

    @property void size(size_t size) 
    {
        size_ = size;
    }
    
    size_t getCapacity() 
    {
        return data.length;
    }
    
    bool isIndexWithinBounds(int index) 
    {
        return index < getCapacity();
    }

    bool isEmpty() 
    {
        return size == 0;
    }

    void add(E e) 
    {
        if (size == data.length) 
        {
            grow();
        }

        data[size_++] = e;
    }

    void set(int index, E e) 
    {
        ensureCapacity(index);
        size = index+1;
        data[index] = e;
    }
    
    void ensureCapacity(int index) 
    {
        if(index >= data.length) 
        {
            grow(index*2);
        }
    }

    void clear() 
    {
        data.length = 0;
        size = 0;
    }

    void addAll(Bag!E items) 
    {
        for(size_t i = 0; items.size() > i; i++) 
        {
            add(items.get(i));
        }
    }

    override string toString()
    {
        import std.conv;
        import std.array;
        auto s = appender!string;
        s.put("[");
        for(size_t i = 0; size > i; i++)
        {
            if( i > 0 )
                s.put(",");
            s.put(to!string(data[i]));
        }
        s.put("]");
        return s.data; 
    }
private:

    void grow() 
    {
        size_t newCapacity = (data.length * 3) / 2 + 1;
        grow(newCapacity);
    }
    
    void grow(size_t newCapacity) 
    {
        data.length = newCapacity;
    }
    
    E[] data;
    size_t size_;
}
