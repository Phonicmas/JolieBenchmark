from exec import Exec
from time import Time
from console import Console
from metricCollector import MetricCollector

type params {
    .program: string
    .invocations: int
    .cooldown: long
    .maxLifetime: int // Not in use
    .samplingPeriod: int
    .warmup: int
}

type programInfo {
    program: string
    warmup: int
}

interface DriverInterface{
    RequestResponse:
        OpenProgram(programInfo)(int),
        RunProgram(void)(int),
        CloseProgram(void)(int),
        Shutdown(void)(void)
}

service Benchmark (p: params){

    execution: single

    embed Console as console
    embed Exec as exec
    embed Time as time
    embed MetricCollector({.portLocation = "socket://localhost:8002" .samplingPeriod = p.samplingPeriod}) as metricCollector

    outputPort Driver {
        location: "socket://localhost:8001"
        protocol: http {}
        interfaces: DriverInterface
    }

    init{
        println@console("Program started")()
        
        //Schedules the program to die in the given time
        //scheduleTimeout@time( p.maxLifetime { .operation = "LifetimeTracker" } )( );

        exec@exec( "jolie" { .args[0] = "Driver.ol" .waitFor = 0 .stdOutConsoleEnable = true})();
        
        println@console("Init block end")()
    }

    main{
        println@console("Benchmarker starting")()

        OpenProgram@Driver({.program = p.program .warmup = p.warmup})(returnVal)

        //Warmup the program for atleast the given amount, currently might run for more, depending on the program.
        getCurrentTimeMillis@time()(curT)
        while(getCurrentTimeMillis@time(curT2) < (curT + request.warmup)){
            RunProgram@Driver()(response)
            println@console("warming up")()
        }

        CollectMetrics@metricCollector()()

        for(i = 0, i < request.invocations, i++) {
                RunProgram@Driver()(CompletionTime)
                println@console("running benchmark")()
                //Write to file BenchmarkOutput, appends the content.
                //writeFile@file( {.filename = filename_time .content = CompletionTime .append = 1} )()
            }

        sleep@time(request.cooldown)()

        CloseProgram@Driver()()

        [ LifetimeTracker (request) (response) {
            shutdown@metricCollector()()
            shutdown@Driver()()
            shutdown()()
        }
        ]

        [ shutdown () () {
            exit
        }
        ]
    }
}