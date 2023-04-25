from console import Console
from exec import Exec

//Fabrizio said: Embed server in single service; Run becnhmark in seperate JVM; We might expect people to do certain things we running the benchmark - like give certain input
//Maybe this service should be embedded?

//Jolie java service??

//Benchmark should - Find memory usage (Both what java allocates and what i actually used of that portion), cpu usage, 

//type for file from exec?

//Dynamic embed other program?

//import javaservice from jolie, annotated with @requestresponse in jave for instance

//Run Benchmark in seperate JVM that gets memory usage of program in another JVM

interface BenchmarkInterface{
    RequestResponse:
        //Should take a program and give back an array of tuples containing time and usage
        JavaMemoryUsed(undefined)(undefined),
        //Should take a program and give back an array of tuples containing time and usage
        ActualMemoryUsed(undefined)(undefined),
        //Should take a program and give back an array of tuples containing time and usage
        CPUUsage(undefined)(undefined),
        //Should take a program and give back a triple containing an array of tuples containing time and usage for each of above
        FullBenchmark(undefined)(undefined)
}

service Benchmark {

    embed Console as console
    embed Exec as exec
    //embed Server as server

    inputPort Benchmark{
    location: "socket://localhost:8001"
        protocol: http
        interfaces: BenchmarkInterface
    }

    main{
        println@console("it works !!")()

        //How much memory java allocated
        [ JavaMemoryUsed (request) (response) {
            response = 0
        }
        ]
        //How much memory is actually used in contrast to allocated portion
        [ ActualMemoryUsed (request) (response) {
            response = 0
        }
        ]
        //How much CPU is used
        [ CPUUsage (request) (response) {
            response = 0
        }
        ]
        //All of the above
        [ FullBenchmark (request) (response) {
            response = 0
        }
        ]
    }
}