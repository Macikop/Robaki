set report_dir [file normalize [file join [file dirname [info script]] .. .. results timing_reports]]
file mkdir $report_dir

report_clock_interaction -file [file join $report_dir clock_interaction.log]
report_timing_summary -delay_type max -warn_on_violation -file [file join $report_dir timing_summary_max.log]
report_timing_summary -delay_type min -warn_on_violation -file [file join $report_dir timing_summary_min.log]

report_timing -delay_type max -max_paths 20 -sort_by slack -path_type full_clock_expanded -file [file join $report_dir worst_setup_paths.log]
report_timing -delay_type min -max_paths 20 -sort_by slack -path_type full_clock_expanded -file [file join $report_dir worst_hold_paths.log]