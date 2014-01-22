module artemisd.entitytemplate;

import artemisd.entity;
import artemisd.world;

abstract class EntityTemplate {
  static Entity buildEntity(Args...)(Entity e, World world, Args args);
}