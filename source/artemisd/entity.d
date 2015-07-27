module artemisd.entity;

import std.uuid;
import std.bitmanip;
import std.conv;
import artemisd.utils.bag;
import artemisd.world;
import artemisd.entitymanager;
import artemisd.component;
import artemisd.componentmanager;
import artemisd.entitysystem;

final class Entity 
{
    private UUID uuid;

    private int id;
    private BitArray componentBits;
    private BitArray systemBits;

    private World world;
    private EntityManager entityManager;
    private ComponentManager componentManager;
    
    this(World world, int id) 
    {
        this.world = world;
        this.id = id;
        this.entityManager = world.getEntityManager();
        this.componentManager = world.getComponentManager();
    
        reset();
    }

    public int getId() 
    {
        return id;
    }

    BitArray getComponentBits() 
    {
        return componentBits;
    }
    
    BitArray getSystemBits() 
    {
        return systemBits;
    }

    void reset() 
    {
        clearComponents();
        systemBits.length = EntitySystem.TypeNum;
        systemBits ^= systemBits;
        uuid = randomUUID();
    }

    void clearComponents()
    {
        componentBits.length = Component.TypeNum;
        componentBits ^= componentBits;
    }

    override string toString() 
    {
        return "Entity[" ~ to!string(uuid) ~ "(" ~ to!string(id) ~ ")]";
    }

    Entity addComponent(T)(T component) 
        if( is(T:Component) )
    {
        componentManager.addComponent!T(this,  component);
        return this;
    }

    Entity removeComponent(T)() 
    {
        componentManager.removeComponent!T(this);
        return this;
    }

    bool isActive() 
    {
        return entityManager.isActive(id);
    }
    
    bool isEnabled() 
    {
        return entityManager.isEnabled(id);
    }
    
    T getComponent(T)()
    {
        return componentManager.getComponent!T(this);
    }

    Bag!Component getComponents(Bag!Component fillBag) 
    {
        return componentManager.getComponentsFor(this, fillBag);
    }

    void addToWorld() 
    {
        world.addEntity(this);
    }
    
    void changedInWorld() 
    {
        world.changedEntity(this);
    }

    void deleteFromWorld() 
    {
        world.deleteEntity(this);
    }
    
    void enable() 
    {
        world.enable(this);
    }
    
    void disable() 
    {
        world.disable(this);
    }
    
    UUID getUuid() 
    {
        return uuid;
    }

    World getWorld() 
    {
        return world;
    }
}
