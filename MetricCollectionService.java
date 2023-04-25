package joliex.benchmark;

import java.lang.management.OperatingSystemMXBean;

public class BenchmarkService extends JavaService {

    @RequestResponse
        public void test( String message ) {
            Long commitedMem = getCommittedVirtualMemorySize();
            return commitedMem;
            return "hi";
    }
}