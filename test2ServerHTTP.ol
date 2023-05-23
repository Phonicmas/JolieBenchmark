from console import Console
from time import Time

interface testInterfaceServer {
    requestResponse: Run (undefined)(undefined)
}

service Test {

    execution: concurrent

    embed Console as console
    embed Time as time

    inputPort test {
        location: "socket://localhost:8005"
        protocol: http
        interfaces: testInterfaceServer
    }

    main{
        [Run (request) (response) {
            response = 0
        }]
    }
}