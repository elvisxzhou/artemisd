module example;
       
import std.stdio;
import artemisd.all;

final class Position : Component
{
    mixin TypeDecl;

    float x;
    float y;

    this(float x, float y)
    {
        this.x = x;
        this.y = y;
    }
}

final class Velocity : Component
{
    mixin TypeDecl;

    float x;
    float y;

    this(float x, float y)
    {
        this.x = x;
        this.y = y;
    }
}

final class Renderer : Component
{
    mixin TypeDecl;
}

final class MovementSystem : EntityProcessingSystem
{
    mixin TypeDecl;

    this()
    {
        super(Aspect.getAspectForAll!(Position,Velocity));
    }

    override void process(Entity e)
    {
        Position pos = e.getComponent!Position;
        Velocity vel = e.getComponent!Velocity;

        assert(pos !is null);
        assert(vel !is null);

        pos.x += vel.x * world.getDelta();
        pos.y += vel.y * world.getDelta();

        writeln(e, " move to (", pos.x, ",", pos.y, ")");
    }
}

final class RenderSystem : EntityProcessingSystem
{
    mixin TypeDecl;

    this()
    {
        super(Aspect.getAspectForAll!(Position, Renderer));
    }

    override void process(Entity e)
    {
        Renderer rend = e.getComponent!Renderer;
        Position pos = e.getComponent!Position;
        assert(pos !is null);
        assert(rend !is null);

        writeln(e, " rendered at (", pos.x, ",", pos.y, ")");
    }
}

void main(string[] argv)
{
    World world = new World();
    world.setSystem(new MovementSystem);
    world.setSystem(new RenderSystem);
    world.initialize();

    Entity e = world.createEntity();
    e.addComponent(new Position(0,0));
    e.addComponent(new Velocity(10,0));
    e.addToWorld();

    Entity e1 = world.createEntity();
    e1.addComponent(new Position(0,0));
    e1.addComponent(new Velocity(10,0));
    e1.addComponent(new Renderer);
    e1.addToWorld();

    import core.thread;
    
    while(true)
    {
        world.setDelta(1/60.0f);
        world.process();
        Thread.sleep(1000.msecs);
    }
}
