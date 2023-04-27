from console import Console
from exec import Exec
from time import Time

type runBenchmarkRequest {
    program: string
    invocations: int
    cooldown: long
    maxLifetime: int
    samplingPeriod: int
    metrics: metricsTuple
    warmup: bool
}

type metricsTuple {
    javaMemory: bool
    actualMemory: bool
    openChannels: bool
    completionTime: bool
}

type metrics {
    javaMemory: int
    actualMemory: int
    openChannels: int
    completionTime: int
}

interface BenchmarkInterface{
    RequestResponse:
        RunBenchmark(runBenchmarkRequest)(string)
        CollectMetrics(int)(metrics)
}

service Benchmark {

    execution: concurrent

    embed Console as console
    embed Exec as exec
    embed Time as time

    inputPort Benchmark{
        location: "socket://localhost:8000"
        protocol: http {}
        interfaces: BenchmarkInterface
    }

    inputPort BenchmarkInternal{
        interfaces: BenchmarkInterface
        location: "local"
    }
    
    init{
        scheduleTimeout@Time( 100 { .operation = "CollectMetrics" } )( );
    }

    main{
        println@console("Benchmarker starting")()

        [ RunBenchmark (request) (response) {
            exec@exec( "jolie" { .args[0] = "-s" .args[1] = "${Driver}".args[2] = request.program .waitFor = 1 })

            OpenProgram@driver(program = request.program, warmup = request.warmup)()

            for(i = 0, i < request.invocations, i++) {
                RunProgram@driver()() //Should this be inside another loop and wait for a certain response? Or does it only move on once a response has been recieved.
            }
            
            //Keeps the program open for an additional time period as specified
            //Will this work, perhaps just use sleep?
            //getCurrentTimeMillis@Time()(curT)
            //while(getCurrentTimeMillis@Time()(curT2) < (curT + request.cooldown)){}

            sleep@time(request.cooldown)()

            CloseProgram@driver()()

            response = 0
        }
        ]

        [ CollectMetrics (request) (response) {

            //Gathers the metrics which was specified every time unit given.
            //This should keep running until the program is closed.
            while(true){
                if(request.metrics.javaMemory){
                    GetJavaVirtualMemory@driver()(JavaMem)
                }
                if(request.metrics.actualMemory){
                    GetActualMemory@driver()(ActualMem)
                }
                if(request.metrics.openChannels){
                    GetOpenChannels@driver()(OpenChannels)
                }
                /*if(request.metrics.completionTime){
                    GetCompletionTime@driver()(CompletionTime)
                }*/
                sleep@time(request.samplingPeriod)()
            }

            response = 0
        }
        ]

    }
}