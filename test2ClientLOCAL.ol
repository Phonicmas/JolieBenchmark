from console import Console
from time import Time

interface testInterface {
    requestResponse: Run (undefined)(undefined)
}

interface testInterfaceServer {
    requestResponse: Run (undefined)(undefined)
}

service Test {

    execution: concurrent

    embed Console as console
    embed Time as time

    inputPort Test{
        location: local
        interfaces: testInterface
    }

    outputPort test {
        location: local
        interfaces: testInterfaceServer
    }

    main{
        [Run (request) (response) {
            Run@test()(r)
        }]
    }
}