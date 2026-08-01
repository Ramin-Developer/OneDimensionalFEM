function [timings, memoryStats] = run_benchmark_workflow()
%RUN_BENCHMARK_WORKFLOW Run benchmark entrypoint with default settings.

[timings, memoryStats] = benchmark_solver();
disp('Benchmark workflow completed.');

end