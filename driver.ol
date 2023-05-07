from console import Console
from exec import Exec
from runtime import Runtime
from time import Time
from string-utils import StringUtils

interface DriverInterface{
    RequestResponse:
        OpenProgram(string)(undefined),
        RunProgram(undefined)(long),
        CloseProgram(undefined)(int),
        GetJavaVirtualMemory(undefined)(long),
        GetActualMemory(undefined)(long),
        GetOpenChannels(undefined)(long),
        GetCPULoad(undefined)(long)
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

    inputPort Driver{
        location: "socket://localhost:8001"
        protocol: http
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
            println@console("Opening Program to be benchmarked")()
            println@console(valueToPrettyString@stringUtils(request))()
            loadEmbeddedService@runtime({.filepath = request})(BenchmarkTarget.location)
            println@console("Program to be benchmarked opened")()

            response = 0
        }
        ]

        [ RunProgram (request) (response) {
            getCurrentTimeMillis@time()(startT)

            println@console("running program")()
            Run@BenchmarkTarget()()
            println@console("done program")()

            getCurrentTimeMillis@time()(endT)
            
            println@console(valueToPrettyString@stringUtils((endT - startT)))()
            
            response = (endT - startT)
        }
        ]

        [ CloseProgram (request) (response) {
            callExit@runtime(BenchmarkTarget.location)()
            println@console("closing program")()
            response = 0
        }
        ]

        [ GetJavaVirtualMemory (request) (response) {
            stats@runtime()(VMem)
            response << VMem.memory.used
        }
        ]

        [ GetActualMemory (request) (response) {
            //commitedMemory@BenchmarkService()(commitedMemory)
            //response = commitedMemory
            response = 0
        }
        ]

        [ GetOpenChannels (request) (response) {
            stats@runtime()(openChannels)
            response = openChannels.files.openCount
        }
        ]

        [ GetCPULoad (request) (response) {
            //CPULoad@BenchmarkService()(CPULoad)
            //response = CPULoad
            response = 0
        }
        ]

        [ Shutdown () ] { exit }
    }
}