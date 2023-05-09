package joliex.benchmark;

import java.lang.management.ManagementFactory;
import com.sun.management.OperatingSystemMXBean;

import jolie.runtime.JavaService;
import jolie.runtime.embedding.RequestResponse;

public class BenchmarkService extends JavaService {

	@RequestResponse
	public Double CPUSystemLoad() {
		OperatingSystemMXBean osBean = (com.sun.management.OperatingSystemMXBean) ManagementFactory.getOperatingSystemMXBean();
		return Double.valueOf( osBean.getSystemLoadAverage() );
	}

	public Double CPUJVMLoad() {
		OperatingSystemMXBean osBean = (com.sun.management.OperatingSystemMXBean) ManagementFactory.getOperatingSystemMXBean();
		return Double.valueOf( osBean.getProcessCpuLoad() );
	}
}
