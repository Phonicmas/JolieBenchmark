from time import Time
from console import Console
from file import File

interface DriverInterface{
    RequestResponse:
        GetJavaVirtualMemory(undefined)(long),
        GetActualMemory(undefined)(long),
        GetOpenChannels(undefined)(long),
        GetCPUSystemLoad(undefined)(double),
        GetCPUJVMLoad(undefined)(double)
}

interface MetricInternalInterface{
    OneWay:
        CollectMetrics(undefined),
        Shutdown(undefined),
        StopCollecting(undefined)
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
        protocol: sodep
        interfaces: DriverInterface
    }

    execution: concurrent
    main {
        [ CollectMetrics (request) ]{
            println@console("Metric collector started")()

            global.collectMetric = true

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

            getCurrentTimeMillis@time()(startT)

            while(global.collectMetric){
                GetJavaVirtualMemory@Driver()(JavaMem)
                writeFile@file( {
                    filename = filename_memory 
                    content = JavaMem + "," 
                    append = 1} )()

                
                GetActualMemory@Driver()(ActualMem)
                writeFile@file( {
                    filename = filename_memory 
                    content = ActualMem + ","
                    append = 1} )()

                
                GetOpenChannels@Driver()(OpenChannels)
                writeFile@file( {
                    filename = filename_openchannels 
                    content = OpenChannels + ","
                    append = 1} )()


                GetCPUSystemLoad@Driver()(CPUSLoad)
                writeFile@file( {
                    filename = filename_cpu 
                    content = CPUSLoad + ","
                    append = 1} )()

                GetCPUJVMLoad@Driver()(CPUJLoad)
                writeFile@file( {
                    filename = filename_cpu 
                    content = CPUJLoad + ","
                    append = 1} )()

                getCurrentTimeMillis@time()(endT)

                writeFile@file( {
                    filename = filename_memory 
                    content = double(endT-startT)/double(1000) + "\n"
                    append = 1} )()

                writeFile@file( {
                    filename = filename_openchannels 
                    content = double(endT-startT)/double(1000) + "\n"
                    append = 1} )()

                writeFile@file( {
                    filename = filename_cpu 
                    content = double(endT-startT)/double(1000) + "\n"
                    append = 1} )()    

                sleep@time(p.samplingPeriod)()
            }
        }

        [ StopCollecting (request) ] { global.collectMetric = false }

        [ Shutdown () ] { exit }
    }
}