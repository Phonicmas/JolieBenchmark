from console import Console
from time import Time

interface testInterface {
    requestResponse: Run (undefined)(undefined)
}

type itemRequest {
    id: int
} 

type storiesRequest {
    newsCategory: string
}

interface JolieMiddleLayerInterface{
    RequestResponse:
        stories(storiesRequest)(undefined),
        item(itemRequest)(undefined)
}

service Test {

    execution: concurrent

    embed Console as console
    embed Time as time

    inputPort Test{
        location: local
        interfaces: testInterface
    }

    outputPort JolieMiddleLayer {
        location: "socket://localhost:8005"
        protocol: sodep
        interfaces: JolieMiddleLayerInterface
    }

    main{
        [Run (request) (response) {
            stories@JolieMiddleLayer( {newsCategory="top"})(r1)
            item@JolieMiddleLayer({id= 36003649})(r2)
        }]
    }
}