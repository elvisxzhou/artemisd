module artemisd.entitytemplate;

import artemisd.entity;
import artemisd.world;
import artemisd.utils.type;

abstract class EntityTemplate 
{
  mixin TypeDecl;

  static Entity buildEntity(Args...)(Entity e, World world, Args args);
}