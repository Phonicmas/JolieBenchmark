interface ServiceInterface{
    requestResponse: test(string)(string)
}

service BenchmarkService {
    inputPort ip {
        location:"local"
        interfaces: ServiceInterface
    }

    foreign java {
        class: "joliex.benchmark.BenchmarkService"
    }
}