module artemisd.managers.playermanager;

import artemisd.entity;
import artemisd.manager;
import artemisd.utils.bag;
import artemisd.utils.type;
import artemisd.utils.ext;

class PlayerManager : Manager 
{
    mixin TypeDecl;

	private string[Entity] playerByEntity;
	private Bag!Entity[string] entitiesByPlayer;

	public void setPlayer(Entity e, string player) 
	{
		removeFromPlayer(e);
		playerByEntity[e]=player;
		auto entities = entitiesByPlayer.getWithDefault(player, new Bag!Entity);
		entities.add(e);
	}
	
	public Bag!Entity getEntitiesOfPlayer(string player) 
	{
		return entitiesByPlayer.getWithDefault(player, new Bag!Entity);
	}
	
	public void removeFromPlayer(Entity e) 
	{
		auto player = e in playerByEntity;
		if(player) 
		{
			Bag!Entity* entities = (*player) in entitiesByPlayer;
			if(entities) 
			{
				entities.remove(e);
			}
		}
	}
	
	public string getPlayer(Entity e) 
	{
		return playerByEntity[e];
	}

	protected override void initialize() 
	{
	}

	public override void deleted(Entity e) 
	{
		removeFromPlayer(e);
	}
}

unittest
{
	import std.stdio;

	PlayerManager m = new PlayerManager;
	import artemisd.world;
	World w = new World;
	Entity e = w.createEntity();

	m.setPlayer(e,"g1");
	assert(m.getPlayer(e) == "g1");
	m.setPlayer(e,"g2");
	assert(m.getPlayer(e) == "g2");
	assert(m.getEntitiesOfPlayer("g2").size == 1 );
	assert(m.getEntitiesOfPlayer("g1").size == 0);
}