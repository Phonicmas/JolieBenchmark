from exec import Exec
from time import Time
from console import Console
from .metricCollector import MetricCollector
from string-utils import StringUtils

type params {
    .program: string
    .invocations?: int
    .cooldown?: int
    .maxLifetime?: int
    .samplingPeriod?: int
    .warmup?: int
}

interface DriverInterface{
    RequestResponse:
        OpenProgram(string)(undefined),
        RunProgram(undefined)(undefined),
        CloseProgram(undefined)(int)
    OneWay:
        Shutdown(undefined)
}

service Benchmark (p: params){

    execution: single

    embed Console as console
    embed Exec as exec
    embed Time as time
    embed MetricCollector({.portLocation = "socket://localhost:8002" .samplingPeriod = p.samplingPeriod}) as metricCollector
    embed StringUtils as stringUtils

    outputPort Driver {
        location: "socket://localhost:8001"
        protocol: http {}
        interfaces: DriverInterface
    }

    init{
        println@console("Program started")()
        
        //Used isDefined() to see if things are defined or if defaults should be used.

        //Schedules the program to die in the given time
        //scheduleTimeout@time( p.maxLifetime { .operation = "LifetimeTracker" } )( );

        exec@exec( "jolie" { .args[0] = "driver.ol" .waitFor = 0 .stdOutConsoleEnable = true})(res);
        println@console(valueToPrettyString@stringUtils(res))()
        sleep@time(1500)()

        println@console("Init block end")()
    }

    main{
        println@console("Benchmarker starting")()

        OpenProgram@Driver(p.program)(returnVal)
        println@console("Program opened")()

        //Warmup the program for atleast the given amount, currently might run for more, depending on the program.
        getCurrentTimeMillis@time()(curT)
        while(getCurrentTimeMillis@time(curT2) < (curT + p.warmup)){
            println@console("warming up")()
            RunProgram@Driver()(response)
            println@console(valueToPrettyString@stringUtils(response))()
        }

        //CollectMetrics@metricCollector()()

        for(i = 0, i < p.invocations, i++) {
                println@console("running benchmark")()
                RunProgram@Driver()(CompletionTime)
                //Write to file BenchmarkOutput, appends the content.
                //writeFile@file( {.filename = filename_time .content = CompletionTime .append = 1} )()
            }

        sleep@time(p.cooldown)()

        CloseProgram@Driver()()

        /*[ LifetimeTracker (request) {
            Shutdown@metricCollector()
            Shutdown@Driver()
            Shutdown()
        }
        ]

        [ Shutdown () ] { exit }*/
    }
}