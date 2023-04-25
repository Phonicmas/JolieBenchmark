from console import Console
from string_utils import StringUtils

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

service JolieMiddleLayer {
    embed Console as console
    embed StringUtils as stringUtils

    execution: concurrent

    //Output port - how to get things from other services/APIs
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

    //Input port - how others get things from this service
    inputPort JolieMiddleLayer {
        location: "socket://localhost:8000"
        protocol: http {
            addHeader.header << "Access-Control-Allow-Origin" {value = "*"}
            contentType = "application/json"
            format = "json"
            }

        interfaces: JolieMiddleLayerInterface
    }

    main{
        [ stories (request) (response){
            response << stories@Hackernews(request)
        }
        ]

        [ item (request) (response) {
            response << item@Hackernews(request)

            if (#response.kids == 1) {
                println@console(response.kids)()
                response.kids._ << request.kids
                println@console(response.kids._)()
            }
            
        }
        ]
    }
}