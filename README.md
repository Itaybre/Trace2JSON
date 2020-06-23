# Trace2JSON
Export Instrument's traces to JSON format

## Usage
```
USAGE: trace2json [--process <process>] [--pid <pid>] [--pretty] [--show-unsupported] [--output <output>] <path>

ARGUMENTS:
  <path>                  Path to .trace to parse. 

OPTIONS:
  --process <process>     Process Name to filter when available. 
  --pid <pid>             Process PID to filter when available. 
  --pretty                Enable JSON pretty print. 
  -s, --show-unsupported  Show unsupported instruments in output JSON. 
  -o, --output <output>   Output path. 
  -h, --help              Show help information.
```

## Requirements

- Xcode 11 and up
- MacOS 10.14+
- Xcode installed at path `/Applications/Xcode.app`

## TODO

- Cleanup code
- Add more instruments

## FAQ

#### Supported Instruments
- Activity Monitor
- Core Animation FPS
- Network Connections
- Leaks
- Allocations
- CPU Activity Impact

## Inspiration
[TraceUtility](https://github.com/Qusic/TraceUtility)

## Contact
Trace2JSON is developed by [Itay Brenner](https://www.twitter.com/itaybre).