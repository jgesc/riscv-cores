#include "math.h"
#include "sphere.h"
#include "vec3f.h"

#define HEIGHT 16
#define WIDTH 16

// top of stack
extern unsigned __stacktop;

__asm__("addi	sp,zero,1");
__asm__("slli	sp,sp,22");
__asm__("call main");

vec3f cast_ray(vec3f* o, vec3f* d, Sphere* sphere) {
  float dist = 10000.0;
  if (!sphere_intersect(sphere, o, d, &dist)) {
      vec3f r = {0.2, 0.7, 0.8};
      return r;
  }
  vec3f r = {0.4, 0.4, 0.3};
  return r;
}

void render(Sphere* sphere)
{
  float fov = 1.48;

  vec3f framebuffer[HEIGHT * WIDTH];

  vec3f o = {0};

  float tan_fov = tan(fov/2.);

  int i, j;
  for (j = 0; j<HEIGHT; j++)
  {
    for (i = 0; i<WIDTH; i++)
    {
      float x =  (2*(i + 0.5)/(float)WIDTH  - 1)*tan_fov*WIDTH/(float)HEIGHT;
      float y = -(2*(j + 0.5)/(float)HEIGHT - 1)*tan_fov;

      vec3f dir = {x, y, -1};
      vec3f_normalizei(&dir);

      framebuffer[i+j*WIDTH] = cast_ray(&o, &dir, sphere);
    }
  }

  vec3f * result = 0x00000000;
  for(i = 0; i < WIDTH * HEIGHT; i++) result[i] = framebuffer[i];
}

int main(void) {
  Sphere sphere = sphere_new(vec3f_new(-3, 0, -16), 2);

  render(&sphere);

  __asm__("ebreak");
}
