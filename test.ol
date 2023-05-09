from console import Console
from time import Time

interface testInterfance {
    requestResponse: Run (undefined)(undefined)
}

service Test {

    execution: concurrent

    embed Console as console
    embed Time as time

    inputPort Test{
        location: local
        interfaces: testInterfance
    }

    main{
        [Run (request) (response) {
            println@console("Test")()
            sleep@time(250)()
        }]
    }
}