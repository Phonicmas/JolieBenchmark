from console import Console
from exec import Exec

type runBenchmarkRequest {
    program: string
    invocations: int
    cooldown: int
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

interface BenchmarkInterface{
    RequestResponse:
        RunBenchmark(runBenchmarkRequest)(string)
}

service Benchmark {

    embed Console as console
    embed Exec as exec

    inputPort Benchmark{
    location: "local"
        interfaces: BenchmarkInterface
    }

    main{
        println@console("it works !!")()

        [ RunBenchmark (request) (response) {
            request.program
            exec@exec (args = .ol, workingDirectory = request.program) (execResponse)
            response = 0
        }
        ]
    }
}