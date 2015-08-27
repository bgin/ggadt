ggadt_binary=../src/ggadt

$ggadt_binary --parameter-file=parameters_diffscat.ini > diffscat.dat
$ggadt_binary --parameter-file=parameters_total_xs.ini > total_xs.dat

python plot_diffscat.py diffscat.dat &
python plot_total_xs.py total_xs.dat &

echo "Plots should show up; they take a moment."