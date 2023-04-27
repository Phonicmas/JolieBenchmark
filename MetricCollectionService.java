package joliex.benchmark;

import java.lang.management.OperatingSystemMXBean;

public class BenchmarkService extends JavaService {

    @RequestResponse
        public Long commitedMemory( String message ) {
            OperatingSystemMXBean osBean = ManagementFactory.getOperatingSystemMXBean();
            Long vMem = osBean.getCommittedVirtualMemorySize();
            return vMem; //Maybe do like runtime.stats does?
    }

}