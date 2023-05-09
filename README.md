# JolieBenchmark

To run this benchmark a few things are requires from the user(you).

You must make a jolie program, containing an operaration "Run(undefined)(undefined)", which when run should run the method or program that needs to be benchmarked. If another program is being benchmarked, it should be running inside the same JVM as the jolie program itself.

You may configure the config.json file to your liking, if nothing is done, default values are used.

metric_java_service.ol should be placed in jolie/packages

BenchmarkService.java should be placed in jolie/javaServices/coreJavaServices/src/main/java/joliex/benchmark

after which mvn clean install can be run from jolie/