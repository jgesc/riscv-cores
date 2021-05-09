#include "vec3f.h"

vec3f vec3f_add(vec3f * a, vec3f * b)
{
  vec3f r;
  int i;
  for(i = 0; i < 3; i++) r.v[i] = a->v[i] + b->v[i];
  return r;
}

void vec3f_addi(vec3f * a, vec3f * b)
{
  int i;
  for(i = 0; i < 3; i++) a->v[i] += b->v[i];
}

vec3f vec3f_sub(vec3f * a, vec3f * b)
{
  vec3f r;
  int i;
  for(i = 0; i < 3; i++) r.v[i] = a->v[i] - b->v[i];
  return r;
}

void vec3f_subi(vec3f * a, vec3f * b)
{
  int i;
  for(i = 0; i < 3; i++) a->v[i] -= b->v[i];
}

vec3f vec3f_mults(vec3f * v, float s)
{
  vec3f r;
  int i;
  for(i = 0; i < 3; i++) r.v[i] = v->v[i] * s;
  return r;
}

void vec3f_multsi(vec3f * v, float s)
{
  int i;
  for(i = 0; i < 3; i++) v->v[i] = v->v[i] * s;
}

void vec3f_divsi(vec3f * v, float s)
{
  int i;
  for(i = 0; i < 3; i++) v->v[i] = v->v[i] / s;
}

float vec3f_dot(vec3f * a, vec3f * b)
{
  float r = 0;
  int i;
  for(i = 0; i < 3; i++) r += a->v[i] * b->v[i];
  return r;
}

float vec3f_length(vec3f * v)
{
  float s = 0;
  int i;
  for(i = 0; i < 3; i++) s += v->v[i]*v->v[i];
  return sqrt(s);
}

void vec3f_normalizei(vec3f * v)
{
  vec3f_divsi(v, vec3f_length(v));
}

vec3f vec3f_new(float x, float y, float z)
{
  vec3f v = {x, y, z};
  return v;
}
