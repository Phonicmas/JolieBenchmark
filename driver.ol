from console import Console
from exec import Exec
from runtime import Runtime
from time import Time
from string-utils import StringUtils
from metric_java_service import BenchmarkService

interface DriverInterface{
    RequestResponse:
        OpenProgram(string)(undefined),
        RunProgram(undefined)(long),
        CloseProgram(undefined)(int),
        GetJavaVirtualMemory(undefined)(long),
        GetActualMemory(undefined)(long),
        GetOpenChannels(undefined)(long),
        GetCPUSystemLoad(undefined)(double),
        GetCPUJVMLoad(undefined)(double)
    OneWay:
        Shutdown(undefined)
}

interface BenchmarkTargetInterface {
        requestResponse: Run (undefined)(undefined)
}

service Driver {

    execution: concurrent

    embed Console as console
    embed Runtime as runtime
    embed Time as time
    embed StringUtils as stringUtils
    embed BenchmarkService as benchmarkService

    inputPort Driver{
        location: "socket://localhost:8001"
        protocol: sodep
        interfaces: DriverInterface
    }

    outputPort BenchmarkTarget {
        interfaces: BenchmarkTargetInterface
    }

    init{
        println@console("Driver starting")()
    }

    main{
        [ OpenProgram (request) (response) {
            println@console("Opening Program (" + request + ") to be benchmarked")()
            loadEmbeddedService@runtime({.filepath = request})(t)
            global.benchmarkLocation = t
            response = 0
            println@console("Opened")()
        }
        ]

        [ RunProgram (request) (response) {
            BenchmarkTarget.location = global.benchmarkLocation

            getCurrentTimeMillis@time()(startT)
            
            Run@BenchmarkTarget()()
            
            getCurrentTimeMillis@time()(endT)

            response = (endT - startT)
        }
        ]

        [ CloseProgram (request) (response) {
            println@console("Closing program that was benchmarked")()
            callExit@runtime(BenchmarkTarget.location)()
            response = 0
        }
        ]

        [ GetJavaVirtualMemory (request) (response) {
            stats@runtime()(VMem)
            response << VMem.memory.used
        }
        ]

        [ GetActualMemory (request) (response) {
            stats@runtime()(VMem)
            response << VMem.memory.total
        }
        ]

        [ GetOpenChannels (request) (response) {
            stats@runtime()(openChannels)
            response = openChannels.files.openCount
        }
        ]

        [ GetCPUSystemLoad (request) (response) {
            CPUSystemLoad@benchmarkService()(CPUSLoad)
            response << CPUSLoad
        }
        ]

        [ GetCPUJVMLoad (request) (response) {
            CPUJVMLoad@benchmarkService()(CPUJLoad)
            response << CPUJLoad
        }
        ]

        [ Shutdown () ] { exit }
    }
}