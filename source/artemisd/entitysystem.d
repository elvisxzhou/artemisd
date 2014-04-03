module artemisd.entitysystem;

import std.bitmanip;
import std.algorithm;
import core.bitop;
import artemisd.utils.bag;
import artemisd.aspect;
import artemisd.entityobserver;
import artemisd.world;
import artemisd.entity;
import artemisd.utils.ext;
import artemisd.utils.type;

abstract class EntitySystem : EntityObserver 
{
    mixin TypeDecl;

    private const int systemIndex;

    protected World world;

    private Bag!Entity actives;

    private Aspect aspect;

    private BitArray allSet;
    private BitArray exclusionSet;
    private BitArray oneSet;

    private bool passive;

    private bool dummy;

    this(Aspect aspect) 
    {
        actives = new Bag!Entity();
        this.aspect = aspect;
        allSet = aspect.getAllSet();
        exclusionSet = aspect.getExclusionSet();
        oneSet = aspect.getOneSet();
        systemIndex = GetTypeId();
        dummy = allSet.isEmpty() && oneSet.isEmpty(); // This system can't possibly be interested in any entity, so it must be "dummy"
    }
    
    protected void begin() {}

    final void process() 
    {
        if(checkProcessing()) 
        {
            begin();
            processEntities(actives);
            end();
        }
    }
    
    protected void end() {}
    
    protected void processEntities(Bag!Entity entities);
    protected bool checkProcessing();

    void initialize() {};
    protected void inserted(Entity e) {};
    protected void removed(Entity e) {};

    protected final void check(Entity e) 
    {
        if(dummy) return;

        bool contains = e.getSystemBits()[systemIndex];
        bool interested = true; // possibly interested, let's try to prove it wrong.
        
        BitArray componentBits = e.getComponentBits();

        // Check if the entity possesses ALL of the components defined in the aspect.
        if(!allSet.isEmpty()) 
        {
            for (size_t i = 0; i < allSet.length; i++)
            {
                if(allSet[i] && !componentBits[i]) 
                {
                    interested = false;
                    break;
                }
            }
        }
        
        // Check if the entity possesses ANY of the exclusion components, if it does then the system is not interested.
        if(!exclusionSet.isEmpty() && interested) 
        {
            interested = !exclusionSet.intersects(componentBits);
        }
        
        // Check if the entity possesses ANY of the components in the oneSet. If so, the system is interested.
        if(!oneSet.isEmpty()) 
        {
            interested = oneSet.intersects(componentBits);
        }

        if (interested && !contains) 
        {
            insertToSystem(e);
        } 
        else if (!interested && contains) 
        {
            removeFromSystem(e);
        }
    }

    private final void removeFromSystem(Entity e) 
    {
        actives.remove(e);
        e.getSystemBits()[systemIndex]=0;
        removed(e);
    }

    private final void insertToSystem(Entity e) 
    {
        actives.add(e);
        e.getSystemBits()[systemIndex] = 1;
        inserted(e);
    }
    
    final override void added(Entity e) 
    {
        check(e);
    }
    
    final override void changed(Entity e) 
    {
        check(e);
    }

    final override void deleted(Entity e) 
    {
        if(e.getSystemBits()[systemIndex]) 
        {
            removeFromSystem(e);
        }
    }
    
    final override void disabled(Entity e) 
    {
        if(e.getSystemBits()[systemIndex]) 
        {
            removeFromSystem(e);
        }
    }
    
    final override void enabled(Entity e) 
    {
        check(e);
    }
    
    final void setWorld(World world) 
    {
        this.world = world;
    }
    
    final bool isPassive() 
    {
        return passive;
    }

    final void setPassive(bool passive) 
    {
        this.passive = passive;
    }
    
    final Bag!Entity getActives() 
    {
        return actives;
    }
}
