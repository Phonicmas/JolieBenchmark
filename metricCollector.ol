from time import Time
from console import Console
from file import File

interface DriverInterface{
    RequestResponse:
        GetJavaVirtualMemory(undefined)(long),
        GetActualMemory(undefined)(long),
        GetOpenChannels(undefined)(long),
        GetCPULoad(undefined)(long)
}

interface MetricInternalInterface{
    RequestResponse:
        CollectMetrics(undefined)(undefined),
        Shutdown(undefined)(undefined)
}

constants {
    filename_metrics = "MetricsOuput.txt",
    filename_time = "CompletionTimeOuput.txt"
}

type metricParams {
    .portLocation: string
    .samplingPeriod: int
}

service MetricCollector (p:metricParams) {

    execution: sequential

    embed Time as time
    embed Console as console
    embed File as file

    inputPort Ip{
        location: "local"
        interfaces: MetricInternalInterface
    }

    outputPort Driver {
        location: "socket://localhost:8001"
        protocol: http {}
        interfaces: DriverInterface
    }

    main {
        [ CollectMetrics (request) (response) {
            sleep@time(1)()
            println@console("Metric collector starting")()

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

                                
                sleep@time(p.samplingPeriod)()
            }
        }
        ]

        [ Shutdown () () {
            exit
        }
        ]

    }
}