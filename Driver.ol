from console import Console
from exec import Exec
from runtine import Runtime

type programInfo {
    program: string
    warmup: bool
}

interface DriverInterface{
    RequestResponse:
        OpenProgram(programInfo)(int),

        RunProgram(void)(int),

        CloseProgram(void)(int),

        GetJavaVirtualMemory(void)(int),

        GetActualMemory(void)(int),

        GetOpenChannels(void)(int),

        GetCompletionTime(void)(int),
}

interface BenchmarkTargetIface {
        requestResponse: run (undefined)(undefined)
}

service Driver {

    execution: single

    embed Console as console
    embed Runtime as runtime

    inputPort Driver{
        location: "socket://localhost:8000"
        protocol: http {}
        interfaces: DriverInterface
    }

    outputPort BenchmarkTarget {
        interfaces: BenchmarkTargetIface
    }

    main{
        println@console("Driver starting")()

        [ OpenProgram (request) (response) {

            //Would i need global variable for this?
            loadEmbeddedService@Runtime({ .filepath = request.program .type = "Jolie" .service = "run"})(BenchmarkTarget.location)

            //Runs the program a couple of times to warm it up
            if(request.warmup){
                for(i = 0, i < 100, i++){
                    RunProgram()()
                }
            }

            response = 0
        }
        ]

        [ RunProgram (request) (response) {
            
            Run@BenchmarkTarget()()

            response = 0
        }
        ]

        [ CloseProgram (request) (response) {
            callExit@runtime(BenchmarkTarget.location)()
            response = 0
        }
        ]

        [ GetJavaVirtualMemory (request) (response) {
            //Might need JavaService? - Stats.memory might cover this
            response = 0
        }
        ]

        [ GetActualMemory (request) (response) {
            //Might need JavaService?
            response = 0
        }
        ]

        [ GetOpenChannels (request) (response) {
            //Unsure how excatly to do this, does this work?
            temp << stats@runtime()(response2)
            response << temp.files.openCount
        }
        ]

        [ GetCompletionTime (request) (response) {
            //IGNORE to begin with
            response = 0
        }
        ]
    }
}