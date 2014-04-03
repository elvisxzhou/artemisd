module artemisd.world;

import artemisd.utils.bag;
import artemisd.entitymanager;
import artemisd.entity;
import artemisd.entitytemplate;
import artemisd.componentmanager;
import artemisd.entitysystem;
import artemisd.manager;
import artemisd.entityobserver;

class World 
{
    private EntityManager em;
    private ComponentManager cm;

    public float delta;
    private Bag!Entity added;
    private Bag!Entity changed;
    private Bag!Entity deleted;
    private Bag!Entity enabled;
    private Bag!Entity disabled;

    private Manager[] managers;
    
    private EntitySystem[] systems;
    
    this() 
    {
        managers.length = 1;
        systems.length = 1;

        added = new Bag!Entity();
        changed = new Bag!Entity();
        deleted = new Bag!Entity();
        enabled = new Bag!Entity();
        disabled = new Bag!Entity();

        cm = new ComponentManager();
        setManager(cm);
        
        em = new EntityManager();
        setManager(em);
    }

    void initialize() 
    {
        foreach(m; managers)
        {
            if(m) m.initialize();
        }

        foreach(s;systems)
        {
            if(s) s.initialize();
        }
    }
    
    EntityManager getEntityManager() 
    {
        return em;
    }
    
    ComponentManager getComponentManager() 
    {
        return cm;
    }

    T setManager(T)(T manager) 
        if( is(T:Manager) )
    {
        import std.stdio;
        if(managers.length <= T.TypeId)
            managers.length = T.TypeId + 1;
        managers[T.TypeId] = manager;
        manager.setWorld(this);

        debug
        {
            import std.stdio;
            writeln(typeid(manager), "(", T.TypeId, ")", " added");
        }
        return manager;
    }

    T getManager(T)() 
        if( is(T:Manager) )
    {
        return cast(T)managers[T.TypeId];
    }
    
    void deleteManager(M)()
        if( is(M:Manager))
    {
        managers[M.TypeId] = null;
    }
    
    float getDelta() 
    {
        return delta;
    }

    void setDelta(float delta) 
    {
        this.delta = delta;
    }
    
    void addEntity(Entity e) 
    {
        added.add(e);
    }
    
    void changedEntity(Entity e) 
    {
        changed.add(e);
    }
    
    void deleteEntity(Entity e) 
    {
        if (!deleted.contains(e)) 
        {
            deleted.add(e);
        }
    }

    void enable(Entity e) 
    {
        enabled.add(e);
    }

    void disable(Entity e) 
    {
        disabled.add(e);
    }

    Entity createEntity() 
    {
        return em.createEntityInstance();
    }

    Entity createEntityFromTemplate(T : EntityTemplate, Args...)(Args args) {
        Entity entity = em.createEntityInstance();
        T.buildEntity(entity, this, args);
        return entity;
    }

    Entity getEntity(int entityId) 
    {
        return em.getEntity(entityId);
    }

    EntitySystem[] getSystems() 
    {
        return systems;
    }

    T setSystem(T)(T system) 
        if( is(T:EntitySystem) )
    {
        return setSystem!T(system, false);
    }

    T setSystem(T)(T system, bool passive) 
    {
        system.setWorld(this);
        system.setPassive(passive);
        
        if( systems.length <= T.TypeId )
            systems.length = T.TypeId + 1;
        systems[T.TypeId] = system;

        debug
        {
            import std.stdio;
            writeln(typeid(system), "(", T.TypeId, ")", " added");
        }   

        return system;
    }
    
    void deleteSystem(E)()
        if( is(E:EntitySystem) )
    {
        systems[E.TypeId] = null;
    }
    
    private void notifySystems(Performer performer, Entity e) 
    {
        foreach(s;systems)
        {
            if(s) performer.perform(s,e);
        }
    }

    private void notifyManagers(Performer performer, Entity e) 
    {
        foreach(m;managers)
        {
            if(m) performer.perform(m,e);
        }
    }
    
    T getSystem(T)()
        if( is(T:EntitySystem) )
    {
        return systems[T.TypeId];
    }

    private void check(Bag!Entity entities, Performer performer) 
    {
        if (!entities.isEmpty()) 
        {
            for (int i = 0; entities.size() > i; i++) 
            {
                Entity e = entities.get(i);
                notifyManagers(performer, e);
                notifySystems(performer, e);
            }
            entities.clear();
        }
    }

    void process() 
    {
        check(added, new class Performer {
            public void perform(EntityObserver observer, Entity e) {
                observer.added(e);
            }
        });
        
        check(changed, new class Performer {
            public void perform(EntityObserver observer, Entity e) {
                observer.changed(e);
            }
        });
        
        check(disabled, new class Performer {
            public void perform(EntityObserver observer, Entity e) {
                observer.disabled(e);
            }
        });
        
        check(enabled, new class Performer {
            public void perform(EntityObserver observer, Entity e) {
                observer.enabled(e);
            }
        });
        
        check(deleted, new class Performer {
            public void perform(EntityObserver observer, Entity e) {
                observer.deleted(e);
            }
        });
        
        cm.clean();
        
        foreach(s;systems)
        {
            if( s && !s.isPassive() )
                s.process();
        }
    }
    
    private interface Performer 
    {
        void perform(EntityObserver observer, Entity e);
    }
}