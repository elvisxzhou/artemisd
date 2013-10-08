module artemisd.managers.groupmanager;

import artemisd.entity;
import artemisd.manager;
import artemisd.utils.bag;
import artemisd.utils.type;
import artemisd.utils.ext;

public class GroupManager : Manager {
  
    mixin TypeDecl;

    private Bag!Entity[string] entitiesByGroup;
    private Bag!string[Entity] groupsByEntity;

    protected override void initialize() {
    }
    
    public void add(Entity e, string group) {
        auto entities = entitiesByGroup.getWithDefault(group, new Bag!Entity);
        entities.add(e);

        auto groups = groupsByEntity.getWithDefault(e, new Bag!string);
        groups.add(group);
    }

    public void remove(Entity e, string group) {
        Bag!Entity* entities = group in entitiesByGroup;
        if(entities) {
            entities.remove(e);
        }
        
        Bag!string* groups = e in groupsByEntity;
        if(groups) {
            groups.remove(group);
        }
    }
    
    public void removeFromAllGroups(Entity e) {
        Bag!string* groups = e in groupsByEntity;
        if(groups != null) {
            for(int i = 0; groups.size() > i; i++) {
                Bag!Entity* entities = groups.get(i) in entitiesByGroup;
                if(entities != null) {
                    entities.remove(e);
                }
            }
            groups.clear();
        }
    }
    
    public Bag!Entity getEntities(string group) {
        return entitiesByGroup.getWithDefault(group, new Bag!Entity);
    }
    
    public Bag!string getGroups(Entity e) { 
        auto group = e in groupsByEntity;
        return group ? *group : null;
    }
    
    public bool isInAnyGroup(Entity e) {
        auto groups = getGroups(e);
        return groups !is null && groups.size > 0;
    }
    
    public bool isInGroup(Entity e, string group) {
        auto groups = e in groupsByEntity;
        return groups ? groups.contains(group) : false;
    }

    public override void deleted(Entity e) {
        removeFromAllGroups(e);
    }
}

unittest
{
    GroupManager gm = new GroupManager;
    import artemisd.world;
    World w = new World;
    Entity e = w.createEntity();
    gm.add(e,"g1");
    gm.add(e,"g2");
    assert(gm.isInGroup(e, "g1"));
    assert(gm.isInGroup(e, "g2"));
    assert(gm.isInAnyGroup(e));
    assert(gm.getGroups(e).toString() == "[g1,g2]");

    gm.remove(e,"g2");
    assert(gm.isInGroup(e, "g1"));
    assert(!gm.isInGroup(e, "g2"));
    assert(gm.isInAnyGroup(e));
    assert(gm.getGroups(e).toString() == "[g1]");

    gm.remove(e,"g1");
    assert(!gm.isInGroup(e, "g1"));
    assert(!gm.isInGroup(e, "g2"));
    assert(!gm.isInAnyGroup(e));
    assert(gm.getGroups(e).toString() == "[]");

    gm.add(e,"g1");
    gm.add(e,"g2");
    assert(gm.isInGroup(e, "g1"));
    assert(gm.isInGroup(e, "g2"));
    assert(gm.isInAnyGroup(e));
    gm.removeFromAllGroups(e);
    assert(!gm.isInGroup(e, "g1"));
    assert(!gm.isInGroup(e, "g2"));
    assert(!gm.isInAnyGroup(e));
}