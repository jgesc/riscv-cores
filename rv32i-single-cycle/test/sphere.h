#ifndef __SPHERE_H__
#define __SPHERE_H__

#include "math.h"
#include "vec3f.h"

typedef struct Sphere {
  vec3f c;
  float r;
  vec3f col;
} Sphere;

int sphere_intersect(Sphere* sphere, vec3f* o, vec3f* dir, float * d);

Sphere sphere_new(vec3f c, float r, vec3f col);

#endif
