module artemisd.managers.tagmanager;

import artemisd.entity;
import artemisd.manager;
import artemisd.utils.bag;
import artemisd.utils.type;
import artemisd.utils.ext;

public class TagManager : Manager 
{
    
	mixin TypeDecl;

	private Entity[string] entitiesByTag;
	private string[Entity] tagsByEntity;

	void register(string tag, Entity e) 
	{
		entitiesByTag[tag] = e;
		tagsByEntity[e] = tag;
	}

	void unregister(string tag) 
	{
        auto e = tag in entitiesByTag;
		if(e)
		{
			tagsByEntity.remove(*e);
			entitiesByTag.remove(tag);
		}
	}

	bool isRegistered(string tag) 
	{
		return (tag in entitiesByTag) !is null;
	}

	Entity getEntity(string tag) 
	{
		auto e = tag in entitiesByTag;
		return e ? *e : null;
	}
	
	public auto getRegisteredTags() 
	{
		return tagsByEntity.values;
	}
	
	override void deleted(Entity e) 
	{
		auto removedTag = e in tagsByEntity;
		if(removedTag) 
		{
			entitiesByTag.remove(*removedTag);
			tagsByEntity.remove(e);
		}
	}

	protected override void initialize() 
	{
	}
}
unittest
{
	TagManager m = new TagManager;
	import artemisd.world;
	World w = new World;
	Entity e = w.createEntity();

	m.register("g1",e);
	assert(m.isRegistered("g1"));
	assert(m.getEntity("g1") == e);
	m.unregister("g1");
	assert(!m.isRegistered("g1"));
	assert(m.getEntity("g1") is null);
}