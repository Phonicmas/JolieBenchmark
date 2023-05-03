from console import Console
from time import Time

interface testInterfance {
        requestResponse: Run (undefined)(undefined)
}

service Test {

    execution: single

    embed Console as console
    embed Time as time

    inputPort Driver{
        location: local
        interfaces: testInterfance
    }

    init{
        sleep@time(500)()
        println@console("Testing")()
    }

    main{
        [Run (request) (response) {
            sleep@time(1000)()
            println@console("Test")()
        }]
    }
}