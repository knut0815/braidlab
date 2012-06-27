//
// Matlab MEX file
//
// COMPACT   Shorten a braid word.
//

// Use the group relations to shorten a braid word as much as
// possible.

// The commute-and-cancel algorithm is from Bangert et al. (2002).

#include <iostream>
#include <vector>
#include <algorithm>
#include "mex.h"

#undef  BRAIDLAB_BANGERT_RESTORE

extern void _main();


//
// "Commute-and-cancel" is described succinctly in Bangert et
// al. (2002), p. 52; for a braid A,
//
//   "We begin with the leftmost generator of A and attempt to move it
//   to the right using both braid group operations. If we can cancel
//   it along the way, we do so and if we cannot, we move it back to
//   where it started. In this way, we proceed to move all the
//   generators as far to the right as possible. Then we begin at the
//   end and move each generator as far to the left as possible in the
//   same manner."
//
// It isn't completely clear to me what moving a generator using the
// second relation actually means.  In the implementation below, while
// moving to the right a sequence such as 121 is turned into 212, and
// the "position" is updated from the first 1 of 121 to the final 2 of
// 212.
//
// I also don't see the point of moving the generator back to where it
// started.  It works faster (and even better) to just leave it there.
// This behavior is controlled by BRAIDLAB_BANGERT_RESTORE.
//

template<class T>
inline
bool commute_and_cancel(T& b, const int dir)
{
  if (b.empty()) return false;

  bool shorter = false;
  mwIndex pos0 = 0; // pos0 is the starting point of the "current" generator.
  do
    {
      bool incrpos = false;
      // dir=1 means start from the begining, dir=-1 from the end.
      mwIndex i = (dir == 1 ? pos0 : b.size()-1-pos0);
#ifdef BRAIDLAB_BANGERT_RESTORE
      T b0(b);      // Save the braid.
#endif
      do
        {
          if (b[i] == -b[i+dir] && b[i] != 0)
            {
              // Cancel with the generator on the left.
              b[i] = b[i+dir] = 0;
              shorter = true;
              break;
            }
          if (abs(abs(b[i]) - abs(b[i+dir])) > 1)
            {
              // Commute with the next generator.
              std::swap(b[i],b[i+dir]);
              i += dir;
              incrpos = true;
              continue;
            }
          if (i+2*dir >= 0 && i+2*dir <= b.size()-1)
            {
              // Try the second type of relation.
              if ((b[i]+1 == b[i+dir] || b[i]-1 == b[i+dir])
                  && b[i] == b[i+2*dir])
                {
                  std::swap(b[i],b[i+dir]);
                  b[i+2*dir] = b[i];
                  i += 2*dir;
                  incrpos = true;
                  continue;
                }
            }
          // Nothing happened: break out of the loop to increase pos0
          // and try again.
#ifdef BRAIDLAB_BANGERT_RESTORE
          b = b0;   // Restore braid, so generator moves back to its
                    // initial position.
#endif
          incrpos = true;
          break;
        } while (i+dir >= 0 && i+dir <= b.size()-1);
      // remove 0's from the vector.
      b.erase(remove(b.begin(),b.end(),0),b.end());
      if (b.empty()) break;
      if (incrpos) ++pos0;
    } while (pos0 < b.size()-1);

  return shorter; // true if actually shorter than upon entry.
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  using std::cout;
  using std::endl;
  using std::max;
  typedef std::vector<int>::iterator vecit;
  typedef std::vector<int>::const_iterator veccit;

  // Arguments checked and formatted in compact.m.

  const mxArray *wA = prhs[0];
  const int *w = (int *)mxGetData(wA); // wA contains int32's.
  const mwSize N = max(mxGetM(wA),mxGetN(wA));
  int n = 1;

  // Convert braid word to vector.
  std::vector<int> bw;
  for (mwIndex i = 0; i < N; ++i)
    {
      n = max(n,abs(w[i])+1);
      bw.push_back(w[i]);
    }

  // Try to commute_and_cancel from the left/right until nothing changes.
  while (commute_and_cancel(bw,1) || commute_and_cancel(bw,-1)) {}

  // Now copy vector bw to an mxArray of int32's.
  plhs[0] = mxCreateNumericMatrix(1,bw.size(),mxINT32_CLASS,mxREAL);
  int *bwp = (int *)mxGetData(plhs[0]);
  mwIndex k = 0;
  for (veccit it = bw.begin(); it != bw.end(); ++it, ++k)
    {
      bwp[k] = *it;
    }
}