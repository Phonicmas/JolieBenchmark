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
        println@console("Testing")()
        sleep@time(500)()
    }

    main{
        [Run (request) (response) {
            println@console("Test")()
            sleep@time(1000)()
        }]
    }
}