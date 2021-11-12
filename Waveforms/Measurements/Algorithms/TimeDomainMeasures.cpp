

#include "TimeDomainMeasures.h"

// TODO: type generalize
// EXAMPLE: const std::vector<T>& set  

TimeDomainMeasures::TimeDomainMeasures()
{

}

void TimeDomainMeasures::processDataInner(const float *inputArray, int count, float *outputArray) {
    std::cout << "Received an array is of size " << count << '\n';

    const float *ptr = &inputArray[0];
    // simple algorithm - multiples input times 2
    for(int j=0; j < count; j++){
        outputArray[j] = *ptr * 2 ;
        std::cout << "Array element [" << *ptr << "]" << '\n';
        *ptr++;
    }
}

TimeDomainMeasures::TimeDomainMeasures(std::vector<float> sampleSet )
{
    size_t N = sampleSet.size();
    _N = (int)N;
    auto hilo = std::minmax_element(sampleSet.begin(), sampleSet.end());
    _min = *hilo.first;
    _max = *hilo.second;
    _sum = std::accumulate(begin(sampleSet), end(sampleSet), 0 );
    _mean = mean<float>( sampleSet );
    _variance = variance<float>( sampleSet );
    _standardDeviation = standard_deviation<float>( sampleSet );
    _RMSSD = root_mean_square_successive_differences<float>( sampleSet );
    _lnRMSSD = log( _RMSSD );
}

int TimeDomainMeasures::N()
{
    return _N; 
}

float TimeDomainMeasures::Min()
{
    return _min; 
}

float TimeDomainMeasures::Max()
{
    return _max; 
}

float TimeDomainMeasures::Mean()
{
    return _mean; 
}

float TimeDomainMeasures::Variance()
{
    return _variance; 
}

float TimeDomainMeasures::StandardDeviation()
{
    return _standardDeviation; 
}

float TimeDomainMeasures::RMSSD()
{
    return _RMSSD; 
}

float TimeDomainMeasures::lnRMSSD()
{
    return _lnRMSSD; 
}
