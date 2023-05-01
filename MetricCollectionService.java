package joliex.benchmark;

import java.lang.management.OperatingSystemMXBean;

public class BenchmarkService extends JavaService {

    @RequestResponse
        public Long commitedMemory() {
            OperatingSystemMXBean osBean = ManagementFactory.getOperatingSystemMXBean();
            Long vMem = osBean.getCommittedVirtualMemorySize();
            return vMem; //Maybe do like runtime.stats does?
        }

    public Long CPULoad() {
        OperatingSystemMXBean osBean = ManagementFactory.getOperatingSystemMXBean();
        Long vMem = osBean.getProcessCpuLoad();
        return vMem; //Maybe do like runtime.stats does?
        }

}