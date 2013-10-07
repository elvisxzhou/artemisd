module artemisd.manager;

import artemisd.world;
import artemisd.entity;
import artemisd.entityobserver;
import artemisd.utils.type;

abstract class Manager : EntityObserver 
{
    mixin TypeDecl;

	protected World world;
	
	void initialize();

	final void setWorld(World world) 
	{
		this.world = world;
	}

	final World getWorld() 
	{
		return world;
	}
	
	public void added(Entity e) 
	{
	}
	
	public void changed(Entity e) 
	{
	}
	
	public void deleted(Entity e) 
	{
	}
	
	public void disabled(Entity e) 
	{
	}
	
	public void enabled(Entity e) 
	{
	}
}
