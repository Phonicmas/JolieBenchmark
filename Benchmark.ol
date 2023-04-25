from console import Console
from exec import Exec
from string_utils import StringUtils

//Fabrizio said: Embed server in single service; Run becnhmark in seperate JVM; We might expect people to do certain things we running the benchmark - like give certain input
//Maybe this service should be embedded?

//Jolie java service??

//Benchmark should - Find memory usage (Both what java allocates and what i actually used of that portion), cpu usage, 

//type for file from exec?

//Dynamic embed other program?

//import javaservice from jolie, annotated with @requestresponse in jave for instance

//Run Benchmark in seperate JVM that gets memory usage of program in another JVM

type runBenchmarkRequest {
    program: string
    invocations: int
    cooldown: int
    maxLifetime: int
    samplingPeriod: int
    metrics: bool //(bool, bool, bool, bool)
    warmup: bool
}

interface BenchmarkInterface{
    RequestResponse:
        RunBenchmark(runBenchmarkRequest)(string)
}

service Benchmark {

    embed Console as console
    embed Exec as exec
    embed StringUtils as stringUtils

    inputPort Benchmark{
    location: "socket://localhost:8001"
        protocol: http
        interfaces: BenchmarkInterface
    }

    main{
        println@console("it works !!")()

        //How much memory java allocated
        [ RunBenchmark (request) (response) {
            response = 0
        }
        ]
    }
}