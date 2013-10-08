module artemisd.systems.entityprocessingsystem;

import artemisd.aspect;
import artemisd.entity;
import artemisd.entitysystem;
import artemisd.utils.type;
import artemisd.utils.bag;

abstract class EntityProcessingSystem : EntitySystem 
{
    mixin TypeDecl;

    public this(Aspect aspect) 
    {
        super(aspect);
    }

    protected void process(Entity e);

    protected final override void processEntities(Bag!Entity entities) 
    {
        for (int i = 0, s = entities.size(); s > i; i++) 
        {
            process(entities.get(i));
        }
    }
    
    protected override bool checkProcessing() 
    {
        return true;
    }
}
