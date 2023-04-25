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

        RunProgram()(int),

        CloseProgram()(int),

        GetJavaVirtualMemory()(int),

        GetActualMemory()(int),

        GetOpenChannels()(int),

        GetCompletionTime()(int),
}

service Benchmark {

    embed Console as console
    embed Runtime as runtime

    inputPort Benchmark{
    location: "local"
        interfaces: DriverInterface
    }

    main{
        println@console("it works !!")()

        [ OpenProgram (request) (response) {

            loadEmbeddedService@Runtime(filepath = program, type = .ol)(loadResponse)

            response = 0
        }
        ]

        [ RunProgram (request) (response) {
            
            response = 0
        }
        ]

        [ CloseProgram (request) (response) {
            
            response = 0
        }
        ]

        [ GetJavaVirtualMemory (request) (response) {
            //Might need JavaService?
            response = 0
        }
        ]

        [ GetActualMemory (request) (response) {
            //Might need JavaService?
            response = 0
        }
        ]

        [ GetOpenChannels (request) (response) {
            
            response = 0
        }
        ]

        [ GetCompletionTime (request) (response) {
            //IGNORE to begin with
            response = 0
        }
        ]
    }
}