#ifndef __VEC3F_H__
#define __VEC3F_H__

#include "math.h"

typedef union {
  float v[3];
  struct {
    float x, y, z;
  };
} vec3f;

vec3f vec3f_add(vec3f * a, vec3f * b);

void vec3f_addi(vec3f * a, vec3f * b);

vec3f vec3f_sub(vec3f * a, vec3f * b);

void vec3f_subi(vec3f * a, vec3f * b);

vec3f vec3f_mults(vec3f * v, float s);

void vec3f_multsi(vec3f * v, float s);

void vec3f_divsi(vec3f * v, float s);

float vec3f_dot(vec3f * a, vec3f * b);

float vec3f_length(vec3f * v);

void vec3f_normalizei(vec3f * v);

vec3f vec3f_new(float x, float y, float z);

#endif
