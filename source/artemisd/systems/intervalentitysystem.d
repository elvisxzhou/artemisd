module artemisd.systems.intervalentitysystem;

import artemisd.aspect;
import artemisd.entitysystem;
import artemisd.utils.type;

public abstract class IntervalEntitySystem : EntitySystem {
    mixin TypeDecl;

	private float acc;
	private float interval;

	public this(Aspect aspect,float interval) 
	{
		super(aspect);
		this.interval = interval;
	}

	protected override bool checkProcessing() 
	{
		acc += world.getDelta();
		if(acc >= interval) 
		{
			acc -= interval;
			return true;
		}
		return false;
	}
}
