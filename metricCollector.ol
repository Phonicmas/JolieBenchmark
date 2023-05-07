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
    OneWay:
        CollectMetrics(undefined),
        Shutdown(undefined)
}

constants {
    filename_memory = "OutputMemory.csv",
    filename_openchannels = "OutputOpenChannels.csv",
    filename_cpu = "OutputCPU.csv"
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
        protocol: http
        interfaces: DriverInterface
    }

    main {
        [ CollectMetrics (request) ]{
            sleep@time(1)()
            println@console("Metric collector starting")()


            /*HERE IN CASE I NEED TO MAKE MULTIPLE NEW BENCHMARKS FILES, THEY WILL BE ITERATED
            filename_metrics = "MetricsOuput.txt"
            exists = true
            i = 1

            while (exists) {
                println@console(exists + " - " + i)()
                exists@File(filename_metrics)(fileExists)
                if (fileExists) {
                    filename_metrics = "MetricsOutput.txt" + i
                }
            }*/

            exists@file(filename_memory)(fileExists)
            if(fileExists){
                delete@file(filename_memory)(r)
            }

            exists@file(filename_cpu)(fileExists2)
            if(fileExists2){
                delete@file(filename_cpu)(r)
            }

            exists@file(filename_openchannels)(fileExists3)
            if(fileExists3){
                delete@file(filename_openchannels)(r)
            }

            /*writeFile@file( {
                    filename = filename_metrics 
                    content = "JavaMem,ActualMem,OpenChannels,CPULoad\n" 
                    append = 1} )()*/

            while(true){
                GetJavaVirtualMemory@Driver()(JavaMem)
                println@console("JavaMem:" + JavaMem + "bytes")()
                writeFile@file( {
                    filename = filename_memory 
                    content = JavaMem + "," 
                    append = 1} )()

                
                GetActualMemory@Driver()(ActualMem)
                println@console("ActualMem:" + ActualMem + "bytes")()
                writeFile@file( {
                    filename = filename_memory 
                    content = ActualMem + "\n"
                    append = 1} )()

                
                GetOpenChannels@Driver()(OpenChannels)
                println@console("OpenChannels:" + OpenChannels)()
                writeFile@file( {
                    filename = filename_openchannels 
                    content = OpenChannels + "\n"
                    append = 1} )()


                GetCPULoad@Driver()(CPULoad)
                println@console("CPULoad:" + CPULoad + "%")()
                writeFile@file( {
                    filename = filename_cpu 
                    content = CPULoad + "\n"
                    append = 1} )()

                                
                sleep@time(p.samplingPeriod)()
            }
        }

        [ Shutdown () ] { exit }

    }
}