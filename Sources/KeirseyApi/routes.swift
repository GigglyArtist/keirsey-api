import Vapor

func routes(_ app: Application) throws {
    app.get { req in "It works!" }
    app.get("hello") { req -> String in "Hello, world!" }

    let keirsey = KeirseyController()
    app.group("api", "v1") { api in
        api.post("keirsey", "result", use: keirsey.result)
    }
}
