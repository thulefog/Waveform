# Waveforms

# Abstract

`Waveforms` is a workbench iOS application that illustrates scaffolding to retrieve and display time series data streams. 

The initial implementation is focused on handling Electrocardiogram signals - querying for and displaying one signal. 

The ECG time series are queried from a the `HealthKit` store, Apple Watch captured. 

## User Interface 

The user interface under construction is illustrated below.

| Waveform | 
|--|
|<img src="/images/waveform.png" alt="waveform" width="512">|

## Software Blueprint

The rough blueprint for key areas in the iOS application system are as follows:

- Type System
- Providers
- Adapters
- Algorithms 
- Views

The `Providers` represents building blocks, roughly aligned with CQRS such as Readers or Writers or interfaces that package underlying application logic.

The `Adapters` layer provides the interface encapsulation around the `HealthKit` calls, primarily read only query paths in this vertical. 

There is `Algorithm` code with implementations in both the Swift and C++ languages with a focus on time series signal analysis, ECG and HRV.

Note that much of this code is from my previous work over time, scrubbed and evolved forward but largely kept intact. In past projects in select concept proof verticals, there potentially was Objective-C code 

# References

# Software License

The rest of the source code is under the MIT License as per below:

MIT License

Copyright (c) 2025 John Matthew Weston

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.