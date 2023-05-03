include "MetricCollector.ol"
from exec import Exec


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
        CloseProgram(void)(int)
}

service Benchmark (p: params){

    execution: single

    embed Console as console
    embed Exec as exec
    embed Time as time
    embed MetricCollector({.portLocation = "socket://localhost:8000" .samplingPeriod = p.samplingPeriod}) as metricCollector

    outputPort Driver {
        location: "socket://localhost:8001"
        protocol: http {}
        interfaces: DriverInterface
    }
    
    init{
        println@console("Program started")()
        //scheduleTimeout@time( p.maxLifetime { .operation = "LifetimeTracker" } )( );
        exec@exec( "jolie" { .args[0] = "Driver.ol" .waitFor = 0 .stdOutConsoleEnable = true})();
        println@console("Init block end")()
    }

    main{
        println@console("Benchmarker starting")()

        CollectMetrics@metricCollector()()

        OpenProgram@Driver({.program = p.program .warmup = p.warmup})(returnVal)

        for(i = 0, i < request.invocations, i++) {
                RunProgram@Driver()(CompletionTime)
                //println@console("running benchmark")()
                //Write to file BenchmarkOutput, appends the content.
                //writeFile@file( {.filename = filename_time .content = CompletionTime .append = 1} )()
            }

        sleep@time(request.cooldown)()

        CloseProgram@Driver()()


        /*[ RunBenchmark (request) (response) {
            println@console("launching driver")()
            //Should open the driver and nothing else.
            exec@exec( "jolie" { .args[0] = "-s" .args[1] = "${Driver}".args[2] = "Driver" .waitFor = 1 })();

            //println@console("opening Driver")()
            OpenProgram@Driver({.program = request.program .warmup = request.warmup})(returnVal);

            for(i = 0, i < request.invocations, i++) {
                RunProgram@Driver()(CompletionTime)
                //println@console("running benchmark")()
                //Write to file BenchmarkOutput, appends the content.
                //writeFile@file( {.filename = filename_time .content = CompletionTime .append = 1} )()
            }

            sleep@time(request.cooldown)()

            CloseProgram@Driver()()

            //Exec gnu plot here to make graph
            //exec@exec()()

            response = 0
        }
        ]*/

        [ LifetimeTracker (request) (response) {
           Halt@runtime()() 
        }
        ]
    }
}