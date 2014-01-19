module artemisd.componentmanager;

import std.bitmanip;
import artemisd.utils.bag;
import artemisd.manager;
import artemisd.component;
import artemisd.entity;
import artemisd.utils.ext;
import artemisd.utils.type;

class ComponentManager : Manager 
{
    mixin TypeDecl;

    private Bag!(Bag!Component) componentsByType;
    private Bag!Entity _deleted;

    this() 
    {
        componentsByType = new Bag!(Bag!Component)();
        _deleted = new Bag!Entity();
    }
    
    protected override void initialize() 
    {
    }

    private void removeComponentsOfEntity(Entity e) 
    {
        BitArray componentBits = e.getComponentBits();
        for (size_t i = 0; i < componentBits.length; i++)
        {
            componentsByType.get(i).set(e.getId(), null);
        }
        componentBits.clear();
    }
    
    protected void addComponent(T)(Entity e, T component) 
        if( is(T:Component) )
    {
        componentsByType.ensureCapacity(T.TypeId);
        
        Bag!Component components = componentsByType.get(T.TypeId);
        if(components is null) 
        {
            components = new Bag!Component();
            componentsByType.set(T.TypeId, components);
        }
        
        components.set(e.getId(), component);

        e.getComponentBits()[T.TypeId] = 1;
    }

    protected void removeComponent(T)(Entity e)
        if( is(T:Component) )
    {
        if(e.getComponentBits().get(T.TypeId)) 
        {
            componentsByType.get(T.TypeId).set(e.getId(), null);
            e.getComponentBits().clear(T.TypeId);
        }
    }
    
    protected Bag!Component getComponents(T)()
        if( is(T:Component) )
    {
        Bag!Component components = componentsByType.get(T.TypeId);
        if(components == null) 
        {
            components = new Bag!Component();
            componentsByType.set(T.TypeId, components);
        }
        return components;
    }
    
    protected T getComponent(T)(Entity e)
        if( is(T:Component) )
    {
        Bag!Component components = componentsByType.get(T.TypeId);
        if(components !is null) 
        {
            return cast(T)(components.get(e.getId()));
        }
        return null;
    }
    
    Bag!Component getComponentsFor(Entity e, Bag!Component fillBag) 
    {
        BitArray componentBits = e.getComponentBits();

        for (size_t i = 0; i < componentBits.length; i++)
        {
            fillBag.add(componentsByType.get(i).get(e.getId()));
        }
        
        return fillBag;
    }

    
    override void deleted(Entity e) 
    {
        _deleted.add(e);
    }
    
    void clean() 
    {
        if(_deleted.size() > 0) 
        {
            for(int i = 0; _deleted.size() > i; i++) 
            {
                removeComponentsOfEntity(_deleted.get(i));
            }
            _deleted.clear();
        }
    }
}
