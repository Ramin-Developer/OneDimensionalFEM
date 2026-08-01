function results = run_regression_tests()
%RUN_REGRESSION_TESTS Execute full regression tests from repository root.

results = run_all_tests();
disp('Regression tests passed.');

end