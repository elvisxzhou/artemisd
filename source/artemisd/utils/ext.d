module artemisd.utils.ext;

import std.bitmanip;
import core.bitop;
import std.algorithm;

bool isEmpty(BitArray ba)
{
    for(auto i=0; i<ba.dim(); ++i)
        if( ba.ptr[i] )
            return false;

    return true;
}

size_t nextSetBit(BitArray ba, size_t index)
{
    size_t u = index / ba.bitsPerSizeT;
    if( u >= ba.dim() ) return size_t.max;

    auto d = (index+1)%ba.bitsPerSizeT;
    size_t b = d > 0 ? ba.ptr[u] & (size_t.max<<d) : 0;
    while(true)
    {
        if( b )
        {
            return u*ba.bitsPerSizeT + bsf(b);
        }

        if( ++u >= ba.dim() )
            return size_t.max;

        b = ba.ptr[u];
    }
}

bool intersects(BitArray set1, BitArray set2) {
    auto dim = min(set1.dim(), set2.dim());
    for(auto i=0; i<dim; ++i)
    {
        if( (set1.ptr[i] & set2.ptr[i]) != 0 )
            return true;
    }
    return false;
}

auto ref getWithDefault(K,V)(ref V[K] aa, K key, lazy V defValue)
{
    auto p = key in aa;
    return p ? *p : (aa[key] = defValue());
}
