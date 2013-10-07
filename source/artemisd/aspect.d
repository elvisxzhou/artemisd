module artemisd.aspect;

import std.bitmanip;
import artemisd.component;

void set(alias ba, T,R...)() if( is(T:Component) )
{
    if( ba.length < T.TypeId + 1 )
        ba.length = T.TypeId + 1;
    ba[T.TypeId] = 1;

    static if( R.length )
        set!(ba, R)();
}

final class Aspect 
{
	private BitArray allSet;
	private BitArray exclusionSet;
	private BitArray oneSet;
	
	BitArray getAllSet() 
	{
		return allSet;
	}
	
	BitArray getExclusionSet() 
	{
		return exclusionSet;
	}
	
	BitArray getOneSet() 
	{
		return oneSet;
	}
	
	Aspect all(T...)() 
	{
        set!(allSet, T)();
		return this;
	}
	
	Aspect exclude(T...)() 
	{
        set!(exclusionSet, T)();
		return this;
	}
	
	Aspect one(T...)() 
	{
        set!(oneSet, T)();
		return this;
	}

	static Aspect getAspectFor(T...)() 
	{
		return getAspectForAll!T();
	}
	
	static Aspect getAspectForAll(T...)() 
	{
		Aspect aspect = new Aspect();
		aspect.all!T();
		return aspect;
	}
	
	static Aspect getAspectForOne(T...)() 
	{
		Aspect aspect = new Aspect();
		aspect.one!T();
		return aspect;
	}
	
	static Aspect getEmpty() 
	{
		return new Aspect();
	}
}
