module artemisd.systems.voidentitysystem;

import artemisd.aspect;
import artemisd.entity;
import artemisd.entitysystem;
import artemisd.utils.type;
import artemisd.utils.bag;

public abstract class VoidEntitySystem : EntitySystem {
    mixin TypeDecl;

	public this() 
	{
		super(Aspect.getEmpty());
	}

	protected final override void processEntities(Bag!Entity entities) 
	{
		processSystem();
	}
	
	protected abstract void processSystem();

	protected override bool checkProcessing() 
	{
		return true;
	}
}
