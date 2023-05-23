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

    outputPort Hackernews {
        location: "socket://hacker-news.firebaseio.com:443/"
        protocol: https {
            format = "json"
            osc.item << {
                template = "v0/item/{id}.json"
                method = "get"
            }
            osc.stories << {
                template = "v0/{newsCategory}stories.json"
                method = "get"
            }
        }
        interfaces: JolieMiddleLayerInterface
    }

    main{
        [Run (request) (response) {
            stories@Hackernews( {newsCategory="top"})(r1)
            item@Hackernews({id= 36003649})(r2)
        }]
    }
}