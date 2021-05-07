float sqrt(float x)
{
  float s, last;

  if (x > 0) {
      s = (x > 1) ? x : 1;
      do {
          last = s;
          s = (x / s + s) / 2;
      } while (s < last);
      return last;
  }

  return 0;
}

float tan(float x)
{
  const float c1 = 211.849369664121;
  const float c2 = -12.5288887278448;
  const float c3 = 269.7350131214121;
  const float c4 = -71.4145309347748;

  float x2 = x*x;

  return (x*(c1+ c2 * c2) / (c3 + x2*(c4+x2)));
}
