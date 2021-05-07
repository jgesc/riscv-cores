#include "sphere.h"

int sphere_intersect(Sphere* sphere, vec3f* o, vec3f* dir, float * d)
{
  vec3f L = vec3f_sub(&sphere->c, o);
  float tca = vec3f_dot(&L, dir);
  float d2 = vec3f_dot(&L, &L) - tca*tca;
  if (d2 > (sphere->r)*(sphere->r)) return 0;
  float thc = sqrt((sphere->r) * (sphere->r) - d2);
  *d = tca - thc;
  float t0 = tca - thc;
  float t1 = tca + thc;
  if (t0 < 0) t0 = t1;
  if (t0 < 0) return 0;
  return 1;
}

Sphere sphere_new(vec3f c, float r)
{
  Sphere sphere;

  sphere.c.x = c.x;
  sphere.c.y = c.y;
  sphere.c.z = c.z;
  sphere.r = r;

  return sphere;
}
