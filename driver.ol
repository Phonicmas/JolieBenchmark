from console import Console
from exec import Exec
from runtime import Runtime
from time import Time

type programInfo {
    program: string
    warmup: int
}

interface DriverInterface{
    RequestResponse:
        OpenProgram(programInfo)(int),

        RunProgram(void)(int),

        CloseProgram(void)(int),

        GetJavaVirtualMemory(void)(int),

        GetActualMemory(void)(int),

        GetOpenChannels(void)(int),

        GetCPULoad(void)(int),

        Shutdown(void)(void)
}

interface BenchmarkTargetInterface {
        requestResponse: Run (undefined)(undefined)
}

service Driver {

    execution: single

    embed Console as console
    embed Runtime as runtime
    embed Time as time

    inputPort Driver{
        location: "socket://localhost:8001"
        protocol: http {}
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

            loadEmbeddedService@runtime({ .filepath = request.program .type = "Jolie" .service = "run"})(BenchmarkTarget.location)
            println@console("loadEmbeddedService done")()

            response = 0
        }
        ]

        [ RunProgram (request) (response) {
            getCurrentTimeMillis@time()(startT)

            Run@BenchmarkTarget()()
            
            getCurrentTimeMillis@time()(endT)
            
            println@console("running program")()
            println@console((endT - startT))()
            
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
            println@console("getting VMem")()
            response = VMem.memory.used
        }
        ]

        [ GetActualMemory (request) (response) {
            //commitedMemory@BenchmarkService()(commitedMemory)
            println@console("getting AMem")()
            //response = commitedMemory
            response = 0
        }
        ]

        [ GetOpenChannels (request) (response) {
            stats@runtime()(openChannels)
            println@console("getting open channels")()
            response = openChannels.files.openCount
        }
        ]

        [ GetCPULoad (request) (response) {
            //CPULoad@BenchmarkService()(CPULoad)
            println@console("getting cpu load")()
            //response = CPULoad
            response = 0
        }
        ]

        [ shutdown () () {
            exit
        }
        ]
    }
}