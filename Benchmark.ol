from console import Console
from exec import Exec
from time import Time
from file import File

type runBenchmarkRequest {
    program: string
    invocations: int
    cooldown: long
    maxLifetime: int
    samplingPeriod: int
    metrics: metrics
    warmup: int
}

type metrics {
    javaMemory: int
    actualMemory: int
    openChannels: int
    completionTime: int
}

type programInfo {
    program: string
    warmup: int
}

interface BenchmarkInterface{
    RequestResponse:
        RunBenchmark(runBenchmarkRequest)(string),
}

interface BenchmarkInternalInterface{
    RequestResponse:
        CollectMetrics(void)(void)
}

interface DriverInterface{
    RequestResponse:
        OpenProgram(programInfo)(int),

        RunProgram(void)(int),

        CloseProgram(void)(int),

        GetJavaVirtualMemory(void)(int),

        GetActualMemory(void)(int),

        GetOpenChannels(void)(int),

        GetCPULoad(void)(int)
}

constants {
    filename_metrics = "MetricsOuput.txt",
    filename_time = "CompletionTimeOuput.txt"
}

service Benchmark {

    execution: concurrent

    embed Console as console
    embed Exec as exec
    embed Time as time
    embed File as file 

    inputPort Benchmark{
        location: "socket://localhost:8000"
        protocol: http {}
        interfaces: BenchmarkInterface
    }

    inputPort BenchmarkInternal{
        interfaces: BenchmarkInternalInterface
        location: "local"
    }

    outputPort Driver {
        location: "socket://localhost:8001"
        protocol: http {}
        interfaces: DriverInterface
    }
    
    init{
        scheduleTimeout@Time( 100 { .operation = "CollectMetrics" } )( );
    }

    main{
        println@console("Benchmarker starting")()

        [ RunBenchmark (request) (response) {
            println@console("launching driver")()
            exec@exec( "jolie" { .args[0] = "-s" .args[1] = "${Driver}".args[2] = request.program .waitFor = 1 });

            //println@console("opening Driver")()
            OpenProgram@Driver(.program = request.program .warmup = request.warmup)(returnVal);

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
        ]

        [ CollectMetrics (request) (response) {

            while(true){
                GetJavaVirtualMemory@Driver()(JavaMem)
                println@console("JavaMem:" + JavaMem)()
                //Write to file BenchmarkOutput, appends the content.
                //writeFile@file( {.filename = filename_metrics .content = JavaMem .append = 1} )()

                
                GetActualMemory@Driver()(ActualMem)
                println@console("ActualMem:" + ActualMem)()
                //Write to file BenchmarkOutput, appends the content.
                //writeFile@file( {.filename = filename_metrics .content = ActualMem .append = 1} )()

                
                GetOpenChannels@Driver()(OpenChannels)
                println@console("OpenChannels:" + OpenChannels)()
                //Write to file BenchmarkOutput, appends the content.
                //writeFile@file( {.filename = filename_metrics .content = OpenChannels .append = 1} )()


                GetCPULoad@Driver()(CPULoad)
                println@console("OpenChannels:" + CPULoad)()
                //Write to file BenchmarkOutput, appends the content.
                //writeFile@file( {.filename = filename_metrics .content = CPULoad .append = 1} )()

                                
                sleep@time(request.samplingPeriod)()
            }

            response = 0
        }
        ]

    }
}