module artemisd.systems.delayedentityprocessingsystem;

import artemisd.aspect;
import artemisd.entity;
import artemisd.entitysystem;
import artemisd.utils.type;
import artemisd.utils.bag;

abstract class DelayedEntityProcessingSystem : EntitySystem 
{
    mixin TypeDecl;

    private float delay;
    private bool running;
    private float acc;

    public this(Aspect aspect) 
    {
        super(aspect);
    }

    protected final override void processEntities(Bag!Entity entities) 
    {
        for (size_t i = 0, s = entities.size(); s > i; i++) 
        {
            Entity entity = entities.get(i);
            processDelta(entity, acc);
            float remaining = getRemainingDelay(entity);
            if(remaining <= 0) 
            {
                processExpired(entity);
            } 
            else 
            {
                offerDelay(remaining);
            }
        }
        stop();
    }
    
    protected  override void inserted(Entity e) 
    {
        float delay = getRemainingDelay(e);
        if(delay > 0) 
        {
            offerDelay(delay);
        }
    }
    
    protected abstract float getRemainingDelay(Entity e);
    
    protected final override bool checkProcessing() 
    {
        if(running) 
        {
            acc += world.getDelta();
            
            if(acc >= delay) 
            {
                return true;
            }
        }
        return false;
    }

    protected abstract void processDelta(Entity e, float accumulatedDelta);
    protected abstract void processExpired(Entity e);

    public void restart(float delay) 
    {
        this.delay = delay;
        this.acc = 0;
        running = true;
    }
    
    public void offerDelay(float delay) 
    {
        if(!running || delay < getRemainingTimeUntilProcessing()) 
        {
            restart(delay);
        }
    }
    
    public float getInitialTimeDelay() 
    {
        return delay;
    }
    
    public float getRemainingTimeUntilProcessing() 
    {
        if(running) 
        {
            return delay-acc;
        }
        return 0;
    }
    
    public bool isRunning() 
    {
        return running;
    }
    
    public void stop() 
    {
        this.running = false;
        this.acc = 0;
    }
}
