module artemisd.utils.type;

mixin template TypeDecl()
{
	static if(!__traits(compiles,TypeNum))
	{
		static uint TypeNum = 0;
		enum BaseType = typeid(typeof(this));
		uint GetTypeId();
	}

	static uint TypeId;

	static if(!__traits(isAbstractClass,typeof(this)))
	{
		override uint GetTypeId()
		{
			return TypeId;
		}

		static this()
		{
			TypeId = TypeNum++;
			debug
			{
				import std.stdio;
				import std.array;
				writeln(typeid(typeof(this)), ":", BaseType.toString().split(".")[$-1], " Registered with TypeId = ", TypeId); 
			}
		}
	}
}

