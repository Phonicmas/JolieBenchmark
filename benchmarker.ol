from exec import Exec
from time import Time
from console import Console
from file import File
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

constants {
    filename_time = "OutputCompletionTime.csv"
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
    embed File as file

    outputPort Driver {
        location: "socket://localhost:8001"
        protocol: sodep
        interfaces: DriverInterface
    }

    init{
        install (default => exit)
        println@console("Program started")()

        if(!is_defined(p.invocations)){p.invocations = 10000} //10000 invocation default
        if(!is_defined(p.cooldown)){p.cooldown = 5000} //5sec default
        if(!is_defined(p.maxLifetime)){p.maxLifetime = 300000} //5min default
        if(!is_defined(p.samplingPeriod)){p.samplingPeriod = 250} //250milisecond default
        if(!is_defined(p.warmup)){p.warmup = 5000} //5sec default
        
        exec@exec( "jolie" { .args[0] = "driver.ol" .waitFor = 0 .stdOutConsoleEnable = true})(res);
        sleep@time(3000)()
    }

    main{
        println@console("Benchmarker starting for " + p.program)()

        OpenProgram@Driver(p.program)(returnVal)


        getCurrentTimeMillis@time()(startT)
        getCurrentTimeMillis@time()(endT)
        end = endT
        start = startT+p.warmup
        println@console("Warming up")()
        while(end < start){
            getCurrentTimeMillis@time()(endT)
            end = endT
            RunProgram@Driver()()
        }

        CollectMetrics@metricCollector()

        exists@file(filename_time)(fileExists)
            if(fileExists){
                delete@file(filename_time)(r)
            }

        println@console("Running benchmark")()
        CompletionTimes = 0
        for(i = 0, i < p.invocations, i++) {        
                RunProgram@Driver()(CompletionTime)
                writeFile@file( {
                    filename = filename_time 
                    content = CompletionTime + "," + int(i+1) + "\n"
                    append = 1} )()
                CompletionTimes = CompletionTimes + CompletionTime
            }

        CompletionTimes = CompletionTimes/p.invocations
        writeFile@file( {
                    filename = filename_time 
                    content = CompletionTimes + "\n"
                    append = 1} )()
        println@console("Average time per invocation: " + CompletionTimes + " milliseconds")()
        sleep@time(p.cooldown)()

        println@console("Stopping and closing metric collector")()
        StopCollecting@metricCollector()
        Shutdown@metricCollector()

        println@console("Stopping and closing driver")()
        CloseProgram@Driver()()
        Shutdown@Driver()

        println@console("Making plots")()

        //Can probably make it not wait for each exec to complete, doesn't really matter
        exec@exec( "gnuplot" { .args[0] = "gnuCommandsMemory.p" .waitFor = 1})();
        exec@exec( "gnuplot" { .args[0] = "gnuCommandsOpenChannels.p" .waitFor = 1})();
        exec@exec( "gnuplot" { .args[0] = "gnuCommandsCPU.p" .waitFor = 1})();
        //exec@exec( "gnuplot" { .args[0] = "gnuCommandsCompletionTime.p" .waitFor = 1})();

        /*println@console("Opening plots")()
        exec@exec( "xdg-open" { .args[0] = "gnuPlotCPU.png" .waitFor = 0})();
        exec@exec( "xdg-open" { .args[0] = "gnuPlotMemory.png" .waitFor = 0})();
        exec@exec( "xdg-open" { .args[0] = "gnuPlotOpenChannels.png" .waitFor = 0})();
        exec@exec( "xdg-open" { .args[0] = "gnuPlotCompletionTime.png" .waitFor = 0})();*/

        exit
    }
}