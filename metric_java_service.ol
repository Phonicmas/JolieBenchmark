interface ServiceInterface{
    requestResponse: CPUSystemLoad(void)(double)
    requestResponse: CPUJVMLoad(void)(double)
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