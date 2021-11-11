
#include <iostream>
#include <iomanip>
#include <vector>
#include <algorithm>
#include <iterator>
#include <numeric>
#include <limits>
#include <cmath>

template <typename T, typename Container>
T mean(const Container& c)
{
   // begin(..) will point to the first element in Container c
   // end(..) will point to the last element in Container c
   // the distance between them gives the number of elements
    size_t N = end(c) - begin(c);
    // first pass through all data (hidden in accumulate):
    T mean = std::accumulate(begin(c), end(c), T(0)) / N;
    return mean;
}

template <typename T, typename Container>
T variance(const Container& c)
{
   // begin(..) will point to the first element in Container c
   // end(..) will point to the last element in Container c
   // the distance between them gives the number of elements
    size_t N = end(c) - begin(c);
    // first pass through all data (hidden in accumulate):
    T mean = std::accumulate(begin(c), end(c), T(0)) / N;
    // the use of variable name s2 is intentional; the calculation a correction 
    // for sample bias to reach "unbiased sample variance" aka s2 
    T s2 = 0;
    T besselsCorrection = (N-1);
    // NB - the actual variance calcluation effectively requires a second pass through all elements
    for(auto element : c) {
        s2 += (element - mean) * 2;
    }
    return s2 / (besselsCorrection);
}

template <typename T, typename Container>
T standard_deviation(const Container& c)
{
   // begin(..) will point to the first element in Container c
   // end(..) will point to the last element in Container c
   // the distance between them gives the number of elements
    size_t N = end(c) - begin(c);
    // first pass through all data is inside accumulate()
    T mean = std::accumulate(begin(c), end(c), T(0)) / N;

    // the use of variable name s2 is intentional; the calculation a correction 
    // for sample bias to reach "unbiased sample variance" aka s2 
    T sd = 0;
    T besselsCorrection = (N-1);
    // NB - the actual variance calcluation effectively requires a second pass through all elements
    for(auto element : c) {
        sd += pow((element - mean),2);
    }
    return sd / (besselsCorrection);
}

template <typename T, typename Container>
T root_mean_square_successive_differences(const Container& c)
{
    size_t N = end(c) - begin(c);

    std::vector<float> differences( end(c)-begin(c) );
    adjacent_difference(c.begin(), c.end(), differences.begin());

   //sum of squared differences
   T ssd = 0;
   printf( "adjacent_difference(s):\n" );
   for (std::vector<float>::const_iterator i = differences.begin()+1; i != differences.end(); ++i) {
        ssd += pow( std::abs(*i),2 );
        std::cout << *i << ' ' << ssd << " | " ;
   }
   T mssd = ssd / N;
   T rmssd = sqrt(mssd);

   return rmssd;
}

/*
 TimeDomainMeasures
 Calculates measurements from a sample heart period data set
 
 Input:
 ------
 - Beats/Minute [BPM] double values

 Outputs:
 ------
 - N
 - Min, Max
 - Sum (Accumulated)
 - Mean
 - Variance
 - Standard Deviation
 - Root Mean Square of Successive Deviations
 
 */

// TODO: 
// - scrub calculations based on successive differences: e.g. RMSSD
// - biased to vector<float> for now, type generalize...

class TimeDomainMeasures
{
   public:
      TimeDomainMeasures( );
      TimeDomainMeasures( std::vector<float> sampleSet );

      int N();

      float Min();
      float Max();

      float Mean();
      float Variance();
      float StandardDeviation();
      float RMSSD();
      float lnRMSSD();

    void processDataInner(const float *arrayOfFloats, int count, float *outputArray);
    
   private:
      int _N;

      float _sum = float(0.0);
      float _min = float(0.0);
      float _max = float(0.0);
      float _mean = float( 0.0 );
      float _variance = float( 0.0 );
      float _standardDeviation = float( 0.0 );
      float _RMSSD = float( 0.0 );
      float _lnRMSSD = float( 0.0 );
};

