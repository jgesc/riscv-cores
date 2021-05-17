#include "math.h"
#include "sphere.h"
#include "vec3f.h"

#define HEIGHT 512
#define WIDTH 512

#define N_SPHERES 4
#define R_SEED 373
#define R_MULT 1753

#define LIGHT_DIFUSE 0.2
#define MIRROR_MULT 0.8

#define ENABLE_ADVANCED

// top of stack
extern unsigned __stacktop;

__asm__("addi	sp,zero,1");
__asm__("slli	sp,sp,22");
__asm__("call main");

vec3f cast_ray(vec3f* o, vec3f* d, Sphere* spheres, int nspheres, vec3f* light, int mirror)
{
  float mindist = 10000.0;
  vec3f pixcol = {0.2, 0.7, 0.8};

  float curdist;
  int i;
  for(i = 0; i < nspheres; i++)
  {
	  if (sphere_intersect(spheres+i, o, d, &curdist))
	  {
		  if(curdist < mindist)
      {
  			mindist = curdist;

  			vec3f tmp = vec3f_mults(d, curdist);
  			vec3f hit = vec3f_add(o, &tmp);
  			vec3f normal = vec3f_sub(&hit, &spheres[i].c);
  			vec3f_normalizei(&normal);

  			vec3f lightdir = vec3f_sub(light, &hit);
  			vec3f_normalizei(&lightdir);

#ifdef ENABLE_ADVANCED
  			if(i != mirror)
  			{
  				int j;
  				float _;
  				int shadow = 0;
  				for(j = 0; j < nspheres; j++)
  				{
  					if(j == i) continue;
  					if(sphere_intersect(spheres+j, &hit, &lightdir, &_))
  					{
  						shadow = 1;
  						break;
  					}
  				}

  				if(shadow)
  				{
  					pixcol = vec3f_mults(&spheres[i].col, LIGHT_DIFUSE);
  				}
  				else
  				{
  					float lightmag = vec3f_dot(&lightdir, &normal);
  					float lighti = LIGHT_DIFUSE + (1-LIGHT_DIFUSE) * (lightmag < 0 ? 0 : lightmag);

  					pixcol = vec3f_mults(&spheres[i].col, lighti);
  				}
  			}
  			else
  			{
  				pixcol = cast_ray(&hit, &normal, spheres, nspheres-1, light, -1);
  				vec3f_multsi(&pixcol, MIRROR_MULT);
  			}
#else
        float lightmag = vec3f_dot(&lightdir, &normal);
        float lighti = LIGHT_DIFUSE + (1-LIGHT_DIFUSE) * (lightmag < 0 ? 0 : lightmag);
        pixcol = vec3f_mults(&spheres[i].col, lighti);
#endif
		  }
	  }
  }

  return pixcol;
}

void render(Sphere* spheres, int nspheres, vec3f* light, int mirror)
{
  float fov = 1.48 / 4;

  vec3f framebuffer[HEIGHT * WIDTH];

  vec3f o = {0};

  float tan_fov = tan(fov);

  int i, j;
  for (j = 0; j<HEIGHT; j++)
  {
    for (i = 0; i<WIDTH; i++)
    {
      float x =  (2*(i + 0.5)/(float)WIDTH  - 1)*tan_fov*WIDTH/(float)HEIGHT;
      float y = -(2*(j + 0.5)/(float)HEIGHT - 1)*tan_fov;

      vec3f dir = {x, y, -1};
      vec3f_normalizei(&dir);

      framebuffer[i+j*WIDTH] = cast_ray(&o, &dir, spheres, nspheres, light, mirror);
    }
  }

  vec3f * result = 0x00000000;
  for(i = 0; i < WIDTH * HEIGHT; i++) result[i] = framebuffer[i];
}

int main(void) {
  Sphere spheres[N_SPHERES];

  spheres[0] = sphere_new(
		vec3f_new(1, 0, -12),
		2,
		vec3f_new(0.847453, 0.337159, 0.410058));
  spheres[1] = sphere_new(
		vec3f_new(-2, -2, -12),
		1,
		vec3f_new(0.686050, 0.710017, 0.158780));
  spheres[2] = sphere_new(
		vec3f_new(-4, -2, -14),
		2,
		vec3f_new(0.532424, 0.754010, 0.384699));
  spheres[N_SPHERES-1] = sphere_new(vec3f_new(10, 12, -20), 12, vec3f_new(0.4,0.4,0.2));

  vec3f lightpos = {6, 6, -6};
  render(spheres, N_SPHERES, &lightpos, N_SPHERES-1);

  __asm__("ebreak");
}
